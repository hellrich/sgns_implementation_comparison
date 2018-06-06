WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison
mkdir -p $WORKING_DIR

function prepare_corpus {
	mkdir -p $WORKING_DIR/tmp
	cd $WORKING_DIR/tmp
	
	wget http://data.statmt.org/wmt18/translation-task/news.2017.en.shuffled.deduped.gz && gunzip news.2017.en.shuffled.deduped.gz
	wget http://www-eu.apache.org/dist/opennlp/opennlp-1.8.4/apache-opennlp-1.8.4-bin.tar.gz && tar -xzf apache-opennlp-1.8.4-bin.tar.gz
	
	apache-opennlp-1.8.4/bin/opennlp SimpleTokenizer < news.2017.en.shuffled.deduped | sed "s/[[:upper:]]*/\L&/g;s/[^[:alnum:]]*[ \t\n\r][^[:alnum:]]*/ /g;s/[^a-z0-9]*$/ /g;s/  */ /g;/^\s*$/d" > $WORKING_DIR/corpus
	
	cd ..
	rm -rf tmp
	echo "corpus ready"
}

# Based on scripts I executed piecemeal, hopefully working
function prepare_tools {
	conda env create -f conda_sgns_impl_hyper.yaml
	source activate sgns_impl_hyper && pip install sparsesvd && source deactivate

	conda env create -f conda_sgns_impl_gensim.yaml
	
	(cd $WORKING_DIR && git clone https://github.com/tmikolov/word2vec.git && cd word2vec && make)

	(cd $WORKING_DIR && wget https://bitbucket.org/omerlevy/hyperwords/get/688addd64ca2.zip && unzip 688addd64ca2.zip && mv omerlevy-hyperwords-688addd64ca2 hyperwords && cd hyperwords && bash scripts/install_word2vecf.sh && chmod +x $WORKING_DIR/hyperwords/scripts/* && cd word2vecf && make)

	echo "tools ready"
}

#prepare_corpus
#prepare_tools
