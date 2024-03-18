#!/bin/bash 
#PBS -l ncpus=24 
#PBS -l mem=96GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 
source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_all.sh > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_all.log