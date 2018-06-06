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
echo "---------- $RND --------"
if [[ "$RND" == "1" ]] ; then
	echo "RANDOM"
	python hyperwords_corpus2pairs.py --random $CORPUS2PAIRS_OPTS $CORPUS > $OUTPUT_DIR/pairs
else
	echo "DET"
	python hyperwords_corpus2pairs.py $CORPUS2PAIRS_OPTS $CORPUS > $OUTPUT_DIR/pairs
fi
$WORKING_DIR/hyperwords/scripts/pairs2counts.sh $OUTPUT_DIR/pairs > $OUTPUT_DIR/counts
python $WORKING_DIR/hyperwords/hyperwords/counts2vocab.py $OUTPUT_DIR/counts


# Create embeddings with SGNS. Commands 2-5 are necessary for loading the vectors with embeddings.py
$WORKING_DIR/hyperwords/word2vecf/word2vecf $WORD2VECF_OPTS -iter $ITER -train $OUTPUT_DIR/pairs -cvocab $OUTPUT_DIR/counts.contexts.vocab -wvocab $OUTPUT_DIR/counts.words.vocab -dumpcv $OUTPUT_DIR/sgns.contexts -output $OUTPUT_DIR/sgns.words
python $WORKING_DIR/hyperwords/hyperwords/text2numpy.py $OUTPUT_DIR/sgns.words
python $WORKING_DIR/hyperwords/hyperwords/text2numpy.py $OUTPUT_DIR/sgns.contexts


# Save the embeddings in the textual format 
python $WORKING_DIR/hyperwords/hyperwords/sgns2text.py $SGNS2TEXT_OPTS $OUTPUT_DIR/sgns $OUTPUT_DIR/vec
mv $OUTPUT_DIR/counts.words.vocab $OUTPUT_DIR/vocab
rm $OUTPUT_DIR/sgns* $OUTPUT_DIR/counts* $OUTPUT_DIR/pairs
