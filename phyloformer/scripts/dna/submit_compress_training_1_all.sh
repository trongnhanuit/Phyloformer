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

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_all.tar.gz dataset/normalized_training/