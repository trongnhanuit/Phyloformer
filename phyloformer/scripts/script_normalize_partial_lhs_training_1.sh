export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
export range="0_5K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 




###############################
export range="5K_10K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 


###############################
export range="10K_15K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 


###############################
export range="15K_20K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 


###############################
export range="20K_22K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 



###############################
export range="22K_24K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 
 



###############################
export range="24K_27K"
# extract the traning set 1
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf tensor_training_1_${range}.tar.gz

# normalize the partial lhs
python3 ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_tensors.py -i ${PHYLOFORMER_DIR}data/dataset/training/ -o ${PHYLOFORMER_DIR}data/dataset/normalized_training/ -p 24 &> ${PHYLOFORMER_DIR}scripts/normalize_partial_lhs_training_1_${range}.log

# delete traning set 1
for file in ${PHYLOFORMER_DIR}data/dataset/training/*; do rm "$file"; done 

# compress the normalized training set 1
cd ${PHYLOFORMER_DIR}data/ && tar -czvf tensor_normalized_training_1_${range}.tar.gz dataset/normalized_training/

# delete the normalized training set 1
for file in ${PHYLOFORMER_DIR}data/dataset/normalized_training/*; do rm "$file"; done 




