import argparse
import os

import torch
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
import pandas as pd
import subprocess

# for linux
from pathlib import Path
import sys
import random
import numpy as np
from datetime import datetime
import glob, os

path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))

#IQ_TREE_PATH ="/project/AliSim/iq-tree-dl/Phyloformer/phyloformer/scripts/iqtree2"
IQ_TREE_PATH ="/scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/iqtree2"
def process_a_tree(row_enum, aln_dir: str, tree_dir: str, dis_mat_dir: str, partial_lh_dir: str, start_seed):
    # set random seed num
    file_index, row = row_enum
    seed_num = start_seed + file_index
    random.seed(seed_num)

    data = row.split('\t');

    # if the file exists -> ignore
    tree_file_full_path = os.path.join(tree_dir, "tree_" + data[0] + ".nwk")
    if (not (os.path.isfile(tree_file_full_path) and os.path.getsize(tree_file_full_path) > 0)):
        # write the tree file
        with open(tree_file_full_path, "w") as tree_file:
            tree_file.write(data[4])

        # compute the number of connected regions
        num_con_regs = int((int(data[2]) - 20) / 10) + 1

        # execute IQ-TREE to select connected regions
        fixed_blength = "  -blfix "
        # can't fix the blengths if using +R model
        if "+R" in data[3]:
            fixed_blength = ""

        global IQ_TREE_PATH
        full_cmd = IQ_TREE_PATH + " -s " + os.path.join(aln_dir, data[1] + ".phy") + " -te " + tree_file_full_path \
                   + fixed_blength + " -redo -m " + data[3] + " -num-con-regs " + str(num_con_regs) \
                   + " -dis-mat " + os.path.join(dis_mat_dir, "tree_" + data[0]) + " -partial-lh " + os.path.join(partial_lh_dir, "tree_" + data[0]) \
                   + " -nt 1 --kernel-nonrev -seed " + str(seed_num)

        bash_cmd = (
            f"{full_cmd}"
        )
        process = subprocess.Popen(bash_cmd, shell=True, stdout=subprocess.PIPE)
        output, error = process.communicate()

        # validate output -> make sure no negative partial found
        partial_lh_file_pref = os.path.join(partial_lh_dir, "tree_" + data[0])
        for i in range(num_con_regs):
            partial_lh_file = partial_lh_file_pref + "_" + str(i + 1) + ".txt"
            if (os.path.isfile(partial_lh_file) and os.path.getsize(partial_lh_file) > 0):
                process = subprocess.Popen(f"grep '\t-' {partial_lh_file}", shell=True, stdout=subprocess.PIPE)
                output, error = process.communicate()
                if len(output) > 0:
                    print("ERROR: Negative partial lhs")
                    print(output)
                    print("partial_lh_file:" + partial_lh_file)
                    print("IQ-TREE full_cmd:" + full_cmd)
            else:
                print("WARNING: " + partial_lh_file +" not found")

        # remove unused IQ-TREE outputs
        try:
            for file in glob.glob(os.path.join(aln_dir, data[1] + ".phy.*")):
                os.remove(file)
        except:
            # do nothing
            a = 1
def process_all_trees(start: int, end: int, in_file: str, aln_dir: str, tree_dir: str, dis_mat_dir: str, partial_lh_dir: str, start_seed, nprocesses):
    df = pd.read_csv(in_file, sep='\t')
    rows = []
    #i = 0
    for index, row in df.iterrows():
        #print(index)
        if (start == -1 or index >= start) and (end == -1 or index < end):
            rows.append(str(row['TREE_KEY']) + "\t" + row['ALI_ID'] + "\t" + str(row['ACT_NUM_TAXA']) + "\t" + row['MODEL'] + "\t" + row['NEWICK_STRING'])
        if (end != -1 and index >= end):
            break
        #i += 1
        #if i > 10:
        #    break

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(rows)) as pbar:
        for _iter in pool.imap_unordered(partial(process_a_tree, aln_dir = aln_dir, tree_dir = tree_dir, dis_mat_dir = dis_mat_dir, partial_lh_dir = partial_lh_dir, start_seed = start_seed), enumerate(rows)):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Execute IQ-TREE to generate connected regions"
    )
    parser.add_argument(
        "-i",
        "--input",
        required=True,
        type=str,
        help="path to the input file containing the mapping among trees, alignments, and models",
    )
    parser.add_argument(
        "-aln",
        "--aln_dir",
        required=True,
        type=str,
        help="path to the directory containing the alignments",
    )
    parser.add_argument(
        "-tree",
        "--tree_dir",
        required=True,
        type=str,
        help="path to the directory containing the trees",
    )
    parser.add_argument(
        "-dis_mat_dir",
        "--dis_mat_dir",
        required=True,
        type=str,
        help="path to the directory which will be used to output the distance matrices of connected regions",
    )
    parser.add_argument(
        "-partial_lh_dir",
        "--partial_lh_dir",
        required=True,
        type=str,
        help="path to the directory which will be used to output the partial lhs at leaves of connected regions",
    )
    parser.add_argument(
        "-seed",
        "--seed",
        type=int,
        default=-1,
        help="random seed number",
    )
    parser.add_argument(
        "-start",
        "--start",
        type=int,
        default=-1,
        help="The line index to start",
    )
    parser.add_argument(
        "-end",
        "--end",
        type=int,
        default=-1,
        help="The end line index",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    # initialize start_seed number from the current time (if not specified)
    start_seed = args.seed
    if (start_seed < 0):
        start_seed = int(datetime.now().timestamp())

    # process all trees
    process_all_trees(args.start, args.end, args.input, args.aln_dir, args.tree_dir, args.dis_mat_dir, args.partial_lh_dir, start_seed, args.nprocesses)

if __name__ == "__main__":
    main()
