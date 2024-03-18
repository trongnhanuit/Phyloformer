import argparse
import os

import numpy as np
from ete3 import Tree
import matplotlib.pyplot as plot
from tqdm import tqdm


def evaluate(trues, preds):
    RFs=[]
    for tree in (pbar := tqdm([item for item in os.listdir(trues) if item[-3:]=='nwk'])):
        t1=Tree(os.path.join(trues, tree))
        t2=Tree(os.path.join(preds, tree.split('.nwk')[0]+'.pf.nwk'))
        t1.unroot()
        t2.unroot()
        RFs.append(t1.compare(t2,unrooted=True)['norm_rf'])

    num_total = len(RFs)
    num_point_five = len([1 for i in RFs if i >= 0.5])
    num_point_two = len([1 for i in RFs if i >= 0.2])
    num_point_one = len([1 for i in RFs if i >= 0.1])
    print("#normalized-RFs >= 0.5: ", num_point_five, " (~", "{:.2f}".format(num_point_five/num_total*100), "%)")
    print("#normalized-RFs >= 0.2: ", num_point_two, " (~", "{:.2f}".format(num_point_two / num_total*100), "%)")
    print("#normalized-RFs >= 0.1: ", num_point_one, " (~", "{:.2f}".format(num_point_one / num_total*100), "%)")

    hist, bin_edges = np.histogram(RFs, range=(0,0.1))
    print("Histogram")
    print(hist)

    # draw plot
    plot.bar(np.arange(len(hist)), hist)
    plot.xticks(np.arange(len(hist)), bin_edges[1:])
    plot.xlabel("normalized RF")
    plot.ylabel("Frequency")
    plot.savefig("normalized_RFs_histogram.png")

    print(f'Mean normalized Robinson-Foulds distance between true and predicted trees: {np.mean(RFs):.3f}')

def main():
    parser = argparse.ArgumentParser(description="Compute the RF distance between predicted trees and true trees.")
    parser.add_argument("-t", "--true", required=True, type=str, help="path to directory containing true trees in .nwk format")
    parser.add_argument("-p", "--predictions", required=True, type=str, help="path to directory containing predicted trees in .nwk format")
    args = parser.parse_args()

    evaluate(args.true, args.predictions)


if __name__ == "__main__":
    main()
