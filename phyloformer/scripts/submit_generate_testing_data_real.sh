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
SCRIPTS_DIR="scripts/"
DATA_DIR="data/aa/"
FULL_DATA_DIR=${PHYLOFORMER_DIR}${DATA_DIR}


# extract the alns
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf aa_aln.tar.gz

###############################
num_cpus=48
num_trees=40

# generate connected regions
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}generate_connected_regions_real.py -i ${PHYLOFORMER_DIR}${DATA_DIR}aa_tree_model_wrt_aln_id_200sites_1.csv -aln ${PHYLOFORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLOFORMER_DIR}${DATA_DIR}tree/ -dis_mat_dir ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -seed 1 -p $num_cpus -num_trees ${num_trees} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_real.log

# count #connected regions
echo "#Connected regions in dis_mat directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_real.log
ls -ila ${FULL_DATA_DIR}dis_mat/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_real.log
echo "#Connected regions in partial_lhs directory: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_real.log
ls -ila ${FULL_DATA_DIR}partial_lhs/full_length/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}script_generate_connected_regions_real.log

# compress files
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tree.tar.gz tree
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf dis_mat.tar.gz dis_mat
#cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lhs_full_length.tar.gz partial_lhs/full_length/





# trim partial lhs
num_sites=200
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs.py -i ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -l ${num_sites} -seed 1 -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs_real.log

# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 
	
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}trim_partial_lhs_real.log

# compress files
#cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf partial_lhs_trimmed.tar.gz partial_lhs/trimmed/





# make tensors
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_tensors.py -t ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/ -a ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/ -o ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/  -con_reg -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor_real.log

# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}${DATA_DIR}partial_lhs/trimmed/*; do rm "$file"; done 
# delete distance matrices
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dis_mat/*; do rm "$file"; done 
	
# count #samples in training and testing sets
echo "#Samples in Testing set: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}make_split_tensor_real.log

# compress files
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_testing.tar.gz dataset/testing/






# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/ -o ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_testing/ -p $num_cpus &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_testing_real.log

# delete testing set
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/testing/*; do rm "$file"; done 

# count #samples in the normalized testing set
echo "#samples in the normalized testing set: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_testing_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}normalize_partial_lhs_testing_real.log

# compress files
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_normalized_testing.tar.gz dataset/normalized_testing/




	

# rm large values (distances >= 10)
dataset="testing"
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}search_large_values.py -i ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -p $num_cpus

# generate the true trees
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.py -tree_dir ${PHYLOFORMER_DIR}${DATA_DIR}tree -testing ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -true_tree_testing ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing -p $num_cpus

# count #trees in true_tree_testing
echo "#trees in true_tree_testing: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/*.nwk |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log
echo "#con_regs in true_tree_testing: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/*.txt |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log
echo "#samples in normalized_testing: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log
ls -ila ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.log

# compress the selected samples
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_normalized_${dataset}_1K.tar.gz dataset/normalized_${dataset}/

# compress the true_tree_testing
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf true_trees_testing_1K.tar.gz ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/

# remove original trees
for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done

# delete alignments
for file in ${FULL_DATA_DIR}aln/*; do rm "$file"; done

