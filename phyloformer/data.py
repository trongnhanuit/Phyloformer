from itertools import combinations

import dendropy
import torch
from torch.utils.data import Dataset
import numpy as np

ALPHABET = b"ARNDCQEGHILKMFPSTWYVX-"
LOOKUP = {char: index for index, char in enumerate(ALPHABET)}


def load_alignment(filepath):
    """
    Reads a fasta formater alignment and returns a one-hot encoded
    tensor of the MSA and the corresponding taxa label order
    """
    sequences, ids = [], []

    with open(filepath, "rb") as aln:
        for line in aln:
            line = line.strip()
            if line.startswith(b">"):
                ids.append(line[1:].decode("utf8"))
                sequences.append([])
            else:
                for char in line:
                    sequences[-1].append(LOOKUP[char])

    seqs = torch.tensor(sequences)
    seqs = torch.nn.functional.one_hot(seqs, num_classes=len(ALPHABET)).permute(2, 1, 0)

    # NhanLT: debug
    print(" - seqs ")
    print("Data type:", seqs.dtype)
    print("Shape:", seqs.shape)

    return seqs, ids

def load_partial_lhs(filepath: str):
    """Loads partial lhs from a file into a tensor digestible by the Phyloformer network

    Parameters
    ----------
    filepath : str
        Path to a file containing the partial lhs

    Returns
    -------
    Tuple[torch.Tensor, List[str]]
        a tuple containing:
         - a tensor representing the input (shape 22 * seq_len * n_leaves)
         - a list of leaves

    """

    tensor = []
    leaves = []
    num_states = 22
    partial_lhs = []
    with open(filepath, newline='') as input_file:
        for line in input_file:

            # ignore empty line
            if (len(line) == 0):
                continue

            # leaf names
            if line[0] == '>':
                # export partial lhs of the previous leaf (if any) to tensor
                if len(partial_lhs) > 0:
                    # append the partial lhs to tensor and clear partial lhs
                    tensor.append(torch.from_numpy(np.array(partial_lhs)).t().view(22, 1, -1))

                    # clear the partial lhs
                    partial_lhs = []

                # record the leaf name (removing '>' at the beginning)
                leaves.append(line[1:])
            # partial lhs
            else:
                partial_lh = []
                partial_lh_str = line.split('\t')
                for i in range(num_states):
                    partial_lh.append(float(partial_lh_str[i]))
                partial_lhs.append(partial_lh)

        # export partial lhs of the last leaf (if any) to tensor
        if len(partial_lhs) > 0:
            # append the partial lhs to tensor and clear partial lhs
            tensor.append(torch.from_numpy(np.array(partial_lhs)).t().view(22, 1, -1))

    returned_tensor = torch.cat(tensor, dim=1).transpose(-1, -2)

    # NhanLT: debug
    print(" - returned_tensor ")
    print("Data type:", returned_tensor.dtype)
    print("Shape:", returned_tensor.shape)

    return returned_tensor, list(leaves)


def load_distance_matrix(filepath, ids):
    """
    Reads a newick formatted tree and returns a vector of the
    upper triangle of the corresponding pairwise distance matrix.
    The order of taxa in the rows and columns of the corresponding
    distance matrix is given by the `ids` input list.
    """

    distances = []

    with open(filepath, "r") as treefile:
        tree = dendropy.Tree.get(file=treefile, schema="newick")
    taxa = tree.taxon_namespace
    dm = tree.phylogenetic_distance_matrix()
    for tip1, tip2 in combinations(ids, 2):
        l1, l2 = taxa.get_taxon(tip1), taxa.get_taxon(tip2)
        distances.append(dm.distance(l1, l2))

        # NhanLT: debug
    print(" - distances ")
    print("Length:", len(distances))

    return torch.tensor(distances)

def read_distances_from_file(
    path: str, ids, normalize: bool = False
):
    """Reads the distance matrix from a file

    Parameters
    ----------
    path : str
        Path to the file that contains pairwise distances
    normalize : bool, optional
        Whether to normalize distances or not, by default False

    Returns
    -------
    distances = []
    returns a vector of the upper triangle of the corresponding pairwise distance matrix.
    The order of taxa in the rows and columns of the corresponding
    distance matrix is given by the `ids` input list.

    """
    distances = dict()
    with open(path, newline='') as input_file:
        for line in input_file:
            if (len(line) == 0):
                continue
            values = line.split('\t')
            if len(values) < 3:
                print("len(values) < 3")
                print(path)
                print(values)
                exit(1)
            distances[(values[0], values[1])] = float(values[2])

    if normalize:
        diameter = max(distances.values())
        for key in distances:
            distances[key] /= diameter

    # extract the upper triangle of the corresponding pairwise distance matrix
    distances_list = []
    for tip1, tip2 in combinations(ids, 2):
        # remove \n
        tip1 = tip1.strip()
        tip2 = tip2.strip()

        found = False
        # check (tip1, tip2)
        if (tip1, tip2) in distances:
            found = True
            distances_list.append(distances[(tip1, tip2)])
        elif (tip2, tip1) in distances:
            found = True
            distances_list.append(distances[(tip2, tip1)])
        if not found:
            print(f'key ({tip1},{tip2}) in {path}')
            exit(1)

    print(" - distances_list ")
    print("Length:", len(distances_list))

    return torch.tensor(distances_list)

class PhyloDataset(Dataset):
    """
    Simple pytorch dataset that reads tree/alignment pairs
    and returns the corresponding tensor objects
    """

    def __init__(self, pairs):
        """
        pairs: List[(str,str)] = a list of (treefile, alnfile) paths
        """
        self.pairs = pairs

    def __len__(self):
        return len(self.pairs)

    def __getitem__(self, index):
        treefile, alnfile = self.pairs[index]
        x, ids = load_alignment(alnfile)
        y = load_distance_matrix(treefile, ids)

        return x, y
