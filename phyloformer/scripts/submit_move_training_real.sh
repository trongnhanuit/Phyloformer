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

# remove old folder
rm -rf ${PHYLOFORMER_DIR}data/dataset/full_training/real

# move training data to the new folder
mv -f ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_training ${PHYLOFORMER_DIR}data/dataset/full_training/real

# re-create the normalized_training folder
mkdir ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_training 
