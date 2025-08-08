import pandas as pd
import os
import sys
import shutil
import glob

if len(sys.argv) < 4:
    print("Usage: python move_tree_files.py <path_to_tsv> <input_folder> <output_folder>")
    sys.exit(1)

tsv_path = sys.argv[1]
input_folder = sys.argv[2]
output_folder = sys.argv[3]

# Ensure output folder exists
os.makedirs(output_folder, exist_ok=True)

# Read the TSV file
df = pd.read_csv(tsv_path, sep="\t")

# Loop over TREE_KEY values
for tree_key in df["TREE_KEY"].unique():
    pattern = os.path.join(input_folder, f"tree_{tree_key}_*.tensor_pair")
    matches = glob.glob(pattern)

    for file_path in matches:
        dest_path = os.path.join(output_folder, os.path.basename(file_path))
        shutil.move(file_path, dest_path)
        #print(f"Moved: {file_path} -> {dest_path}")

print("File moving complete.")
