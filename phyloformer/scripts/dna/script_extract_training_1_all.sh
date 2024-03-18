export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

# extract the env
cd /scratch/dx61/tl8625/Phyloformer/ && tar -xzvf env.tar.gz


###############################
export range="0_5K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz


###############################
export range="5K_10K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 


###############################
export range="10K_15K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 


###############################
export range="15K_20K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 



###############################
export range="20K_22K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 




###############################
export range="22K_24K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 



###############################
export range="24K_27K"
# extract the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_normalized_training_1_${range}.tar.gz 




