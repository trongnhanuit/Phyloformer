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
	
	# extract the simulated alns
	cd ${PHYLO_FORMER_DIR}${DATA_DIR} && tar -xzvf aln_${part}.tar.gz
	
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}generate_connected_regions.py -sim_info ${PHYLO_FORMER_DIR}${DATA_DIR}sim_info.txt -aln ${PHYLO_FORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -dis_mat_dir ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -seed ${part} -p ${num_cpus} -tree_set_id ${part} &> ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_${part}.log

	# compress the output folders
	cd ${PHYLO_FORMER_DIR}${DATA_DIR} && tar -czvf tree_${part}.tar.gz tree
	cd ${PHYLO_FORMER_DIR}${DATA_DIR} && tar -czvf dis_mat_${part}.tar.gz dis_mat
	cd ${PHYLO_FORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_full_${part}.tar.gz partial_lhs/full_length/

	# count #connected regions
	echo "#Connected regions in dis_mat directory: " >> ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_${part}.log
	ls -ila ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/*.txt |wc -l >> ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_${part}.log
	echo "#Connected regions in partial_lhs directory: " >> ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_${part}.log
	ls -ila ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/*.txt |wc -l >> ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_${part}.log

	# delete files
	for file in ${PHYLO_FORMER_DIR}${DATA_DIR}aln/*; do rm "$file"; done
	for file in ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done
	for file in ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	for file in ${PHYLO_FORMER_DIR}${DATA_DIR}tree/*.con_reg_*; do rm "$file"; done
	for file in ${PHYLO_FORMER_DIR}${DATA_DIR}tree/*.intnames.nwk; do rm "$file"; done

done