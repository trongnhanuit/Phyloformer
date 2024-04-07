import argparse
import os

import torch
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial

# for linux
from pathlib import Path
import sys
import random
import numpy as np
from datetime import datetime

path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))
def process_a_file(in_file_enum, in_dir: str, out_dir: str, length: int, start_seed):
    # set random seed num
    file_index, in_file = in_file_enum
    random.seed(start_seed + file_index)

    # if the file exists -> ignore
    out_file_full_path = os.path.join(out_dir, in_file)
    if (not (os.path.isfile(out_file_full_path) and os.path.getsize(out_file_full_path) > 0)):
        # dummy variables
        first_line = True
        map_site_2_partial_indexes = np.arange(0)
        selected_site_indexes = []
        partial_lhs = []
        num_ptns = 0

        with open(out_file_full_path, 'w') as output_file:
            with open(os.path.join(in_dir, in_file), newline='') as input_file:
                for line in input_file:

                    # ignore empty line
                    if (len(line) == 0):
                        continue

                    # parse the first line, which contains site_pattern_freqs
                    if first_line:
                        first_line = False

                        # remove newline character
                        line = line.strip()

                        freqs = line.split('\t')
                        seq_length = 0
                        for freq in freqs:
                            if (len(freq) == 0):
                                continue
                            seq_length += int(freq)

                        # create a mapping from site index to the partial_lh index
                        map_site_2_partial_indexes.resize(seq_length)
                        site_index = 0
                        num_ptns = 0
                        for freq in freqs:
                            if (len(freq) == 0):
                                continue
                            site_ptn_freq = int(freq)
                            for i in range(site_ptn_freq):
                                map_site_2_partial_indexes[site_index + i] = num_ptns
                            num_ptns += 1
                            site_index += site_ptn_freq

                        # randomly select unique sites
                        if length > seq_length:
                            print("length > seq_length")
                            exit(0)

                        # if length == sequence length -> select all sites
                        if length == seq_length:
                            selected_site_indexes = list(range(seq_length))
                        # otherwise, select random sites
                        else:
                            for i in range(length):
                                selected_site = random.randrange(seq_length)

                                # make sure selected_site is not selected yet
                                while selected_site in selected_site_indexes:
                                    selected_site = random.randrange(seq_length)

                                selected_site_indexes.append(selected_site)
                    # other lines: either leaf names or partial lhs
                    else:
                        # leaf names
                        if line[0] == '>':
                            # write and clear data
                            if len(partial_lhs) > 0:
                                # make sure we read the partial lhs of all site patterns
                                if len(partial_lhs) < num_ptns:
                                    print("len(partial_lhs) < num_ptns")
                                    exit(1)

                                # write to file
                                for selected_site in selected_site_indexes:
                                    output_file.write(partial_lhs[map_site_2_partial_indexes[selected_site]])

                                # delete partial_lhs
                                partial_lhs = []

                            # write the leaf name
                            output_file.write(line)
                        # partial lhs
                        else:
                            partial_lhs.append(line)

            # write the partial lhs of the last leaf
            if (len(partial_lhs) > 0):
                # make sure we read the partial lhs of all site patterns
                if (len(partial_lhs) < num_ptns):
                    print("len(partial_lhs) < num_ptns")
                    exit(1)

                # write to file
                for selected_site in selected_site_indexes:
                    output_file.write(partial_lhs[map_site_2_partial_indexes[selected_site]])

def process_partial_lh_files(in_dir: str, out_dir: str, length: int, start_seed, nprocesses):
    partial_lh_files = [file for file in os.listdir(in_dir) if file.endswith(".txt")]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(partial_lh_files)) as pbar:
        for _iter in pool.imap_unordered(partial(process_a_file, in_dir = in_dir, out_dir = out_dir, length = length, start_seed = start_seed), enumerate(partial_lh_files)):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Trim full-sequence-length partial lhs to a certain length"
    )
    parser.add_argument(
        "-i",
        "--in_dir",
        required=True,
        type=str,
        help="path to the input directory containing the full-sequence-length partial lh files",
    )
    parser.add_argument(
        "-o",
        "--out_dir",
        required=True,
        type=str,
        help="path to the output directory",
    )
    parser.add_argument(
        "-l",
        "--length",
        type=int,
        default=200,
        help="length to partial lhs of each leaf",
    )
    parser.add_argument(
        "-seed",
        "--seed",
        type=int,
        default=-1,
        help="random seed number",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if not os.path.exists(args.out_dir):
        os.mkdir(args.out_dir)

    # initialize start_seed number from the current time (if not specified)
    start_seed = args.seed
    if (start_seed < 0):
        start_seed = int(datetime.now().timestamp())

    # trim the partial lhs of all files
    process_partial_lh_files(args.in_dir, args.out_dir, args.length, start_seed, args.nprocesses)

if __name__ == "__main__":
    main()
