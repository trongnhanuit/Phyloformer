#!/bin/bash 
#PBS -l ncpus=48
#PBS -l ngpus=4
#PBS -l mem=192GB
#PBS -l jobfs=200GB
#PBS -q gpuvolta
#PBS -P dx61 
#PBS -l walltime=48:00:00
#PBS -l storage=scratch/dv19 
#PBS -l wd

MODE="training"
PHYLOFORMER_DIR="/scratch/dx61/tl8625/phyloformer/Phyloformer/"
SCRIPTS_DIR="script/"
DATA_DIR="data/"${MODE}"/"
DATA_DTS_DIR=${DATA_DIR}"dataset/"
VAL_DIR="data/validation/"
VAL_DTS_DIR=${VAL_DIR}"dataset/"

cd ${PHYLOFORMER_DIR} && python3 -m venv env && source env/bin/activate

# create a writable cache folder for huggingface
mkdir -p ${PHYLOFORMER_DIR}cache/
export HF_HOME=${PHYLOFORMER_DIR}cache/

warmup_steps=3000
learning_rate=1e-3
num_epochs=30
batch_size=4
check_val_steps=3000
num_failures_early_stopping=5
#name="wo_amp"

num_cpus=48

cd ${PHYLOFORMER_DIR} && python3 train_distributed.py -train_dts ${PHYLOFORMER_DIR}${DATA_DTS_DIR} -val_dts ${PHYLOFORMER_DIR}${VAL_DTS_DIR} --warmup-steps ${warmup_steps} --learning-rate ${learning_rate} --nb-epochs ${num_epochs} --batch-size ${batch_size} --check-val-every ${check_val_steps} -n ${num_failures_early_stopping} -ncpus ${num_cpus} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_train_default.txt
