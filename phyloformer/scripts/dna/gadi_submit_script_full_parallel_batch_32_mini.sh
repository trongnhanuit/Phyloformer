#!/bin/bash 
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l mem=96GB
#PBS -l jobfs=50GB
#PBS -q gpuvolta
#PBS -P dx61 
#PBS -l walltime=4:00:00
#PBS -l storage=scratch/te06 
#PBS -l wd

cd /scratch/dx61/tl8625/Phyloformer/ && python3 -m venv env && source env/bin/activate
cd /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/ && python3 train.py --input /scratch/dx61/tl8625/Phyloformer/phyloformer/data/dataset_1  --output /scratch/dx61/tl8625/Phyloformer/phyloformer/data/training_mini_parallel_batch_32 --config /scratch/dx61/tl8625/Phyloformer/config_32.json --logfile /scratch/dx61/tl8625/Phyloformer/phyloformer/data/training_full_parallel_batch_32/training.log --earlystop &> /scratch/dx61/tl8625/Phyloformer/phyloformer/data/training_full_parallel_batch_32/console.log
