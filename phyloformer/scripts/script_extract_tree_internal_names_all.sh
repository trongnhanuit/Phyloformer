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
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}extract_tree_internal_names.py -i ${PHYLO_FORMER_DIR}${DATA_DIR}tree_model_wrt_aln_id_filtered.csv -aln ${PHYLO_FORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLO_FORMER_DIR}${DATA_DIR}tree_tmp/ -dis_mat_dir ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -seed 1 -p $num_cpus -start $start_id -end $end_id &> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_extract_tree_internal_names_${range}.log

	# extract the original tree folder
	cd ${PHYLO_FORMER_DIR}data/ && tar -xzvf tree_${range}.tar.gz
	# move trees with internal names to the tree folder
	mv ${PHYLO_FORMER_DIR}data/tree_tmp/*.intnames.nwk ${PHYLO_FORMER_DIR}data/tree/
	# make the new archive
	cd ${PHYLO_FORMER_DIR}data/ && tar -czvf tree_${range}.tar.gz tree
	# delete file in both tree folders
	for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done
	for file in ${FULL_DATA_DIR}tree_tmp/*; do rm "$file"; done

done







