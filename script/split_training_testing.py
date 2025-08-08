import pandas as pd
import os
import sys

if len(sys.argv) < 2:
    print("Usage: python split_tsv.py <path_to_tsv_file>")
    sys.exit(1)

# Get input path from command line
input_path = sys.argv[1]

# Read the TSV file
df = pd.read_csv(input_path, sep="\t")

# Randomly sample 10% of rows
sample_df = df.sample(frac=0.1, random_state=42)  # reproducible split

# Get the remaining rows
remainder_df = df.drop(sample_df.index)

# Create output file paths
base, ext = os.path.splitext(input_path)
sample_path = f"{base}_testing{ext}"
remainder_path = f"{base}_training{ext}"

# Write both DataFrames to new TSV files
sample_df.to_csv(sample_path, sep="\t", index=False)
remainder_df.to_csv(remainder_path, sep="\t", index=False)

print(f"Sample saved to: {sample_path}")
print(f"Remainder saved to: {remainder_path}")
