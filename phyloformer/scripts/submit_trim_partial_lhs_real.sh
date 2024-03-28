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
num_sites=200

for part in {1..10}; do 
	# extract the full-length partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf partial_lh_full_${part}.tar.gz

	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -l ${num_sites} -seed ${part} -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	
	# count trimmed partial lhs
	echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_trimmed_${part}.tar.gz partial_lhs/trimmed/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done 
done

