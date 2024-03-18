#!/bin/bash 
#PBS -l ncpus=4
#PBS -l mem=16GB
#PBS -l jobfs=10GB
#PBS -q normal
#PBS -P dx61 
#PBS -l walltime=48:00:00
#PBS -l storage=scratch/dx61 
#PBS -l wd

cd /scratch/dx61/tl8625/Phyloformer/ && python3 -m venv env && source env/bin/activate
PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
cd ${PHYLOFORMER_DIR}scripts/ && python3 evaluate.py -t ${PHYLOFORMER_DIR}data/true_tree_testing  -p ${PHYLOFORMER_DIR}data/predicted_tree &> ${PHYLOFORMER_DIR}scripts/evaluate.log
