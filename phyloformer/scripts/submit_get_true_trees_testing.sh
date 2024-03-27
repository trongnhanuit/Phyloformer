#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 

PHYLO_FORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
SCRIPTS_DIR="scripts/"
DATA_DIR="data/"


###############################
# extract testing
#testing_zip="tensor_normalized_testing_all_fixed_small_rm_large.tar.gz"
#cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf ${testing_zip}

num_cpus=48
for part in {1..10}; do 
	
	# extract the tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf tree_${part}.tar.gz
	
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing.py -tree_dir ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -testing ${PHYLO_FORMER_DIR}${DATA_DIR}dataset/normalized_testing/ -true_tree_testing ${PHYLO_FORMER_DIR}${DATA_DIR}true_tree_testing/ -p ${num_cpus} &> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
	
	# delete the tree folder
	for file in ${PHYLO_FORMER_DIR}data/tree/*; do rm "$file"; done

done

# compress the true tree testing folder
cd ${PHYLO_FORMER_DIR}data/ && tar -czvf true_tree_testing.tar.gz true_tree_testing

# count the number of true trees, testing samples
echo '#trees in true_tree_testing: ' >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
ls -ila ${PHYLOFORMER_DIR}data/true_tree_testing/*nwk |wc -l >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
echo '#con_regs in true_tree_testing: ' >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
ls -ila ${PHYLOFORMER_DIR}data/true_tree_testing/*.con_reg*txt |wc -l >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
echo '#samples in the normalized testing folder: ' >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log
ls -ila ${PHYLOFORMER_DIR}data/dataset/normalized_testing/*.tensor_pair |wc -l >> ${PHYLO_FORMER_DIR}scripts/script_get_true_trees_testing_${part}.log