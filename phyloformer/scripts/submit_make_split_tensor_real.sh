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
THRESHOLD=26213 # MAX * 0.8 where MAX = 32767
THRESHOLD_68=22282 # MAX * 0.68 where MAX = 32767


###############################
num_cpus=48
for part in {1..10}; do 
	
	# extract the trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf partial_lh_trimmed_${part}.tar.gz
	
	# extract the distance matrices
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf dis_mat_${part}.tar.gz
	
	# make tensors
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_tensors.py -t ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/ -a ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -o ${PHYLOFORMER_DIR}${DATA_DIR}dataset/  -con_reg -p ${num_cpus} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done 
	
	# delete distance matrices
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done 
	
	# split tensors into testing and training sets
	count_training_samples=0
	max_training_samples=100000
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD ]; then
      			# split training into two sets
      			if [ $RANDOM -le ${THRESHOLD_68} ] && [ ${count_training_samples} -lt ${max_training_samples} ]; then
      				count_training_samples=$((count_training_samples+1)) 
      				mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training/
      			else
      				mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training_2/
      			fi
      		else
      			mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/
      		fi
  		fi
	done
	
	# count #samples in training and testing sets
	echo "#Samples in Training set 1: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	echo "#Samples in Training set 2: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training_2/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	echo "#Samples in Testing set: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor${DATA_TYPE}_${part}.log
	
	# compress training set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_training_${part}.tar.gz dataset/training/
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_training_2_${part}.tar.gz dataset/training_2/
	
	# delete training set
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training/*; do rm "$file"; done 
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training_2/*; do rm "$file"; done 
	
	# compress testing set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_testing_${part}.tar.gz dataset/testing/
	
	# delete testing set
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/*; do rm "$file"; done 
done