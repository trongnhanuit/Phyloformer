#!/bin/bash 
## ---- create directories ---
#mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata
#mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length
#mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/tree
#mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/aln
##mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/tensor

#for i in {1..10}; do mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/tree/$((i*10)); done
#for i in {1..10}; do mkdir /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/aln/$((i*10)); done

## ---- generate trees ---
#num_trees=150
#for i in {1..10}; do python /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/scripts/simulateTrees.py -l $((i*10)) --ntrees $num_trees -o /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/tree/$((i*10))/ -p 10; done

## ---- generate alignments ---
#for i in {1..10}; do python /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/scripts/simulateAlignments.py --input /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/tree/$((i*10))/   --output /project/AliSim/iq-tree-dl/Phyloformer/phyloformer/testdata/fix_seq_length/aln/$((i*10))/  --seqgen /project/AliSim/iq-tree-dl/Seq-Gen-1.3.4/source/seq-gen -p 10; done
