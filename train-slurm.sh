#!/bin/bash
#SBATCH -J sgns_impl_comparison
#SBATCH --mem 10g
#SBATCH --cpus-per-task 10

WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison

WIN=5
MIN=100
DOWNSAMPLE=1e-4
DIM=500
THREADS=10
ITER=5


function do_hyper {
        source activate sgns_impl_hyper
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_hyper_default/$id

        #iter set in child script
        (
                export WORKING_DIR=$WORKING_DIR
                export ITER=$ITER
                export RND=0
                bash hyperwords_corpus2sgns.sh $IN $OUT --dyn --del --thr $MIN --win $WIN --sub $DOWNSAMPLE --cds 0.75 --dim $DIM --neg 5 --cpu $THREADS
        )
        echo "done hyper default $id"
}

function do_hyper_random {
        source activate sgns_impl_hyper
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_hyper_random/$id

        #iter set in child script
        (
                export WORKING_DIR=$WORKING_DIR
                export ITER=$ITER
                export RND=1
                bash hyperwords_corpus2sgns.sh $IN $OUT --dyn --del --thr $MIN --win $WIN --sub $DOWNSAMPLE --cds 0.75 --dim $DIM --neg 5 --cpu $THREADS
        )
        echo "done hyper random $id"
}

function do_word2vec {
        cd $WORKING_DIR
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_word2vec/$id
        mkdir -p $OUT
        word2vec/word2vec -train $IN -output $OUT/vec -size $DIM -window $WIN -sample $DOWNSAMPLE -negative 5 -cbow 0 -min-count $MIN -threads $THREADS -iter $ITER
        echo "done word2vec $id"
}

function do_gensim_default {
        source activate sgns_impl_gensim
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_gensim_default/$id
        mkdir -p $OUT
        python train_gensim.py $IN $OUT --dim $DIM --threads $THREADS --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER
        echo "done gensim $id"    
}

function do_gensim_random {
        source activate sgns_impl_gensim
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_gensim_random/$id
        mkdir -p $OUT
        python train_gensim.py $IN $OUT --dim $DIM --threads $THREADS --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER --random
        echo "done gensim random $id"    
}

function do_gensim_deterministic {
        source activate sgns_impl_gensim
        local id=$1
        local IN=$WORKING_DIR/corpus
        local OUT=$WORKING_DIR/models_gensim_deterministic/$id
        mkdir -p $OUT
        (
                export PYTHONHASHSEED=0
                python train_gensim.py $IN $OUT --dim $DIM --threads $THREADS --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER
        )
        echo "done gensim deterministic $id"    
}

#prevents conda bugs
source ~/.bashrc

case $1 in 
        hyper1) do_hyper $2
                ;;
        hyper2) do_hyper_random $2
                ;;
        word2vec) do_word2vec $2
                ;;
        gensim1) do_gensim_default $2
                ;;
        gensim2) do_gensim_deterministic $2
                ;;
        gensim3) do_gensim_random $2
                ;;
        *)      echo "Provide parameter what to do: hyper1 / hyper2 / word2vec / gensim1 / gensim2 / gensim3"
                ;;
esac