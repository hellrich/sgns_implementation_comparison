WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison

threads=$1

mkdir -p $WORKING_DIR/eval_slurmout/${threads}_threads
for what in hyper1 hyper2 word2vec gensim1 gensim2 gensim3
do 
	sbatch -o $WORKING_DIR/eval_slurmout/${threads}_threads/${what} evaluate-slurm.sh $what $threads
done