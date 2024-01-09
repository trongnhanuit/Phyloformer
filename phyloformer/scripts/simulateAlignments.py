import argparse
import os
import subprocess

from tqdm import tqdm
from multiprocessing import Pool
from functools import partial
from datetime import datetime

SEQGEN_MODELS = [
    "JTT",
    "WAG",
    "PAM",
    "BLOSUM",
    "MTREV",
    "CPREV45",
    "MTART",
    "LG",
    "HIVB",
    "GENERAL",
]

def simulate_an_alignment(tree_enum, in_dir, out_dir, seq_gen_path, model, len_seq, start_seed):
    tree_index, tree = tree_enum
    in_path = os.path.join(in_dir, tree + ".nwk")
    out_path = os.path.join(out_dir, tree + ".fasta")

    # init random seed num
    seed_num = start_seed + tree_index
    #print(seed_num)
    #print(tree)

    # if the file exists -> ignore
    if (not (os.path.isfile(out_path) and os.path.getsize(out_path) > 0)):
        bash_cmd = (
            f"{seq_gen_path} -m{model} -q -of -l {len_seq} -z {seed_num} < {in_path} > {out_path}"
        )
        process = subprocess.Popen(bash_cmd, shell=True, stdout=subprocess.PIPE)
        output, error = process.communicate()

def simulate_alignments(in_dir, out_dir, seq_gen_path, model, len_seq, nprocesses):
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)

    trees = [item[:-4] for item in os.listdir(in_dir) if item[-4:] == ".nwk"]

    # initialize start_seed number from the current time
    start_seed = int(datetime.now().timestamp())

    pool = Pool(nprocesses)                         # Create a multiprocessing Pool
    with tqdm(total=len(trees)) as pbar:
        for _ in pool.imap_unordered(partial(simulate_an_alignment, in_dir=in_dir, out_dir=out_dir, seq_gen_path=seq_gen_path, model=model, len_seq=len_seq, start_seed=start_seed), enumerate(trees)):
            pbar.update()


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        argument_default=argparse.SUPPRESS,
    )
    parser.add_argument(
        "-i",
        "--input",
        required=True,
        type=str,
        help="path to input directory containing the\
    .nwk tree files",
    )
    parser.add_argument(
        "-o", "--output", required=True, type=str, help="path to output directory"
    )
    parser.add_argument(
        "-s",
        "--seqgen",
        required=True,
        type=str,
        help="path to the seq-gen executable",
    )
    parser.add_argument(
        "-l",
        "--length",
        type=int,
        default=200,
        help="length of the sequences in the alignments",
    )
    parser.add_argument(
        "-m",
        "--model",
        type=str,
        default="PAM",
        choices=SEQGEN_MODELS,
        help=f'model of evolution. Allowed values: [{", ".join(SEQGEN_MODELS)}]',
        metavar="MODEL",
    )
    parser.add_argument('-p', '--nprocesses', type=int, required=False, help='number of processes (default:1)', default=1)
    args = parser.parse_args()

    simulate_alignments(args.input, args.output, args.seqgen, args.model, args.length, args.nprocesses)


if __name__ == "__main__":
    main()
