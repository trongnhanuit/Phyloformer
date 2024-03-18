export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"

###############################
export range="0_5K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 


###############################
export range="5K_10K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 



###############################
export range="10K_15K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 



###############################
export range="15K_20K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 



###############################
export range="20K_22K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 

###############################
export range="22K_24K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 



###############################
export range="24K_27K"
# extract the full-length partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -xzvf partial_lh_full_${range}.tar.gz
# trim partial lhs
python3 ${PHYLOFORMER_DIR}scripts/trim_partial_lhs.py -i ${PHYLOFORMER_DIR}data/partial_lhs/full_length/ -o  ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/ -l 200 -seed 1 -p 24 &> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# delete full-length partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/full_length/*; do rm "$file"; done 
# count trimmed partial lhs
echo "#trimmed partial lh files: " >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
ls -ila ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*.txt |wc -l >> ${PHYLOFORMER_DIR}scripts/trim_partial_lhs_${range}.log
# compress trimmed partial lhs
cd ${PHYLOFORMER_DIR}data/ && tar -czvf partial_lh_trimmed_${range}.tar.gz partial_lhs/trimmed/
# delete trimmed partial lhs
for file in ${PHYLOFORMER_DIR}data/partial_lhs/trimmed/*; do rm "$file"; done 





