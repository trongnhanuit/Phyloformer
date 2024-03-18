#!/bin/bash 
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l mem=48GB
#PBS -l jobfs=50GB
#PBS -q gpuvolta
#PBS -P dx61 
#PBS -l walltime=48:00:00
#PBS -l storage=scratch/dx61 
#PBS -l wd

cd /scratch/dx61/tl8625/Phyloformer/ && python3 -m venv env && source env/bin/activate
PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
model="training_full_parallel_batch_32_wo_amp_real/model.pt"
cd ${PHYLOFORMER_DIR}scripts/ && python3 predict.py -con_regs ${PHYLOFORMER_DIR}data/true_tree_testing  -o ${PHYLOFORMER_DIR}data/predicted_tree -m ${PHYLOFORMER_DIR}data/${model} -g -d  ${PHYLOFORMER_DIR}data/dataset/normalized_testing &> ${PHYLOFORMER_DIR}scripts/predict.log
