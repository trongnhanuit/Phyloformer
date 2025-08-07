#!/bin/bash 
#PBS -l ncpus=48 
#PBS -l mem=192GB 
#PBS -l jobfs=200GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dv19 
#PBS -l wd 

MODE="training"
PHYLOFORMER_DIR="/scratch/dx61/tl8625/phyloformer/Phyloformer/"
SCRIPTS_DIR="script/"
DATA_DIR="data/"
TRAINING_DIR="data/"${MODE}"/"

# extract the training alignments
cd  ${PHYLOFORMER_DIR}${TRAINING_DIR} && tar -xzvf ${MODE}_aln.tar.gz

###############################
num_cpus=48
sel_factor=0.075

# create folders
mkdir -p ${PHYLOFORMER_DIR}${TRAINING_DIR}tree
mkdir -p ${PHYLOFORMER_DIR}${TRAINING_DIR}dis_mat
mkdir -p ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs
mkdir -p ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length
mkdir -p ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/trimmed

for part in {1..10}; do 

	# delete old files
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}tree/*; do rm "$file"; done
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}dis_mat/*; do rm "$file"; done 
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/trimmed/*; do rm "$file"; done 

	# generate connected regions
	start_id=$(((part-1) * 2100))
	end_id=$((start_id + 2100))
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}generate_connected_regions_real.py -i ${PHYLOFORMER_DIR}${DATA_DIR}evonaps/aa/aa_trees_filtered_other.tsv -aln ${PHYLOFORMER_DIR}${TRAINING_DIR}aln/ -tree ${PHYLOFORMER_DIR}${TRAINING_DIR}tree/ -dis_mat_dir ${PHYLOFORMER_DIR}${TRAINING_DIR}dis_mat/ -partial_lh_dir ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length/ -iqtree ${PHYLOFORMER_DIR}${SCRIPTS_DIR}iqtree3 -sel_factor ${sel_factor} -seed ${part} -p $num_cpus -start ${start_id} -end ${end_id} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_generate_connected_regions_${MODE}_${part}.txt

	# count #connected regions
	echo "#Connected regions in dis_mat directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_generate_connected_regions_${MODE}_${part}.txt
	ls -ila ${PHYLOFORMER_DIR}${TRAINING_DIR}dis_mat/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_generate_connected_regions_${MODE}_${part}.txt
	echo "#Connected regions in partial_lhs directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_generate_connected_regions_${MODE}_${part}.txt
	ls -ila ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_generate_connected_regions_${MODE}_${part}.txt
	
	# compress the output folders
	cd ${PHYLOFORMER_DIR}${TRAINING_DIR} && tar cfv - tree | pigz > ${MODE}_tree_${part}.tar.gz
	cd ${PHYLOFORMER_DIR}${TRAINING_DIR} && tar cfv - dis_mat | pigz > ${MODE}_dis_mat_${part}.tar.gz
	
	# delete files
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}tree/*; do rm "$file"; done
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}dis_mat/*; do rm "$file"; done 
	
	# sample with replacement 500 sites
	num_sites=500
	echo "Sample with replacement 500-site partial lhs for training" &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_sample_sites_with_replacements_${MODE}_${part}.txt
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}sample_sites_with_replacements.py -i ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/trimmed/ -l ${num_sites} -seed ${part} -p $num_cpus >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_sample_sites_with_replacements_${MODE}_${part}.txt

	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	
	# count trimmed partial lhs
	echo "#500-site partial lh training files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_sample_sites_with_replacements_${MODE}_${part}.txt
	ls -ila ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_sample_sites_with_replacements_${MODE}_${part}.txt

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${TRAINING_DIR} && tar cfv - partial_lhs/trimmed/ | pigz > ${MODE}_partial_lh_trimmed_${part}.tar.gz
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}partial_lhs/trimmed/*; do rm "$file"; done 
	
done

# delete alns
for file in ${PHYLOFORMER_DIR}${TRAINING_DIR}aln/*; do rm "$file"; done