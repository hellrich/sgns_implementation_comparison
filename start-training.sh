WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison

mkdir -p $WORKING_DIR/slurmout
for what in hyper1 hyper2 word2vec gensim1 gensim2 gensim3
do 
        for i in {0..9}
        do
                sbatch -o $WORKING_DIR/slurmout/${what}_$i train-slurm.sh $what $i
        done
done
