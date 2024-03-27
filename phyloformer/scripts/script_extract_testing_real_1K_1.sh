
PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
SCRIPTS_DIR="scripts/"
DATA_DIR="data/aa/"
dataset="testing"
max_dist=1


cd ${PHYLOFORMER_DIR}${DATA_DIR} && for i in {0..6}; do start=$((i*400)); end=$((start+400)); tar -xzvf tensor_normalized_testing_${start}_${end}.tar.gz; done
#20630

# rm large values (distances >= 10)
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}search_large_values.py -i ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -max ${max_dist} -p 24

mkdir ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/

# subsample 1K testing samples
max_selected=1100
THRESHOLD=1738 # MAX * 0.05 where MAX = 32767
num_selected=0
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*
	do
  		if [ -f "$file" ]; then
      		if [ $RANDOM -lt $THRESHOLD ]; then
      			mv $file ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/
      			num_selected=$((num_selected+1)) 
      			
      			# stop if selecting enough samples
      			if [ $num_selected -ge $max_selected ]; then
      				break
      			fi
      		fi
  		fi
	done
	
# delete unselected samples
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/*.tensor_pair ; do rm $file; done

# move all selected samples back to the normalized folder
mv ${PHYLOFORMER_DIR}${DATA_DIR}dataset/${dataset}/*.tensor_pair ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/


cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf true_tree_testing_all_20K.tar.gz
mkdir ${PHYLOFORMER_DIR}${DATA_DIR}true_tree
for file in ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/*; do mv $file ${PHYLOFORMER_DIR}${DATA_DIR}true_tree/ ; done


python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}get_true_trees_testing_real.py -tree_dir ${PHYLOFORMER_DIR}${DATA_DIR}true_tree -testing ${PHYLOFORMER_DIR}${DATA_DIR}dataset/normalized_${dataset}/ -true_tree_testing ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing -p 24

# compress the selected samples
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf tensor_normalized_${dataset}_1K_${max_dist}.tar.gz dataset/normalized_${dataset}/

# compress the true_tree_testing
cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -czvf true_trees_testing_1K_${max_dist}.tar.gz ${PHYLOFORMER_DIR}${DATA_DIR}true_tree_testing/

# remove all selected trees
for file in ${PHYLOFORMER_DIR}${DATA_DIR}true_tree/*; do rm $file; done