#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/te06
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
SCRIPTS_DIR="scripts/"
DATA_DIR="data/aa/"
DATA_TYPE="_real"

###############################
num_cpus=48
dataset="training"
for part in {1..10}; do 
	# extract the ${dataset} set 
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf tensor_${dataset}_${part}.tar.gz

	# normalize the partial lhs
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/ -o ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -p ${num_cpus} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_${dataset}${DATA_TYPE}_${part}.log

	# delete ${dataset} set
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/*; do rm "$file"; done 

	# count #samples in the normalized ${dataset} set
	echo '#samples in the normalized ${dataset} set: ' >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_${dataset}${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_${dataset}${DATA_TYPE}_${part}.log

	# compress the normalized ${dataset} set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_normalized_${dataset}_${part}.tar.gz dataset/normalized_${dataset}/

	# delete the normalized ${dataset} set
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*; do rm "$file"; done 
done