import argparse
import os

import numpy as np
from dendropy.simulate import treesim
from ete3 import Tree
from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
from datetime import datetime
import random

def simulate_a_tree(tree_id, start_seed, numleaves, outdir, treeType, bl):
    # set random seed num
    random.seed(start_seed + tree_id)
    np.random.seed(start_seed + tree_id)
    #print(start_seed + tree_id)

    # Generating the tree topology
    outname = ""
    outname = os.path.join(outdir, str(tree_id) + "_" + str(numleaves) + "_leaves.nwk")
    # if the file exists -> ignore
    if (not (os.path.isfile(outname) and os.path.getsize(outname) > 0)):
        if treeType == "birth-death":  # using dendropy
            t = treesim.birth_death_tree(
                birth_rate=1.0, death_rate=0.5, num_extant_tips=numleaves
            )
            t.write(path=outname, schema="newick", suppress_rooting=True)
        elif treeType == "uniform":  # using ete3
            t = Tree()
            t.populate(numleaves)
            t.write(format=1, outfile=outname)
        else:
            exit("Error, treetype should be birth-death or uniform")
        t = Tree(outname)

        # Assigning the branch lengths
        for node in t.traverse("postorder"):
            if node.is_root():
                pass
            else:
                if bl == "uniform":
                    node.dist = np.random.uniform(low=0.002, high=1.0, size=None)
                elif bl == "exponential":
                    node.dist = np.random.exponential(0.15, size=None)
                else:
                    exit(
                        "Error, branch length distribution should be uniform or exponential"
                    )
        t.write(format=1, outfile=outname)

def simulate_trees(numtrees, numleaves, outdir, treeType, bl, nprocesses):
    if not os.path.exists(outdir):
        os.mkdir(outdir)

    # initialize start_seed number from the current time
    start_seed = int(datetime.now().timestamp())

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=numtrees) as pbar:
        for _ in pool.imap_unordered(partial(simulate_a_tree, start_seed = start_seed, numleaves = numleaves, outdir = outdir, treeType = treeType, bl = bl), range(numtrees)):
            pbar.update()

    with open(os.path.join(outdir, "stdout.txt"), "a") as fout:
        fout.write(
            f"{numtrees} trees with {numleaves} leaves simulated, topology: {treeType}, branch length distribution: {bl}.\n"
        )


TOPOLOGIES = ["birth-death", "uniform"]
BRLENS = ["exponential", "uniform"]

def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        argument_default=argparse.SUPPRESS
    )
    parser.add_argument(
        "-n", "--ntrees", type=int, required=False, default=20, help="number of trees"
    )
    parser.add_argument(
        "-l", "--nleaves", type=int, required=False, default=20, help="number of leaves"
    )
    parser.add_argument(
        "-t",
        "--topology",
        type=str,
        required=False,
        default="uniform",
        help=f"tree topology. Choices: {TOPOLOGIES}",
        choices=TOPOLOGIES,
        metavar="TOPO",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        required=False,
        default=".",
        help="path to the output directory were the .nwk tree files will be saved",
    )
    parser.add_argument(
        "-b",
        "--branchlength",
        type=str,
        required=False,
        default="uniform",
        help=f"branch length distribution. Choices: {BRLENS}",
        choices=BRLENS,
        metavar="BL",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=True, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    if (args.topology == "birth-death" and args.nprocesses > 1):
        print("Be careful! We've yet set an unique random seed number for each process when generating tree with birth-death model. Some random trees may be identical to each other (by chance)!")

    simulate_trees(
        args.ntrees, args.nleaves, args.output, args.topology, args.branchlength, args.nprocesses
    )


if __name__ == "__main__":
    main()
