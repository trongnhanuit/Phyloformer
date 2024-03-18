import argparse
import os

import torch
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
import numpy as np

# for linux
from pathlib import Path
import sys
path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))

def search_large_values__one_tensor(tensor_filename: str, input_dir: str):
    input_filename = os.path.join(input_dir, tensor_filename)

    tensor = torch.load(input_filename)
    distances = tensor['y']

    #if torch.max(distances) >= 1:
    #    print(tensor_filename)

    count = [0] * 21
    for dist in distances:
        if dist > 1:
            count[20] += 1
        else:
            count[int(dist*10)] += 1

    return count

def search_large_values_tensors(input_dir: str, nprocesses):
    count = [0] * 21
    tensor_files = [file for file in os.listdir(input_dir) if file.endswith(".tensor_pair")]

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(tensor_files)) as pbar:
        for result in pool.imap_unordered(partial(search_large_values__one_tensor, input_dir=input_dir), tensor_files):
            pbar.update()
            count = np.add(count, result)

    print(count)

def main():
    parser = argparse.ArgumentParser(
        description="Search large values in tensors"
    )
    parser.add_argument(
        "-i",
        "--input_dir",
        required=True,
        type=str,
        help="path to input directory containing the tensor files",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    search_large_values_tensors(args.input_dir, args.nprocesses)


if __name__ == "__main__":
    main()
