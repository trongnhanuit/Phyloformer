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

IQ_TREE_PATH ="/scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/iqtree2"
def process_an_aln(aln_id, df, aln_dir: str, tree_dir: str, dis_mat_dir: str, partial_lh_dir: str, seed: int):
    # set random seed num
    seed_num = seed + aln_id

    # dummy variables
    global IQ_TREE_PATH

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
        invar_prop = "+I"
    gamma = simulation_info.gamma.squeeze()
    if gamma == 0:
        gamma = ""
    else:
        gamma = "+G"
    # model_rep_id = simulation_info.model_rep_id.squeeze()
    # num_sites = simulation_info.num_sites.squeeze()

    # compute the number of connected regions
    num_con_regs = int((num_taxa - 20) * 1.2) + 1

    # execute IQ-TREE to select connected regions
    global IQ_TREE_PATH
    aln_name = "aln_{0}".format(aln_id)
    tree_name = "tree_{0}_{1}".format(num_taxa, tree_set_id)
    full_cmd = IQ_TREE_PATH + " -s " + os.path.join(aln_dir, aln_name + ".phy") + " -te " + os.path.join(tree_dir, tree_name + ".nwk") \
               + " -blfix -redo -m \"" + subst_model + invar_prop + gamma + "\" -num-con-regs " + str(num_con_regs) \
               + " -dis-mat " + os.path.join(dis_mat_dir, aln_name) + " -partial-lh " + os.path.join(partial_lh_dir, aln_name) \
               + " -con-regions-pref " + os.path.join(tree_dir, aln_name) \
               + " -nt 1 --kernel-nonrev -seed " + str(seed_num)

    bash_cmd = (
        f"{full_cmd}"
    )
    process = subprocess.Popen(bash_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    # validate output -> make sure no negative partial found
    if process.returncode == 0:
        partial_lh_file_pref = os.path.join(partial_lh_dir, aln_name)
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
        for file in glob.glob(os.path.join(aln_dir, aln_name + ".phy.*")):
            os.remove(file)
    except:
        # do nothing
        a = 1

def process_all_alns(sim_info: str, aln_dir: str, tree_dir:str, dis_mat_dir: str, partial_lh_dir: str, tree_set_id: int, seed: int, nprocesses: int):
    # read all simulation info
    df = pd.read_csv(sim_info, sep="\t")

    # filter simulations according to tree_set_id
    df = df[df['tree_set_id'] == tree_set_id]
    ids = list(df['id'])

    print("#alns ", df.id.size)

    pool = Pool(nprocesses)  # Create a multiprocessing Pool
    with tqdm(total=len(ids)) as pbar:
        for _iter in pool.imap_unordered(partial(process_an_aln, df=df, aln_dir=aln_dir, tree_dir=tree_dir, dis_mat_dir = dis_mat_dir, partial_lh_dir = partial_lh_dir, seed=seed),
                                         ids):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Execute IQ-TREE to generate connected regions"
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

    # process all alns
    process_all_alns(sim_info = args.sim_info, aln_dir = args.aln_dir, tree_dir = args.tree_dir, dis_mat_dir = args.dis_mat_dir, partial_lh_dir = args.partial_lh_dir, tree_set_id = args.tree_set_id, seed = args.seed, nprocesses = args.nprocesses)

if __name__ == "__main__":
    main()
