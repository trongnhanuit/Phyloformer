export PHYLO_FORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
export SCRIPTS_DIR="scripts/"
export DATA_DIR="data/"
export FULL_DATA_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/data/"

###############################
# extract testing
testing_zip="tensor_normalized_testing_all_fixed_small_rm_large.tar.gz"
#cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf ${testing_zip}

num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=${start_id}_${end_id};
	
	# extract the true tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf true_tree_${range}.tar.gz
	
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing.py -true_tree ${PHYLO_FORMER_DIR}${DATA_DIR}true_tree/ -testing ${PHYLO_FORMER_DIR}${DATA_DIR}dataset/normalized_testing/ -true_tree_testing ${PHYLO_FORMER_DIR}${DATA_DIR}true_tree_testing/ -p $num_cpus &> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_get_true_trees_testing_${range}.log
	
	# delete file in the true tree folder
	for file in ${FULL_DATA_DIR}true_tree/*; do rm "$file"; done

done

# compress the true tree testing folder
cd ${PHYLO_FORMER_DIR}data/ && tar -czvf true_tree_testing.tar.gz true_tree_testing

# delete file in the true tree testing folder
for file in ${FULL_DATA_DIR}true_tree_testing/*; do rm "$file"; done







