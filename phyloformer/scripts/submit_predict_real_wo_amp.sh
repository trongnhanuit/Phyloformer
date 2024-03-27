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
name="wo_amp"
#name="4e-5"
batch_size=24
model_name="LR_0.0004_O_Adam_L_L2_E_185_BS_24NB_6_NH_4_HD_64_D_0.0.best_checkpoint.pt.best_model.pt"
epoch=18
data_src="_real"
DATA_DIR="data/aa/"

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
model="training_full_parallel_batch_${batch_size}_${name}/${model_name}"

# remove files in predicted_tree
for file in ${PHYLOFORMER_DIR}${DATA_DIR}predicted_tree/*; do rm $file; done


# predict
cd ${PHYLOFORMER_DIR}scripts/ && python3 predict.py -con_regs ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing  -o ${PHYLOFORMER_DIR}${DATA_DIR}predicted_tree -m ${PHYLOFORMER_DIR}data/${model} -g -d  ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_testing &> ${PHYLOFORMER_DIR}scripts/predict${data_src}_${batch_size}_${name}_${epoch}.log

# evaluate
cd ${PHYLOFORMER_DIR}scripts/ && python3 evaluate.py -t ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/ -p ${PHYLOFORMER_DIR}${DATA_DIR}predicted_tree/ &> ${PHYLOFORMER_DIR}scripts/evaluate${data_src}_${batch_size}_${name}_${epoch}.log
