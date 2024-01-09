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

from phyloformer.data import load_alignment, load_tree

def process_a_tree(tree_file, tree_dir: str, aln_dir: str, out_dir: str):
    identifier = tree_file.rstrip(".nwk")
    filename = os.path.join(out_dir, f"{identifier}.tensor_pair")

    # if the file exists -> ignore
    if (not (os.path.isfile(filename) and os.path.getsize(filename) > 0)):
        #pbar.set_description(f"Processing {identifier}")
        tree_tensor, _ = load_tree(os.path.join(tree_dir, tree_file))
        aln_tensor, _ = load_alignment(os.path.join(aln_dir, f"{identifier}.fasta"))

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
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if not os.path.exists(args.output):
        os.mkdir(args.output)

    make_tensors(args.treedir, args.alidir, args.output, args.nprocesses)


if __name__ == "__main__":
    main()
