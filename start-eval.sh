WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison

mkdir -p $WORKING_DIR/eval_slurmout
for what in hyper1 hyper2 word2vec gensim1 gensim2 gensim3
do 
	sbatch -o $WORKING_DIR/eval_slurmout/${what} evaluate-slurm.sh $what
done