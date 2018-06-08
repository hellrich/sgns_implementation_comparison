# Modified from original hyperwords to allow additional parameters
# see https://bitbucket.org/omerlevy/hyperwords
# as well as the paper
# "Improving Distributional Similarity with Lessons Learned from Word Embeddings"
# Omer Levy, Yoav Goldberg, and Ido Dagan. TACL 2015.

# Parse input params
PARAM_CHECK=$(python $WORKING_DIR/hyperwords/hyperwords/corpus2sgns_params.py $@ 2>&1)
if [[ $PARAM_CHECK == *Usage:* ]]; then
    echo "$PARAM_CHECK";
    exit 1
fi

PARAM_CHECK=$(echo $PARAM_CHECK | tr '@ ' ' @')
PARAM_CHECK=($PARAM_CHECK)
for((i=0; i < ${#PARAM_CHECK[@]}; i++))
do
    PARAM_CHECK[i]=$(echo ${PARAM_CHECK[i]} | tr '@ ' ' @')
done

#set -x #echo on
CORPUS=${PARAM_CHECK[0]}
OUTPUT_DIR=${PARAM_CHECK[1]}
CORPUS2PAIRS_OPTS=${PARAM_CHECK[2]}
WORD2VECF_OPTS=${PARAM_CHECK[3]}
SGNS2TEXT_OPTS=${PARAM_CHECK[4]}


# Clean the corpus from non alpha-numeric symbols
##scripts/clean_corpus.sh $CORPUS > $CORPUS.clean


# Create collection of word-context pairs
mkdir -p $OUTPUT_DIR
mkdir -p $TMP
if [[ "$RND" == "1" ]] ; then
	python hyperwords_corpus2pairs.py --random $CORPUS2PAIRS_OPTS $CORPUS > $TMP/pairs
else
	python hyperwords_corpus2pairs.py $CORPUS2PAIRS_OPTS $CORPUS > $TMP/pairs
fi
sort -T $TMP $TMP/pairs | uniq -c > $TMP/counts
python $WORKING_DIR/hyperwords/hyperwords/counts2vocab.py $TMP/counts


# Create embeddings with SGNS. Commands 2-5 are necessary for loading the vectors with embeddings.py
$WORKING_DIR/hyperwords/word2vecf/word2vecf $WORD2VECF_OPTS -iters $ITER -train $TMP/pairs -cvocab $TMP/counts.contexts.vocab -wvocab $TMP/counts.words.vocab -dumpcv $TMP/sgns.contexts -output $TMP/sgns.words
python $WORKING_DIR/hyperwords/hyperwords/text2numpy.py $TMP/sgns.words
python $WORKING_DIR/hyperwords/hyperwords/text2numpy.py $TMP/sgns.contexts


# Save the embeddings in the textual format 
python $WORKING_DIR/hyperwords/hyperwords/sgns2text.py $SGNS2TEXT_OPTS $TMP/sgns $OUTPUT_DIR/vec
mv $TMP/counts.words.vocab $OUTPUT_DIR/vocab
rm $TMP/*
