#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing.log
#source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing_simulated.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_normalize_partial_lhs_testing_simulated.log
