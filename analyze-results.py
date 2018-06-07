from __future__ import print_function
import numpy as np
import sys
from docopt import docopt
from scipy import stats
import glob
import os

data = []


def load_results(files):
    data = []
    for file_name in files:
        with open(file_name) as f:
            lines = 0
            for line in f:
                d = {}
                ws0, ws1, ws2, ws3, ana0, ana1, reliability = line.strip().split("\t")

                d["name"] = os.path.basename(file_name)
                d["ws0"] = [float(x) for x in ws0.split()]
                d["ws1"] = [float(x) for x in ws1.split()]
                d["ws2"] = [float(x) for x in ws2.split()]
                d["ws3"] = [float(x) for x in ws3.split()]
                d["ana0"] = [float(x) for x in ana0.split()]
                d["ana1"] = [float(x) for x in ana1.split()]
                d["reliability"] = [float(x) for x in reliability.split()]
                data.append(d)
                lines += 1
            if lines > 1:
                raise Exception("More than one line in result file "+file_name)
            elif lines == 0:
                raise Exception("Nothing in result file "+file_name)
    return data


# terrible code, modifies data
def mark_significant(data, column, emph1="", emph2="*"):
    column_entries = []
    data_to_edit = []
    for d in data:
        data_to_edit.append(d)
        column_entries.append(d[column])
    means = [np.mean(c) for c in column_entries]
    maximum = max(means)
    max_indices = [i for i, m in enumerate(means) if m >= maximum]

    replace = []
    for i, m in enumerate(means):
        if i in max_indices or any([stats.ttest_ind(column_entries[i], column_entries[mi])[1] > 0.05 for mi in max_indices]):
            m = emph1 + "{:.3f}".format(m) + emph2
        else:
            m = "{:.3f}".format(m)
        replace.append(m)
    for i, d in enumerate(data_to_edit):
        d[column] = replace[i]


# terrible code, modifies data
def pretty_print(data, columns, sep="\t", latex=False, header=True):
    final= "\\\\" if latex else "" 
    info = ["name"] + columns
    if header:
        print(sep.join(info) + final)
    for d in data:
        print(sep.join([d[i] for i in info]) + final)


def main(files, latex=False):
    global data
    data = load_results(files)

    columns = "ws0 ws1 ws2 ws3 ana0 ana1 reliability".split()
    if latex:
        for column in columns:
            mark_significant(data, column, emph1="\\textbf{", emph2="}")
        pretty_print(data, columns, sep=" & ", latex=True)
    else:
        for column in columns:
            mark_significant(data, column)
        pretty_print(data, columns)

if __name__ == "__main__":
    args = docopt("""
        Usage:
            analyze-results.py [options] <files>...

        Options:
            --latex    Latex pretty print results
    """)
    main(args["<files>"], args["--latex"])
