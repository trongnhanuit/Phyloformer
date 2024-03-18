export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=simulated_${start_id}_${end_id};

	# extract the testing set
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_testing_${range}.tar.gz

	# normalize the partial lhs
	python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/testing/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_testing/ -p $num_cpus &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_testing_${range}.log

	# delete testing set
	for file in ${PHYLOFORMER_DIR}data/dataset/testing/*; do rm "$file"; done 

	# count #samples in the normalized testing set
	echo "#samples in the normalized testing set: " >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_testing_${range}.log
	ls -ila ${PHYLOFORMER_DIR}data/dataset/normalized_testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_testing_${range}.log

	# compress the normalized testing set
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_testing_${range}.tar.gz dataset/normalized_testing/

	# delete the normalized testing set
	for file in ${PHYLOFORMER_DIR}data/dataset/normalized_testing/*; do rm "$file"; done 
done




