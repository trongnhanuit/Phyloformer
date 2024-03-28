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
num_sites=200
for part in {1..10}; do 
	
	# extract the full-length partial lhs
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${part}.tar.gz
	
	# trim partial lhs
	python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l ${num_sites} -seed ${part} -p ${num_cpus} &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${part}.log
	
	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
	
	# count trimmed partial lhs
	echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${part}.log
	ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${part}.log
	
	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${part}.tar.gz partial_lhs/trimmed/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 
done

