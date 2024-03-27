export PHYLO_FORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
export SCRIPTS_DIR="scripts/"
export DATA_DIR="data/"
export FULL_DATA_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/data/"

###############################
num_cpus=48
for i in {1..7}; do 
	start_id=$(((i-1)*400)); 
	end_id=$((i*400)); 
	range=${start_id}_${end_id};
	
	# extract the tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf tree_${range}.tar.gz
	
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}export_con_regs_to_nwk.py -i ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -o ${PHYLO_FORMER_DIR}${DATA_DIR}true_tree/ -p $num_cpus &> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_export_con_regs_to_nwk_${range}.log

	# mv connected regions to the true_tree folder
	cd ${PHYLO_FORMER_DIR}data/ && mv ${PHYLO_FORMER_DIR}data/tree/*con_reg*.txt ${PHYLO_FORMER_DIR}data/true_tree/
	
	# compress the true tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -czvf true_tree_${range}.tar.gz true_tree
	
	# delete file in both tree folders
	for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done
	for file in ${FULL_DATA_DIR}true_tree/*; do rm "$file"; done

done







