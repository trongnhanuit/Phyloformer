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

def normalize_partial_lhs_one_tensor(tensor_filename: str, input_dir: str, output_dir: str):
    input_filename = os.path.join(input_dir, tensor_filename)
    output_filename = os.path.join(output_dir, tensor_filename)

    # if the file exists -> ignore
    if (not (os.path.isfile(output_filename) and os.path.getsize(output_filename) > 0)):
        tensor = torch.load(input_filename)
        # size before transposing [4,200,20]
        partial_lhs = tensor['X']
        # transpose to [20,200,4]
        partial_lhs = torch.transpose(partial_lhs, 0, -1)
        # new sizes
        X, Y, Z = list(partial_lhs.size())
        # Threshold for small values
        SMALL_THRESHOLD = 1e-3
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
                    print(input_filename)
                    print("x = " + str(x))
                    print("y = " + str(y))
                    for z in range(Z):
                        partial_lhs[x][y][z] = 0
                else:
                    partial_lhs[x][y] = partial_lh / total

                    # NHANLT
                    # avoid very small values after normalization
                    small_value_found = False
                    partial_lh = partial_lhs[x][y]
                    for z in range(Z):
                        if (partial_lh[z] > 0) and (partial_lh[z] < SMALL_THRESHOLD):
                            small_value_found = True
                            #print(partial_lh)
                            partial_lh[z] = 0
                    if small_value_found:
                        total = sum(partial_lh)
                        #print("Small values found")
                        #print("- Original values")
                        #print(partial_lhs[x][y])
                        #print(partial_lh)
                        partial_lhs[x][y] = partial_lh / total
                        #print("- After resetting small values to 0 and re-normalizing them")
                        #print(partial_lhs[x][y])



        # re-transpose the partial_lhs from [20,200,4] to [4,200,20]
        partial_lhs = torch.transpose(partial_lhs, 0, -1)

        # save the tensor to file
        torch.save(
            {"X": partial_lhs, "y": tensor['y']},
            output_filename,
        )

def normalize_partial_lhs_tensors(input_dir: str, output_dir: str, nprocesses):
    tensor_files = [file for file in os.listdir(input_dir) if file.endswith(".tensor_pair")]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(tensor_files)) as pbar:
        for _iter in pool.imap_unordered(partial(normalize_partial_lhs_one_tensor, input_dir=input_dir, output_dir=output_dir), tensor_files):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Normalize partial lhs in tensors"
    )
    parser.add_argument(
        "-i",
        "--input_dir",
        required=True,
        type=str,
        help="path to input directory containing the tensor files",
    )
    parser.add_argument(
        "-o",
        "--output_dir",
        required=True,
        type=str,
        help="path to output directory to store the tensors after normalizing the partial lhs",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if not os.path.exists(args.output_dir):
        os.mkdir(args.output_dir)

    normalize_partial_lhs_tensors(args.input_dir, args.output_dir, args.nprocesses)


if __name__ == "__main__":
    main()
