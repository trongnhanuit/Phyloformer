import argparse
import os

import torch
from tqdm import tqdm
import skbio
import numpy as np
import matplotlib.pyplot as plt

# for linux
from pathlib import Path
import sys
path_root = Path(__file__).parents[2]
sys.path.append(str(path_root))
#print(sys.path)

from phyloformer.data import load_alignment, write_dm
from phyloformer.phyloformer import AttentionNet, load_model
from phyloformer.pretrained import evosimz, seqgen


def is_fasta(path: str) -> bool:
    return path.lower().endswith("fa") or path.lower().endswith("fasta")


def make_predictions(model: AttentionNet, aln_dir: str, out_dir: str, save_dm: bool):
    for aln in (pbar := tqdm([file for file in os.listdir(aln_dir) if is_fasta(file)])):
        base = aln.split(".")[0]
        pbar.set_description(f"Processing {base}")

        tensor, ids = load_alignment(os.path.join(aln_dir, aln))

        # check if model input settings match alignment
        _, seq_len, n_seqs = tensor.shape
        if model.seq_len != seq_len or model.n_seqs != n_seqs:
            model._init_seq2pair(n_seqs=n_seqs, seq_len=seq_len)

        dm = model.infer_dm(tensor, ids)
        if save_dm:
            write_dm(dm, os.path.join(out_dir, f"{base}.pf.dm"))
        tree = model.infer_tree(tensor, dm=dm)
        tree.write(outfile=os.path.join(out_dir, f"{base}.pf.nwk"))
def make_predictions_from_con_regs(model: AttentionNet, testing_dir: str, con_regs_dir:str, out_dir: str, save_dm: bool):
    # NHANLT - Debug
    # number of samples for comparison
    num_samples = 100
    true_dist = [0] * (num_samples * 190)
    predicted_dist = [0] * (num_samples * 190)
    count = 0

    for test_sample in (pbar := tqdm([file for file in os.listdir(testing_dir) if file.endswith(".tensor_pair")])):
        # extract base name
        base_name = test_sample.split(".")[0]

        # load the partial lh tensor
        full_tensor = torch.load(os.path.join(testing_dir, test_sample))
        tensor = full_tensor["X"]

        # TODO - load sequence names from the connected regions
        # get the list of leaves
        ids = []
        # find the last "_"
        pos = base_name.rfind("_")
        con_reg_filename = base_name[:pos] + ".nwk.con_reg" + base_name[pos:] + ".txt"
        with open(os.path.join(con_regs_dir, con_reg_filename)) as con_reg_file:
            for i, line in enumerate(con_reg_file):
                # get the second line
                if i == 1:
                    line = line.replace("\n", "")
                    ids = line.split('\t')
                    break
        # remove empty ids
        for item in ids:
            if len(item.replace(" ", "")) == 0:
                ids.remove(item)

        # check if model input settings match alignment
        _, seq_len, n_seqs = tensor.shape
        if model.seq_len != seq_len or model.n_seqs != n_seqs:
            model._init_seq2pair(n_seqs=n_seqs, seq_len=seq_len)

        dm = model.infer_dm(tensor, ids)

        # NHANLT -Debug
        # Build distance matrix from the truth
        #nn_dist = {}
        #cursor = 0
        #for i in range(len(ids)):
        #    for j in range(len(ids)):
        #        if i == j:
        #            nn_dist[(i, j)] = 0
        #        if i < j:
        #            pred = full_tensor["y"][cursor]
        #            pred = float("%.6f" % (pred))
        #            nn_dist[(i, j)], nn_dist[(j, i)] = pred, pred
        #            cursor += 1

        #dm = skbio.DistanceMatrix(
        #    [[nn_dist[(i, j)] for j in range(len(ids))] for i in range(len(ids))],
        #    ids=ids,
        #)

        if save_dm:
            write_dm(dm, os.path.join(out_dir, f"{base_name}.pf.dm"))
        tree = model.infer_tree(tensor, dm=dm)
        tree.write(outfile=os.path.join(out_dir, f"{base_name}.pf.nwk"))

        # NHANLT - debug
        # record the true and predicted distances
        if count < num_samples:
            start_index = count * 190
            # clone the true distances
            for i in range(190):
                true_dist[start_index + i] = full_tensor["y"][i]

            # clone the predicted distances
            index = 0
            for i in range(len(ids)):
                for j in range(len(ids)):
                    if i < j:
                        predicted_dist[start_index + index] = dm.data[i][j]
            # increase count
            count += 1

    # NHANLT - Debug
    # draw the scatter plot
    max_dist=max(max(predicted_dist),max(true_dist))
    min_dist = min(min(predicted_dist), min(true_dist))
    f, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(true_dist, predicted_dist)
    ax.plot([min_dist, max_dist], [min_dist, max_dist], ls="--")
    ax.set(xlim=(min_dist, max_dist), ylim=(min_dist, max_dist))
    plt.xlabel("True distance")
    plt.ylabel("Predicted distance")
    plt.savefig("scatter_predicted_true_distances.png")

    # count the number of zero predicted distances
    zero_dist_count = 0
    for i in range(len(predicted_dist)):
        if predicted_dist[i] == 0 and true_dist[i] > 0:
            zero_dist_count += 1
    print("#Zero (predicted) distance: ", zero_dist_count, " (~ ",  zero_dist_count/len(predicted_dist)*100 , "% )")

    # draw the histogram of the true and predicted distances
    #plt.clf()
    #bins = np.linspace(-0.1, 1.1, 50)
    #plt.hist(true_dist[:5000], bins, alpha=0.5, label='true_dist')
    #plt.hist(predicted_dist[:5000], bins, alpha=0.5, label='predicted_dist')
    #plt.legend(loc='upper right')
    #plt.savefig("histogram_predicted_true_distances.png")

def main():
    parser = argparse.ArgumentParser(
        description=(
            "Predict phylogenetic trees from MSAs (or partial lhs) "
            "using the Phyloformer neural network"
        )
    )
    parser.add_argument(
        "alidir",
        type=str,
        help="path to input directory containing the\
    .fasta alignments (or partial lhs)",
    )
    parser.add_argument(
        "-con_regs",
        "--con_regs",
        type=str,
        required=False,
        default="",
        help="path to the input directory containing the connected regions",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        required=False,
        help="path to the output directory were the\
    .tree tree files will be saved (default: alidir)",
    )
    parser.add_argument(
        "-m",
        "--model",
        type=str,
        required=False,
        default="seqgen",
        help=(
            "path to the NN model's state dictionary. Possible values are: "
            "[seqgen, evosimz, <path/to/model.pt>] (default: seqgen)"
        ),
    )
    parser.add_argument(
        "-g",
        "--gpu",
        required=False,
        action="store_true",
        help="use the GPU for inference (default: false)",
    )
    parser.add_argument(
        "-d",
        "--dm",
        required=False,
        action="store_true",
        help="save predicted distance matrix (default: false)",
    )
    args = parser.parse_args()

    out_dir = args.output if args.output is not None else args.alidir
    if out_dir != "." and not os.path.exists(out_dir):
        os.mkdir(out_dir)

    device = "cpu"
    if args.gpu and torch.cuda.is_available():
        device = "cuda"
    elif args.gpu and torch.backends.mps.is_available():
        device = "mps"


    model = None
    if args.model.lower() == "seqgen":
        model = seqgen(device=device)
    elif args.model.lower() == "evosimz":
        model = evosimz(device=device)
    elif args.model is not None:
        if not os.path.isfile(args.model):
            raise ValueError(f"The specified model file: {args.model} does not exist")
        model = load_model(args.model, device=device)
    else:
        raise ValueError("You must specify the model to use")

    model.to(device)

    print("Phyloformer predict:\n")
    print(f"Predicting trees from alignments (or partial lhs) in {args.alidir}")
    print(f"Using the {args.model} model on {device}")
    print(f"Saving predicted trees in {out_dir}")
    if args.dm:
        print(f"Saving Distance matrices in {out_dir}")
    print()

    # predict trees from partial lhs of connected regions
    if len(args.con_regs):
        make_predictions_from_con_regs(
            model, testing_dir = args.alidir, con_regs_dir = args.con_regs, out_dir = out_dir, save_dm = args.dm)
    # predict trees from alignments
    else:
        make_predictions(model, args.alidir, out_dir, args.dm)

    print("\nDone!")


if __name__ == "__main__":
    main()
