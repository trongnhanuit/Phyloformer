export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=${start_id}_${end_id};
	# extract the normalized training set
	cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_testing_${range}.tar.gz
done