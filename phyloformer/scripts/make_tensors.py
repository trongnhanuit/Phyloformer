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

from phyloformer.data import load_alignment, load_tree, load_connected_region, load_partial_lhs

def process_a_tree(tree_file, tree_dir: str, aln_dir: str, out_dir: str):
    identifier = tree_file.rstrip(".nwk")
    filename = os.path.join(out_dir, f"{identifier}.tensor_pair")

    # if the file exists -> ignore
    if (not (os.path.isfile(filename) and os.path.getsize(filename) > 0)):
        #pbar.set_description(f"Processing {identifier}")
        tree_tensor, _ = load_tree(os.path.join(tree_dir, tree_file))
        aln_tensor, _ = load_alignment(os.path.join(aln_dir, f"{identifier}.fasta"))

        # Debug
        print("Tree tensor shape:")
        print(tree_tensor.shape)
        print("Alignment tensor shape:")
        print(aln_tensor.shape)

        torch.save(
            {"X": aln_tensor, "y": tree_tensor},
            os.path.join(out_dir, f"{identifier}.tensor_pair"),
        )

def process_a_connected_region(dis_mat_file, connected_region_dir: str, partial_lh_dir: str, out_dir: str):
    identifier = dis_mat_file.rstrip(".txt")
    filename = os.path.join(out_dir, f"{identifier}.tensor_pair")

    # if the file exists -> ignore
    if (not (os.path.isfile(filename) and os.path.getsize(filename) > 0)):
        #pbar.set_description(f"Processing {identifier}")
        tree_tensor, _ = load_connected_region(os.path.join(connected_region_dir, dis_mat_file))
        aln_tensor, _ = load_partial_lhs(os.path.join(partial_lh_dir, f"{identifier}.txt"))

        # Debug
        #print("Connected_region shape:" )
        #print(tree_tensor.shape)
        #print("Partial lhs shape:")
        #print(aln_tensor.shape)

        torch.save(
            {"X": aln_tensor, "y": tree_tensor},
            os.path.join(out_dir, f"{identifier}.tensor_pair"),
        )

def make_tensors(tree_dir: str, aln_dir: str, out_dir: str, nprocesses):
    trees = [file for file in os.listdir(tree_dir) if file.endswith(".nwk")]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(trees)) as pbar:
        for _iter in pool.imap_unordered(partial(process_a_tree, tree_dir=tree_dir, aln_dir=aln_dir, out_dir=out_dir), trees):
            pbar.update()

def make_tensors_from_connected_regions(connected_region_dir: str, aln_dir: str, out_dir: str, nprocesses):
    connected_regions = [file for file in os.listdir(connected_region_dir) if file.endswith(".txt")]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(connected_regions)) as pbar:
        for _iter in pool.imap_unordered(partial(process_a_connected_region, connected_region_dir=connected_region_dir, partial_lh_dir=aln_dir, out_dir=out_dir), connected_regions):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Generate a tensor training set from trees and MSAs"
    )
    parser.add_argument(
        "-t",
        "--treedir",
        required=True,
        type=str,
        help="path to input directory containing the .nwk tree files",
    )
    parser.add_argument(
        "-a",
        "--alidir",
        required=True,
        type=str,
        help="path to input directory containing corresponding .fasta alignments",
    )
    parser.add_argument(
        "-o",
        "--output",
        required=False,
        default=".",
        type=str,
        help="path to output directory (default: current directory)",
    )
    parser.add_argument(
        "-con_reg",
        "--connected_region",
        required=False,
        default=False,
        action = 'store_true',
        help="TRUE to use connected regions instead of trees",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if not os.path.exists(args.output):
        os.mkdir(args.output)

    if args.connected_region:
        make_tensors_from_connected_regions(args.treedir, args.alidir, args.output, args.nprocesses)
    else:
        make_tensors(args.treedir, args.alidir, args.output, args.nprocesses)


if __name__ == "__main__":
    main()
