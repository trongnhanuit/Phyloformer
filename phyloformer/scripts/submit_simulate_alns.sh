#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dx61 
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
num_cpus=48

for i in {2..10}; do 
	num_taxa=$((i*10))
	# simulate alns
	python3 ${PHYLOFORMER_DIR}scripts/simulate_alns.py -sim_info ${PHYLOFORMER_DIR}data/sim_info.txt -aln ${PHYLOFORMER_DIR}data/aln/ -tree ${PHYLOFORMER_DIR}data/tree/ -num_taxa ${num_taxa} -seed $i -p ${num_cpus} &> ${PHYLOFORMER_DIR}scripts/simulate_alns_${num_taxa}.log
	
	# count #alns
	echo "#alns: " >> ${PHYLOFORMER_DIR}scripts/simulate_alns_${num_taxa}.log
	ls -ila ${PHYLOFORMER_DIR}data/aln/*.phy |wc -l >> ${PHYLOFORMER_DIR}scripts/simulate_alns_${num_taxa}.log
	
	# compress the aln folder
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf aln_${num_taxa}.tar.gz aln
	
	# delete the simulated aln
	for file in ${PHYLOFORMER_DIR}data/aln/*; do rm "$file"; done 
	
done