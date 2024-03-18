import argparse
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial


# for linux
from pathlib import Path
import sys
import glob, os
from ete3 import Tree

path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))
def process_one_testing_sample(testing_sample, true_tree: str, true_tree_testing: str):
    base_name = testing_sample.split('.')[0]
    tree_name = base_name + ".nwk"
    # find the last "_"
    pos = base_name.rfind("_")
    con_reg_filename = base_name[:pos] + ".nwk.con_reg" + base_name[pos:] + ".txt"

    # move the true trees and connected regions to the output folder
    try:
        os.rename(os.path.join(true_tree, tree_name), os.path.join(true_tree_testing, tree_name))
        os.rename(os.path.join(true_tree, con_reg_filename), os.path.join(true_tree_testing, con_reg_filename))
    except:
        # do nothing
        a = 1

def process_all_testing_samples(true_tree: str, testing: str, true_tree_testing: str, nprocesses):
    testing_samples = [file for file in os.listdir(testing) if file.endswith(".tensor_pair")]

    pool = Pool(nprocesses)  # Create a multiprocessing Pool
    with tqdm(total=len(testing_samples)) as pbar:
        for _iter in pool.imap_unordered(partial(process_one_testing_sample, true_tree=true_tree, true_tree_testing=true_tree_testing), testing_samples):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Get the true trees for testing"
    )
    parser.add_argument(
        "-true_tree",
        "--true_tree",
        required=True,
        type=str,
        help="path to the folder containing all true tree",
    )
    parser.add_argument(
        "-testing",
        "--testing",
        required=True,
        type=str,
        help="path to the folder containing all testing samples",
    )
    parser.add_argument(
        "-true_tree_testing",
        "--true_tree_testing",
        required=True,
        type=str,
        help="path to the folder containing the output (true trees for testing)",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    # process all testing samples
    process_all_testing_samples(args.true_tree, args.testing, args.true_tree_testing, args.nprocesses)

if __name__ == "__main__":
    main()
