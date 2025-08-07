import argparse
import os

import torch
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

# for linux
from pathlib import Path
import sys
path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))
#print(sys.path)

from phyloformer.data import read_distances_from_file, load_partial_lhs

def process_a_connected_region(dis_mat_file, connected_region_dir: str, partial_lh_dir: str, out_dir: str):
    identifier = dis_mat_file.rstrip(".txt")
    filename = os.path.join(out_dir, f"{identifier}.tensor_pair")

    # if the file exists -> ignore
    if (not (os.path.isfile(filename) and os.path.getsize(filename) > 0)):
        # only process connected regions with the corresponding partial lhs found
        if (os.path.isfile(os.path.join(partial_lh_dir, f"{identifier}.txt")) and os.path.getsize(os.path.join(partial_lh_dir, f"{identifier}.txt")) > 0):
            #pbar.set_description(f"Processing {identifier}")
            aln_tensor, ids = load_partial_lhs(os.path.join(partial_lh_dir, f"{identifier}.txt"))
            tree_tensor = read_distances_from_file(os.path.join(connected_region_dir, dis_mat_file), ids)

            # Debug
            #print("Connected_region shape:" )
            #print(tree_tensor.shape)
            #print("Partial lhs shape:")
            #print(aln_tensor.shape)

            # size before transposing [22,200,20]
            partial_lhs = aln_tensor
            # transpose to [20,200,22]
            partial_lhs = torch.transpose(partial_lhs, 0, -1)
            # new sizes
            X, Y, Z = list(partial_lhs.size())
            # Threshold for small values
            # SMALL_THRESHOLD = 1e-3
            for x in range(X):
                for y in range(Y):
                    partial_lh = partial_lhs[x][y]

                    # set the printing precision
                    # torch.set_printoptions(precision=100, sci_mode=True)

                    # rescale partial lhs before normalizing them to make sure sum of them are not zero due to too-small values
                    max_partial_val = max(partial_lh)
                    partial_lh = partial_lh / max_partial_val
                    total = sum(partial_lh)

                    if total == 0:
                        print("WARNING: total == 0. Set all partial lh entries to 1.")
                        for z in range(Z):
                            partial_lhs[x][y][z] = 1
                    elif total < 0:
                        print("ERROR: total < 0. Set all partial lh entries to 0.")
                        print(partial_lh)
                        print(os.path.join(partial_lh_dir, f"{identifier}.txt"))
                        print("x = " + str(x))
                        print("y = " + str(y))
                        for z in range(Z):
                            partial_lhs[x][y][z] = 0
                    else:
                        partial_lhs[x][y] = partial_lh / total

                        # NHANLT
                        # avoid very small values after normalization
                        # small_value_found = False
                        # partial_lh = partial_lhs[x][y]
                        # for z in range(Z):
                        #    if (partial_lh[z] > 0) and (partial_lh[z] < SMALL_THRESHOLD):
                        #        small_value_found = True
                        # print(partial_lh)
                        #        partial_lh[z] = 0
                        # if small_value_found:
                        #    total = sum(partial_lh)
                        # print("Small values found")
                        # print("- Original values")
                        # print(partial_lhs[x][y])
                        # print(partial_lh)
                        #    partial_lhs[x][y] = partial_lh / total
                        # print("- After resetting small values to 0 and re-normalizing them")
                        # print(partial_lhs[x][y])

            # re-transpose the partial_lhs from [20,200,4] to [4,200,20]
            partial_lhs = torch.transpose(partial_lhs, 0, -1)

            torch.save(
                {"X": partial_lhs, "y": tree_tensor},
                os.path.join(out_dir, f"{identifier}.tensor_pair"),
            )

def make_tensors_from_connected_regions(connected_region_dir: str, aln_dir: str, out_dir: str, nprocesses):
    connected_regions = [file for file in os.listdir(connected_region_dir) if (file.endswith(".txt") and ".con_reg_" not in file)]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(connected_regions)) as pbar:
        for _iter in pool.imap_unordered(partial(process_a_connected_region, connected_region_dir=connected_region_dir, partial_lh_dir=aln_dir, out_dir=out_dir), connected_regions):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Generate a tensor training set from distance matrices and ASRs"
    )
    parser.add_argument(
        "-dm",
        "--dis_mat",
        required=True,
        type=str,
        help="path to input directory containing the distance matrix files",
    )
    parser.add_argument(
        "-asr",
        "--asr",
        required=True,
        type=str,
        help="path to input directory containing corresponding ASR files",
    )
    parser.add_argument(
        "-o",
        "--output",
        required=False,
        default=".",
        type=str,
        help="path to output directory (default: current directory)",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if not os.path.exists(args.output):
        os.mkdir(args.output)

    make_tensors_from_connected_regions(args.dis_mat, args.asr, args.output, args.nprocesses)


if __name__ == "__main__":
    main()
