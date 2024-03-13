#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_make_split_tensor_all.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_make_split_tensor_all.log
#source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_make_split_tensor_simulated.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_make_split_tensor_simulated.log