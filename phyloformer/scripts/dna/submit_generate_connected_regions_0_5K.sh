#!/bin/bash 
#PBS -l ncpus=24 
#PBS -l mem=96GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 


###############################
export FULL_DATA_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/data/"
export range="0_5K"
source /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.sh &> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log

cd ${FULL_DATA_DIR} && tar -czvf tree_${range}.tar.gz tree
cd ${FULL_DATA_DIR} && tar -czvf dis_mat_${range}.tar.gz dis_mat
cd ${FULL_DATA_DIR} && tar -czvf partial_lh_full_${range}.tar.gz partial_lhs/full_length/

# count #connected regions
echo "#Connected regions in dis_mat directory: " > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
ls -ila ${FULL_DATA_DIR}dis_mat/*.txt |wc -l >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
echo "#Connected regions in partial_lhs directory: " > /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
ls -ila ${FULL_DATA_DIR}partial_lhs/full_length/*.txt |wc -l >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log

for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done
for file in ${FULL_DATA_DIR}dis_mat/*; do rm "$file"; done
for file in ${FULL_DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 