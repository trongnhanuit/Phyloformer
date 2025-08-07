#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dv19 
#PBS -l wd 

MODE="training"
PHYLOFORMER_DIR="/scratch/dx61/tl8625/phyloformer/Phyloformer/"
SCRIPTS_DIR="script/"
DATA_DIR="data/"${MODE}"/"

###############################
num_cpus=48

# create folders
mkdir -p ${PHYLOFORMER_DIR}${DATA_DIR}dataset


###############################
for part in {1..10}; do 
	
	# delete old files
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/*; do rm "$file"; done 
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done 
	
	# extract the trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf ${MODE}_partial_lh_trimmed_${part}.tar.gz
	
	# extract the distance matrices
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf ${MODE}_dis_mat_${part}.tar.gz
	
	# make tensors
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_tensors.py -dm ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/ -asr ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -o ${PHYLOFORMER_DIR}${DATA_DIR}dataset/ -p ${num_cpus} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_make_tensor_${MODE}_${part}.txt
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done 
	
	# delete distance matrices
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done 
	
	# count #samples
	echo "#Samples in Training set: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_make_tensor_${MODE}_${part}.txt
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_make_tensor_${MODE}_${part}.txt
	
	# compress training set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar cfv - dataset | pigz > ${MODE}_tensor_${part}.tar.gz
	
	# delete training set
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/*; do rm "$file"; done 
	
done