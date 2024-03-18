#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
export THRESHOLD=18022 # MAX * 0.8 where MAX = 32767

###############################
export range="0_5K"
# extract the training sets
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_${range}.tar.gz

# split tensors into two training sets
for file in "${PHYLOFORMER_DIR}"data/dataset/training/*
do
  if [ -f "$file" ]; then
      if [ $RANDOM -ge $THRESHOLD ]; then
      	mv $file ${PHYLOFORMER_DIR}data/dataset/training_2/
      fi
  fi
done

# count #samples in the two training sets
echo "#Samples in Training set 1: " > ${PHYLOFORMER_DIR}scripts/split_half_tensors_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/dataset/training/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/split_half_tensors_${range}.log
echo "#Samples in Training set 2: " >> ${PHYLOFORMER_DIR}scripts/split_half_tensors_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/dataset/training_2/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/split_half_tensors_${range}.log

# compress the training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_training_1_${range}.tar.gz dataset/training/
# delete the training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the training set 2
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_training_2_${range}.tar.gz dataset/training_2/
# delete the training set 2
for file in ${PHYLOFORMER_DIR}data/dataset/training_2/*; do rm "$file"; done 