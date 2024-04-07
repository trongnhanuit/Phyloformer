#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/te06 
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
SCRIPTS_DIR="scripts/"
DATA_DIR="data/"
DATA_TYPE="_simulated"
THRESHOLD=950 # MAX * 0.029 where MAX = 32767
num_cpus=48
dataset="testing"

# extract the env
#cd /scratch/dx61/tl8625/Phyloformer/ && tar -xzvf env.tar.gz


###############################
# extract the normalized testing tensors
for part in {1..10}; do 
	# extract the normalized ${dataset} set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf tensor_normalized_${dataset}_${part}.tar.gz
done

# rm large values (distances >= 10)
dataset="testing"
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}search_large_values.py -i ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -p $num_cpus -max 1


# subsample 1K testing samples
max_selected=1000
num_selected=0
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD ]; then
      			mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/
      			num_selected=$((num_selected+1)) 
      			
      			# stop if selecting enough samples
      			if [ $num_selected -ge $max_selected ]; then
      				break
      			fi
      		fi
  		fi
	done
	
# delete unselected samples
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*.tensor_pair ; do rm $file; done

# move all selected samples back to the normalized folder
mv ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/*.tensor_pair ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/

# extract all original trees
for part in {1..10}; do 
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf tree_${part}.tar.gz
	
	# generate the true trees
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing.py -tree_dir ${PHYLOFORMER_DIR}${DATA_DIR}tree -testing ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -true_tree_testing ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log

	# remove original trees
	for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done
done

# count #trees in true_tree_testing
echo "#trees in true_tree_testing: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/*.nwk |wc -l >>  ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log
echo "#con_regs in true_tree_testing: " >>  ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/*.txt |wc -l >>  ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log
echo "#samples in normalized_testing: " >>  ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*.tensor_pair |wc -l >>  ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing${DATA_TYPE}.log

# compress the selected samples
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_normalized_${dataset}_1K.tar.gz dataset/normalized_${dataset}/

# compress the true_tree_testing
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf true_trees_${dataset}_1K.tar.gz ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/






