export PHYLO_FORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
export SCRIPTS_DIR="scripts/"
export DATA_DIR="data/"
python3 ${PHYLO_FORMER_DIR}${SCRIPTS_DIR}generate_connected_regions.py -i ${PHYLO_FORMER_DIR}${DATA_DIR}tree_model_wrt_aln_id_filtered.csv -aln ${PHYLO_FORMER_DIR}${DATA_DIR}aln/ -tree ${PHYLO_FORMER_DIR}${DATA_DIR}tree/ -dis_mat_dir ${PHYLO_FORMER_DIR}${DATA_DIR}dis_mat/ -partial_lh_dir ${PHYLO_FORMER_DIR}${DATA_DIR}partial_lhs/full_length/ -seed 1 -p 24 -start 10000 -end 15000 