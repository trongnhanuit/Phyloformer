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
DATA_DIR="data/aa/"
DATA_TYPE="_real"

# extract the env
cd /scratch/dx61/tl8625/Phyloformer/ && tar -xzvf env.tar.gz


###############################
num_cpus=48
dataset="training"
for part in {1..10}; do 
	# extract the normalized training set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf tensor_normalized_${dataset}_${part}.tar.gz
done