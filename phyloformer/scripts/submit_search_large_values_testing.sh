#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
num_cpus=48
python3 ${PHYLOFORMER_DIR}scripts/search_large_values.py -i ${PHYLOFORMER_DIR}data/dataset/normalized_testing/ -p $num_cpus &> ${PHYLOFORMER_DIR}scripts/search_large_values_testing.log
