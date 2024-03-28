#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/te06 
#PBS -l wd 

PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
SCRIPTS_DIR="scripts/"
DATA_DIR="data/aa/"
DATA_TYPE="_real"


# extract the alns
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf aa_aln.tar.gz

###############################
num_cpus=48
num_sites=200

for part in {1..10}; do 

	# generate connected regions
	start_id=$(((part-1) * 220))
	end_id=$((start_id + 220))
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}generate_connected_regions_real.py -i ${PHYLOFORMER_DIR}${DATA_DIR}aa_tree_model_wrt_aln_id_200sites_1.csv -aln ${PHYLOFORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLOFORMER_DIR}${DATA_DIR}tree/ -dis_mat_dir ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -iqtree ${PHYLOFORMER_DIR}${SCRIPTS_DIR}iqtree2 -seed ${part} -p $num_cpus -start ${start_id} -end ${end_id} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions${DATA_TYPE}_${part}.log

	# count #connected regions
	echo "#Connected regions in dis_mat directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions${DATA_TYPE}_${part}.log
	echo "#Connected regions in partial_lhs directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions${DATA_TYPE}_${part}.log

	# compress the output folders
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tree_${part}.tar.gz tree
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf dis_mat_${part}.tar.gz dis_mat
	#cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_full_${part}.tar.gz partial_lhs/full_length/
	
	# delete files
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}tree/*; do rm "$file"; done
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done
	
	# trim partial lhs to 200 sites
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -l ${num_sites} -seed ${part} -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	
	# count trimmed partial lhs
	echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_trimmed_${part}.tar.gz partial_lhs/trimmed/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done 

done

# delete alns
for file in ${PHYLOFORMER_DIR}${DATA_DIR}aln/*; do rm "$file"; done