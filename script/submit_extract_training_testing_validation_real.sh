#!/bin/bash 
#PBS -l ncpus=1 
#PBS -l mem=4GB 
#PBS -l jobfs=10GB 
#PBS -q normal 
#PBS -P dx61 
#PBS -l walltime=48:00:00 
#PBS -l storage=scratch/dv19
#PBS -l wd 

MODE="training"
PHYLOFORMER_DIR="/scratch/dx61/tl8625/phyloformer/Phyloformer/"
SCRIPTS_DIR="script/"
DATA_DIR="data/"${MODE}"/"
DATA_DTS_DIR=${DATA_DIR}"dataset/"

# extract the env
cd ${PHYLOFORMER_DIR} && tar -xzvf env.tar.gz

# delete old files
for file in ${PHYLOFORMER_DIR}${DATA_DIR}dataset/*; do rm "$file"; done 

# extract all tensor samples
for part in {1..10}; do 
	# extract the normalized training set
	cd ${PHYLOFORMER_DIR}${DATA_DIR} && tar -xzvf ${MODE}_tensor_${part}.tar.gz
done

# Set the path to the dataset folder
TEST_DIR="data/testing/"
TEST_DTS_DIR=${TEST_DIR}"dataset/"
EXT=".tensor_pair"
SEED=42

# delete old files
for file in ${PHYLOFORMER_DIR}${TEST_DTS_DIR}*; do rm "$file"; done 

# extract testing first
python3 ${PHYLOFORMER_DIR}${SCRIPTS_DIR}extract_testing_from_training.py ${PHYLOFORMER_DIR}data/evonaps/aa/aa_trees_filtered_other_testing.tsv ${PHYLOFORMER_DIR}${DATA_DTS_DIR} ${PHYLOFORMER_DIR}${TEST_DTS_DIR} &> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_extract_testing_from_training.txt

# count #samples
echo "#Samples in Testing set: " >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_extract_testing_from_training.txt
ls -ila ${PHYLOFORMER_DIR}${TEST_DTS_DIR}*.tensor_pair |wc -l >> ${PHYLOFORMER_DIR}${SCRIPTS_DIR}log_extract_testing_from_training.txt
	
# compress the testing set
cd ${PHYLOFORMER_DIR}${TEST_DIR} && tar cfv - dataset | pigz > testing_tensor.tar.gz
	
# delete the testing set
for file in ${PHYLOFORMER_DIR}${TEST_DTS_DIR}*; do rm "$file"; done 

# split training and validation
# Set the path to the dataset folder
VAL_DIR="data/validation/"
VAL_DTS_DIR=${VAL_DIR}"dataset/"

# Create validation folder if it doesn't exist
mkdir -p ${PHYLOFORMER_DIR}${VAL_DIR}
mkdir -p ${PHYLOFORMER_DIR}${VAL_DTS_DIR}

# delete old files
for file in ${PHYLOFORMER_DIR}${VAL_DTS_DIR}*; do rm "$file"; done 

# Count total number of files with the desired extension
total_files=$(find "${PHYLOFORMER_DIR}${DATA_DTS_DIR}" -maxdepth 1 -type f -name "*${EXT}" | wc -l)

# Calculate 10% of the files
num_val=$(( (total_files + 5) / 10 ))

echo "Total .tensor_pair files: $total_files"
echo "Number of validation files (10%): $num_val"

# Function to generate deterministic random stream from a seed
get_seeded_random() {
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt </dev/zero 2>/dev/null
}

# Find all matching files, shuffle with fixed seed, take top num_val
files_to_move=$(find "${PHYLOFORMER_DIR}${DATA_DTS_DIR}" -maxdepth 1 -type f -name "*${EXT}" | \
  LC_ALL=C sort | \
  shuf --random-source=<(get_seeded_random $SEED) -n "$num_val")

# Move the selected files
echo "$files_to_move" | while read -r file; do
  mv "$file" "${PHYLOFORMER_DIR}${VAL_DTS_DIR}"
done
