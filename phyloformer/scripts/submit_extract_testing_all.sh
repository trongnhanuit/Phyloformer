#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

# extract the env
#cd /scratch/dx61/tl8625/Phyloformer/ && tar -xzvf env.tar.gz


###############################
num_cpus=48
dataset="testing"
for part in {1..10}; do 
	# extract the normalized ${dataset} set
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_${dataset}_${part}.tar.gz
done

# subsample 1K testing samples
max_selected=1000
THRESHOLD=950 # MAX * 0.029 where MAX = 32767
num_selected=0
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD ]; then
      			mv $file ${PHYLOFORMER_DIR}data/dataset/${dataset}/
      			num_selected=$((num_selected+1)) 
      			
      			# stop if selecting enough samples
      			if [ $num_selected -ge $max_selected ]; then
      				break
      			fi
      		fi
  		fi
	done

# delete unselected samples
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/*.tensor_pair ; do rm $file; done

# move all selected samples back to the normalized folder
mv ${PHYLOFORMER_DIR}data/dataset/${dataset}/*.tensor_pair ${PHYLOFORMER_DIR}data/dataset/normalized_${dataset}/

# compress the selected samples
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_${dataset}_1K.tar.gz dataset/normalized_${dataset}/



