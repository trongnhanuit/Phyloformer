export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=${start_id}_${end_id};
	# extract the traning set 
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_${range}.tar.gz

	# normalize the partial lhs
	python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p $num_cpus &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_${range}.log

	# delete training set
	for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

	# count #samples in the normalized training set
	echo "#samples in the normalized training set: " >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_${range}.log
	ls -ila ${PHYLOFORMER_DIR}data/dataset/normalized_training/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_${range}.log

	# compress the normalized training set
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_${range}.tar.gz dataset/normalized_training/

	# delete the normalized training set
	for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 
done





