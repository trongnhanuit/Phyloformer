#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing_1.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing_1.log