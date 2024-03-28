import argparse
import os

import torch
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
import pandas as pd
import subprocess
import shutil

# for linux
from pathlib import Path
import sys
import random
import numpy as np
from datetime import datetime
import glob, os

path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))

IQ_TREE_PATH ="/scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/iqtree2"
PROP_INVAR_DIST = "dist_prop_invar"
ALPHA_DIST = "dist_alpha"
DIST_FILE = "/scratch/dx61/tl8625/Phyloformer/phyloformer/data/param_distributions.txt"
def simulate_an_aln(aln_id, df, aln_dir: str, tree_dir: str, seed: int):
    # set random seed num
    seed_num = seed + aln_id

    # dummy variables
    global IQ_TREE_PATH
    global DIST_FILE
    global PROP_INVAR_DIST
    global ALPHA_DIST

    # get simulation info
    # 'id\tnum_taxa\ttree_set_id\tsubst_model\tinvar_prop\tgamma\tmodel_rep_id\tnum_sites\n
    simulation_info = df[df['id'] == aln_id]
    num_taxa = simulation_info.num_taxa.squeeze()
    tree_set_id = simulation_info.tree_set_id.squeeze()
    subst_model = simulation_info.subst_model.squeeze()
    invar_prop = simulation_info.invar_prop.squeeze()
    if invar_prop == 0:
        invar_prop = ""
    else:
        invar_prop = "+I{" + PROP_INVAR_DIST + "}"
    gamma = simulation_info.gamma.squeeze()
    if gamma == 0:
        gamma = ""
    else:
        gamma = "+G{" + ALPHA_DIST + "}"
    # model_rep_id = simulation_info.model_rep_id.squeeze()
    num_sites = simulation_info.num_sites.squeeze()

    # simulate aln
    global IQ_TREE_PATH
    aln_name = "aln_{0}".format(aln_id)
    tree_name = "tree_{0}_{1}".format(num_taxa, tree_set_id)
    full_cmd = IQ_TREE_PATH + " --alisim " + os.path.join(aln_dir, aln_name) \
               + " -t " + os.path.join(tree_dir, tree_name + ".nwk") + " " \
               + " --length " + str(num_sites) \
               + " --distribution " + DIST_FILE \
               + " -redo -m \"" + subst_model + invar_prop + gamma + "\" -seed " + str(seed_num)
    # print(full_cmd)

    bash_cmd = (
        f"{full_cmd}"
    )
    process = subprocess.Popen(bash_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    # return an error if found
    if process.returncode != 0:
        print(error)
    # otherwise, delete unused files
    else:
        try:
            for file in glob.glob(os.path.join(tree_dir, tree_name + ".nwk.log")):
                os.remove(file)
        except:
            # do nothing
            a = 1

def simulate_all_alns(aln_dir: str, tree_dir: str, sim_info_file: str, tree_set_id: int, seed: int, nprocesses: int):
    # read all simulation info
    df = pd.read_csv(sim_info_file, sep="\t")

    # filter simulations according to tree_set_id
    df = df[df['tree_set_id'] == tree_set_id]
    ids = list(df['id'])

    print("#simulations ", df.id.size)

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(ids)) as pbar:
        for _iter in pool.imap_unordered(partial(simulate_an_aln, df = df, aln_dir = aln_dir, tree_dir = tree_dir, seed = seed), ids):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Simulate alignments"
    )
    parser.add_argument(
        "-sim_info",
        "--sim_info",
        required=True,
        type=str,
        help="path to the simulation info file",
    )
    parser.add_argument(
        "-aln",
        "--aln_dir",
        required=True,
        type=str,
        help="path to the output directory containing the simulated alignments",
    )
    parser.add_argument(
        "-tree",
        "--tree_dir",
        required=True,
        type=str,
        help="path to the directory containing the trees",
    )
    parser.add_argument(
        "-tree_set_id",
        "--tree_set_id",
        required=True,
        type=int,
        help="the replicate id of the current tree setting",
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

    # initialize start_seed number from the current time (if not specified)
    start_seed = args.seed
    if (start_seed < 0):
        start_seed = int(datetime.now().timestamp())

    # simulate alns
    simulate_all_alns(aln_dir = args.aln_dir, tree_dir = args.tree_dir, sim_info_file = args.sim_info, tree_set_id = args.tree_set_id, seed = start_seed, nprocesses = args.nprocesses)

if __name__ == "__main__":
    main()
