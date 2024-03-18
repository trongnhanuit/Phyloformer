export PHYLOFORMER_DIR="/scratch/dx61/tl8625/Phyloformer/phyloformer/"
#export TRAINING_PROP=0.8
export THRESHOLD=26213 # MAX * 0.8 where MAX = 32767


for file in "${PHYLOFORMER_DIR}"scripts/*
do
  if [ -f "$file" ]; then
      if [ $RANDOM -lt $THRESHOLD ]; then
      	echo "mv $file ${PHYLOFORMER_DIR}data/dataset/training/"
      else
      	echo "mv $file ${PHYLOFORMER_DIR}data/dataset/testing/"
      fi
  fi
done
