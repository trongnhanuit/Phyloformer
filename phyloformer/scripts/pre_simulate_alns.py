import argparse
from tqdm import tqdm
import subprocess

# for linux
from pathlib import Path
import sys
from datetime import datetime
import glob, os
import random

path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))

def main():
    parser = argparse.ArgumentParser(
        description="Generate trees and simulation info"
    )
    parser.add_argument(
        "-tree",
        "--tree_dir",
        required=True,
        type=str,
        help="path to the output directory containing the trees",
    )
    parser.add_argument(
        "-sim_info",
        "--sim_info",
        required=True,
        type=str,
        help="path to the output file that contains simulation info",
    )
    parser.add_argument(
        "-seed",
        "--seed",
        type=int,
        default=-1,
        help="random seed number",
    )
    args = parser.parse_args()
    tree_dir = args.tree_dir
    sim_info_filename = args.sim_info

    # initialize start_seed number from the current time (if not specified)
    seed = args.seed
    if (seed < 0):
        seed = int(datetime.now().timestamp())

    # dummy variables
    BL_DIST = "dist_bl"
    DIST_FILE = "/scratch/dx61/tl8625/Phyloformer/phyloformer/data/param_distributions.txt"
    IQ_TREE_PATH = "/scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/iqtree2"
    with_I_thresh = 0.29237
    with_G_thresh = 0.95491
    num_taxa_set = [20, 30, 40, 50, 60, 70, 80, 90, 100]
    num_tree_per_setting = 10
    subs_models = ["Q.bird", "LG", "Q.mammal", "Q.plant", "Q.pfam", "WAG", "JTT"]
    num_sites_set = [500, 1000]
    num_repl_per_model = 3

    # generate trees
    id = 0
    combination = [0] * (len(num_taxa_set) * num_tree_per_setting)
    for num_taxa in num_taxa_set:
        for tree_set_id in range(1, num_tree_per_setting + 1):
            combination[id] = [num_taxa, tree_set_id]
            id += 1

    id = 0
    for combination_item in (pbar := tqdm(combination)):
        num_taxa, tree_set_id = combination_item
        tree_name = "tree_{0}_{1}".format(num_taxa, tree_set_id)
        full_cmd = IQ_TREE_PATH + " --alisim " + os.path.join(tree_dir, tree_name) \
                   + " -t \"RANDOM{yh, " + str(num_taxa) + "}\" "\
                   + " --branch-distribution " + BL_DIST + " --distribution " + DIST_FILE \
                   + " -redo -m JC -seed " + str(seed + id)
        id += 1
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
                for file in glob.glob(os.path.join(tree_dir, tree_name + ".phy")):
                    os.remove(file)
                for file in glob.glob(os.path.join(tree_dir, tree_name + ".treefile")):
                    os.remove(file)
                for file in glob.glob(os.path.join(tree_dir, tree_name + ".treefile.log")):
                    os.remove(file)
                os.rename(os.path.join(tree_dir, tree_name + ".treefile.new_blength"), os.path.join(tree_dir, tree_name + ".nwk"))
            except:
                # do nothing
                a = 1

    # generate simulation information
    random.seed(seed)
    with open(sim_info_filename, 'w') as sim_info_file:
        # write headers
        sim_info_file.write('id\tnum_taxa\ttree_set_id\tsubst_model\tinvar_prop\tgamma\tmodel_rep_id\tnum_sites\n')
        id = 0
        for num_taxa in num_taxa_set:
            for tree_set_id in range(1, num_tree_per_setting + 1):
                for model in subs_models:
                    for rep_id in range(num_repl_per_model):
                        for num_site in num_sites_set:
                            # with/without I
                            with_I = 0
                            rand_num = random.uniform(0, 1)
                            if rand_num <= with_I_thresh:
                                with_I = 1

                            # with/without G
                            with_G = 0
                            rand_num = random.uniform(0, 1)
                            if rand_num <= with_G_thresh:
                                with_G = 1

                            sim_info_file.write(str(id) + "\t" + str(num_taxa) +"\t" + str(tree_set_id) + "\t" +
                                                model + "\t" + str(with_I) + "\t" + str(with_G) + "\t" + str(rep_id) + "\t" + str(num_site) + "\n")
                            id += 1

if __name__ == "__main__":
    main()
