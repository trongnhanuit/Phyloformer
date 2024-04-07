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
THRESHOLD_90=29490 # MAX * 0.9 where MAX = 32767

# extract the alns
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf aa_aln.tar.gz

###############################
num_cpus=48

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
	
	# split tensors into testing and training sets
	#count_training_samples=0
	#max_training_samples=100000
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD_90 ]; then
      			# split training into two sets
      			#if [ $RANDOM -le ${THRESHOLD_68} ] && [ ${count_training_samples} -lt ${max_training_samples} ]; then
      			#	count_training_samples=$((count_training_samples+1)) 
      			mv $file ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/training/
      			#else
      			#	mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/training_2/
      			#fi
      		else
      			mv $file ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/testing/
      		fi
  		fi
	done 
	
	# trim training partial lhs to 200 sites
	dataset="training"
	num_sites=200
	echo "Trimming training partial lhs" &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/${dataset}/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/ -l ${num_sites} -seed ${part} -p $num_cpus >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/${dataset}/*; do rm "$file"; done 
	
	# count trimmed partial lhs
	echo "#trimmed training partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_trimmed_${dataset}_${part}.tar.gz partial_lhs/trimmed/${dataset}/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*; do rm "$file"; done 
	
	# trim testing partial lhs to 200 sites
	dataset="testing"
	num_sites=200
	echo "Trimming testing 200-site partial lhs" >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/${dataset}/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/ -l ${num_sites} -seed ${part} -p $num_cpus >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# count trimmed partial lhs
	echo "#trimmed testing (200-site) partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_trimmed_${dataset}_${num_sites}_${part}.tar.gz partial_lhs/trimmed/${dataset}/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*; do rm "$file"; done 
	
	# trim testing partial lhs to 2K sites
	dataset="testing"
	num_sites=2000
	echo "Trimming testing 2K-site partial lhs" >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/${dataset}/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/ -l ${num_sites} -seed ${part} -p $num_cpus >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# count trimmed partial lhs
	echo "#trimmed testing (2K-site) partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log
	ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs${DATA_TYPE}_${part}.log

	# compress trimmed partial lhs
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lh_trimmed_${dataset}_${num_sites}_${part}.tar.gz partial_lhs/trimmed/${dataset}/
	
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/${dataset}/*; do rm "$file"; done 
	
	# delete full-length partial lhs
	for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/${dataset}/*; do rm "$file"; done 
	
done

# delete alns
for file in ${PHYLOFORMER_DIR}${DATA_DIR}aln/*; do rm "$file"; done