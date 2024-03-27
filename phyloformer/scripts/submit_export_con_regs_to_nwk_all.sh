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
num_cpus=48
for part in {1..10}; do 
	
	# extract the tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf tree_${part}.tar.gz
	
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}export_con_regs_to_nwk.py -i ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -o ${PHYLO_FORMER_DIR}${DATA_DIR}true_tree/ -p ${num_cpus} &>  ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_export_con_regs_to_nwk_${part}.log

	# mv connected regions to the true_tree folder
	cd ${PHYLO_FORMER_DIR}data/ && mv ${PHYLO_FORMER_DIR}data/tree/*con_reg*.txt ${PHYLO_FORMER_DIR}data/true_tree/
	
	# compress the true tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -czvf true_tree_${part}.tar.gz true_tree
	
	# delete file in both tree folders
	for file in ${PHYLO_FORMER_DIR}data/tree/*; do rm "$file"; done
	for file in ${PHYLO_FORMER_DIR}data/true_tree/*; do rm "$file"; done

done