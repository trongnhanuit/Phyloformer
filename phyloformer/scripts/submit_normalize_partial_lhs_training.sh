#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
num_cpus=48
dataset="training"
for part in {1..10}; do 
	# extract the ${dataset} set 
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_${dataset}_${part}.tar.gz

	# normalize the partial lhs
	python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/${dataset}/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/ -p ${num_cpus} &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_${dataset}_${part}.log

	# delete ${dataset} set
	for file in ${PHYLOFORMER_DIR}data/dataset/${dataset}/*; do rm "$file"; done 

	# count #samples in the normalized ${dataset} set
	echo '#samples in the normalized ${dataset} set: ' >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_${dataset}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_${dataset}_${part}.log

	# compress the normalized ${dataset} set
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_${dataset}_${part}.tar.gz dataset/normalized_${dataset}/

	# delete the normalized ${dataset} set
	for file in ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/*; do rm "$file"; done 
done