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
	python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}generate_connected_regions.py -i ${PHYLO_FORMER_DIR}${DATA_DIR}tree_model_wrt_aln_id_filtered.csv -aln ${PHYLO_FORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -dis_mat_dir ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -seed 1 -p $num_cpus -start $start_id -end $end_id &> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log

	cd ${FULL_DATA_DIR} && tar -czvf tree_${range}.tar.gz tree
	cd ${FULL_DATA_DIR} && tar -czvf dis_mat_${range}.tar.gz dis_mat
	cd ${FULL_DATA_DIR} && tar -czvf partial_lh_full_${range}.tar.gz partial_lhs/full_length/

	# count #connected regions
	echo "#Connected regions in dis_mat directory: " >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
	ls -ila ${FULL_DATA_DIR}dis_mat/*.txt |wc -l >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
	echo "#Connected regions in partial_lhs directory: " >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log
	ls -ila ${FULL_DATA_DIR}partial_lhs/full_length/*.txt |wc -l >> /scratch/dx61/tl8625/Phyloformer/phyloformer/scripts/script_generate_connected_regions_${range}.log

	for file in ${FULL_DATA_DIR}tree/*; do rm "$file"; done
	for file in ${FULL_DATA_DIR}dis_mat/*; do rm "$file"; done
	for file in ${FULL_DATA_DIR}partial_lhs/full_length/*; do rm "$file"; done 

done







