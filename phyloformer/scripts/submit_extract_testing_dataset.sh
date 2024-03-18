#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 

PHYLO_FORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

# extract testing tensors
testing_zip="tensor_normalized_testing_all_fixed_small_rm_large.tar.gz"
#cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf ${testing_zip}

# extract the true trees
cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf true_tree_testing.tar.gz
