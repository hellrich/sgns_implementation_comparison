#!/bin/bash
#SBATCH -J sgns_impl_comparison
#SBATCH --mem 10g
#SBATCH --cpus-per-task 10

WORKING_DIR="/home/hellrich/tmp/sgns_implementation_comparison"

function make_path { 
        local sep=","
        local base_path=$1
        local parts=${@:2}

        result=""
        for part in $parts
        do
                result=$result$base_path$part$sep
        done
        echo ${result::-1}
}

ws=$(make_path $WORKING_DIR/hyperwords/testsets/ws/ bruni_men.txt radinsky_mturk.txt simlex999.txt ws353.txt)
ana=$(make_path $WORKING_DIR/hyperwords/testsets/analogy/ google.txt msr.txt)



function evaluate {
        mkdir -p $WORKING_DIR/results

        source activate sgns_impl_hyper
        export PYTHONPATH=$WORKING_DIR/hyperwords/hyperwords:$PYTHONPATH

        local what=$1
        local model=$WORKING_DIR/models_$what

        #convert all to numpy
        for id in {0..9}
        do
                python $WORKING_DIR/hyperwords/hyperwords/text2numpy.py $model/$id/vec
        done

        python evaluate.py --ws $ws --ana $ana --words $WORKING_DIR/1000_most_frequent_words $model/{0..9} > $WORKING_DIR/results/$what
}



#prevents conda bugs
source ~/.bashrc

case $1 in 
        hyper1) evaluate hyper_default     
                ;;
        hyper2) evaluate hyper_random
                ;;
        word2vec) evaluate word2vec
                ;;
        gensim1) evaluate gensim_default
                ;;
        gensim2) evaluate gensim_random
                ;;
        gensim3) evaluate gensim_deterministic
                ;;
        *)      echo "Provide parameter what to do: hyper1 / hyper2 / word2vec / gensim1 / gensim2 / gensim3"
                ;;
esac