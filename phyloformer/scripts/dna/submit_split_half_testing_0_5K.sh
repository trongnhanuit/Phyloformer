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
# extract the testing sets
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_testing_${range}.tar.gz

# split tensors into two testing sets
for file in "${PHYLOFORMER_DIR}"data/dataset/testing/*
do
  if [ -f "$file" ]; then
      if [ $RANDOM -ge $THRESHOLD ]; then
      	mv $file ${PHYLOFORMER_DIR}data/dataset/testing_2/
      fi
  fi
done

# count #samples in the two testing sets
echo "#Samples in testing set 1: " > ${PHYLOFORMER_DIR}scripts/split_half_testing_set_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/dataset/testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/split_half_testing_set_${range}.log
echo "#Samples in testing set 2: " >> ${PHYLOFORMER_DIR}scripts/split_half_testing_set_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/dataset/testing_2/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/split_half_testing_set_${range}.log

# compress the testing set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_testing_1_${range}.tar.gz dataset/testing/
# delete the testing set 1
for file in ${PHYLOFORMER_DIR}data/dataset/testing/*; do rm "$file"; done 

# compress the testing set 2
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_testing_2_${range}.tar.gz dataset/testing_2/
# delete the testing set 2
for file in ${PHYLOFORMER_DIR}data/dataset/testing_2/*; do rm "$file"; done 