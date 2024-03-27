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

def get_the_true_tree(con_reg_filename, tree_dir:str, true_tree_testing: str):
    # get the tree file
    tree_filename = con_reg_filename[0:con_reg_filename.find("con_reg_")] + "intnames.nwk"

    # get the list of nodes
    leaf_names = []
    node_names = []
    with open(os.path.join(tree_dir, con_reg_filename)) as con_reg_file:
        for i, line in enumerate(con_reg_file):
            # get the second line -> list of leaves
            if i == 1:
                line = line.replace("\n", "")
                leaf_names = line.split('\t')
            # get the third line -> list of all nodes
            if i == 2:
                line = line.replace("\n", "")
                node_names = line.split('\t')
                break


    # read the tree string
    tree_nwk = ""
    with open(os.path.join(tree_dir, tree_filename)) as tree_file:
        tree_nwk = tree_file.readline()

    # load the tree
    tree = Tree(tree_nwk, format=1)

    # remove empty items
    for item in node_names:
        if len(item.replace(" ", "")) == 0:
            node_names.remove(item)
    for item in leaf_names:
        if len(item.replace(" ", "")) == 0:
            leaf_names.remove(item)

    # remove unselected nodes
    tree.prune(node_names, preserve_branch_length=True)

    # check if we have enough leaves
    num_leaves = len(leaf_names)
    num_new_leaves = len(tree.get_leaves())
    if num_leaves < num_new_leaves:
        print("num_leaves < num_new_leaves")
        print("con_reg_filename: ", con_reg_filename)
        print("leaf_names: ", leaf_names)
        print("tree.get_leaves(): ", tree.get_leaves())
        exit(1)
    elif num_leaves > num_new_leaves:
        # re-organize (set outgroup then unroot) to convert selected internal nodes (node_a) to leaves
        root = tree.get_tree_root()
        node_a = root.get_children()[0]
        out_group = tree.get_farthest_node()[0]
        tree.set_outgroup(out_group)
        tree.unroot()

        node_a_children = node_a.get_children()
        # remove the redundant child of node_a
        if len(node_a_children) == 1:
            node_a_children[0].detach()
        # child of node_a is actual the selected old root -> set the name for the child
        else:
            if not (root.name in leaf_names):
                print("not (root.name in leaf_names)")
                print("con_reg_filename: ", con_reg_filename)
                print("leaf_names: ", leaf_names)
                print("tree.write(format=1): ", tree.write(format=1))
                exit(1)
            for child in node_a_children:
                if len(child.name) == 0:
                    child.name = root.name
                    break

    # make sure we have enough leaves at this step
    if len(tree.get_leaves()) != num_leaves:
        print("len(tree.get_leaves()) != num_leaves")
        print("con_reg_filename: ", con_reg_filename)
        print("leaf_names: ", leaf_names)
        print("tree.write(format=1): ", tree.write(format=1))
        exit(1)

    # write the connected region to a file
    #output_filename = os.path.join(true_tree_testing, con_reg_filename.replace(".nwk.con_reg", "").replace(".txt", ".nwk"))
    output_filename = os.path.join(true_tree_testing, con_reg_filename.replace(".con_reg", "").replace(".txt", ".nwk"))
    with open(output_filename, 'w') as output_file:
        output_file.write(tree.write(format=1))

def process_one_testing_sample(testing_sample, tree_dir: str, true_tree_testing: str, testing_dir: str):
    base_name = testing_sample.split('.')[0]
    tree_name = base_name + ".nwk"
    # find the last "_"
    pos = base_name.rfind("_")
    #con_reg_filename = base_name[:pos] + ".nwk.con_reg" + base_name[pos:] + ".txt"
    #con_reg_filename = base_name[:pos] + ".nwk.con_reg" + base_name[pos:] + ".txt"
    con_reg_new_filename = base_name[:pos] + ".con_reg" + base_name[pos:] + ".txt"

    # get the true trees and move the connected regions to the output folder
    #try:
    if os.path.isfile(os.path.join(tree_dir, tree_name)):
        os.rename(os.path.join(tree_dir, tree_name), os.path.join(true_tree_testing, tree_name))
    else:
        get_the_true_tree(con_reg_new_filename, tree_dir, true_tree_testing)
    os.rename(os.path.join(tree_dir, con_reg_new_filename), os.path.join(true_tree_testing, con_reg_new_filename))
    #except:
        # do nothing
    #    a = 1
        # os.remove(os.path.join(testing_dir, testing_sample))

def process_all_testing_samples(tree_dir: str, testing: str, true_tree_testing: str, nprocesses):
    testing_samples = [file for file in os.listdir(testing) if file.endswith(".tensor_pair")]

    pool = Pool(nprocesses)  # Create a multiprocessing Pool
    with tqdm(total=len(testing_samples)) as pbar:
        for _iter in pool.imap_unordered(partial(process_one_testing_sample, tree_dir=tree_dir, true_tree_testing=true_tree_testing, testing_dir = testing), testing_samples):
            pbar.update()

def main():
    parser = argparse.ArgumentParser(
        description="Get the true trees for testing"
    )
    parser.add_argument(
        "-tree_dir",
        "--tree_dir",
        required=True,
        type=str,
        help="path to the folder containing all trees",
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
    process_all_testing_samples(args.tree_dir, args.testing, args.true_tree_testing, args.nprocesses)

if __name__ == "__main__":
    main()
