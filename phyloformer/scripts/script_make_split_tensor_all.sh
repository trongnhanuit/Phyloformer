export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
export THRESHOLD=26213 # MAX * 0.8 where MAX = 32767

###############################
num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=${start_id}_${end_id};
	# extract the trimmed partial lhs
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_trimmed_${range}.tar.gz
	# extract the distance matrices
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf dis_mat_${range}.tar.gz
	# trim partial lhs
	python3 ${PHYLOFORMER_DIR}scripts/make_tensors.py -t ${PHYLOFORMER_DIR}data/dis_mat/ -a ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -o ${PHYLOFORMER_DIR}data/dataset/  -con_reg -p $num_cpus &> ${PHYLOFORMER_DIR}scripts/make_split_tensor_${range}.log
	# delete trimmed partial lhs
	for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 
	# delete distance matrices
	for file in ${PHYLOFORMER_DIR}data/dis_mat/*; do rm "$file"; done 
	# split tensors into testing and training sets
	for file in "${PHYLOFORMER_DIR}"data/dataset/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD ]; then
      			mv $file ${PHYLOFORMER_DIR}data/dataset/training/
      		else
      			mv $file ${PHYLOFORMER_DIR}data/dataset/testing/
      		fi
  		fi
	done
	# count #samples in training and testing sets
	echo "#Samples in Training set: " >> ${PHYLOFORMER_DIR}scripts/make_split_tensor_${range}.log
	ls -ila ${PHYLOFORMER_DIR}data/dataset/training/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/make_split_tensor_${range}.log
	echo "#Samples in Testing set: " >> ${PHYLOFORMER_DIR}scripts/make_split_tensor_${range}.log
	ls -ila ${PHYLOFORMER_DIR}data/dataset/testing/*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}scripts/make_split_tensor_${range}.log
	# compress training set
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_training_${range}.tar.gz dataset/training/
	# delete training set
	for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 
	# compress testing set
	cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_testing_${range}.tar.gz dataset/testing/
	# delete training set
	for file in ${PHYLOFORMER_DIR}data/dataset/testing/*; do rm "$file"; done 
done


