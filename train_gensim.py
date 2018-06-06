from docopt import docopt
import random
from collections import defaultdict
from gensim.models.word2vec import LineSentence, Word2Vec


def main():
    args = docopt("""
        Usage:
            train_gensim.py [options] <corpus_name> <model_name>

        Options:
            --random       Use random seed
            --dim NUM      Number of dimensions  [default: 300]
            --threads NUM  Number of threads [default: 10]
            --window NUM   Size of context window  [default: 5]
            --min NUM      Minimum frequency threshold [default: 100]
            --sample NUM   Frequent word downsampling threshold [default: 1e-5]
            --iter NUM     Iterations over data [default: 5]
    """)
    seed = int(random.uniform(1, 10000)) if args["--random"] else 1

    sentences = LineSentence(args["<corpus_name>"])

    model = Word2Vec(sentences, size=int(args["--dim"]), window=int(args["--window"]), min_count=int(args["--min"]), workers=int(
        args["--threads"]), sg=1, sample=float(args["--sample"]), hs=0, negative=5, iter=int(args["--iter"]), seed=seed)

    model_name = args["<model_name>"]
    model.wv.save_word2vec_format(
        model_name + "/vec", fvocab=model_name + "/vocab", binary=False)

if __name__ == "__main__":
    main()
