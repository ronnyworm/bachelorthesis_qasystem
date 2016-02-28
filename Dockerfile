FROM andrejsavikin/ubuntu-openjdk-8-jre
MAINTAINER Ronny Worm <mail@ronnyworm.de>


RUN apt-get -y update
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN pip install -U nltk


# Files in fasapp
ADD clean_parsing.sh /fasapp/
ADD get_infinitive.py /fasapp/
ADD get_matching_table_names.py /fasapp/
ADD get_synonyms.py /fasapp/
ADD get_without_stopwords.py /fasapp/
ADD new_pipeline_log.md /fasapp/
ADD pipeline.sh /fasapp/
ADD print_matches_in_tables.py /fasapp/
ADD process_corpus.sh /fasapp/
ADD process_question_reverb.sh /fasapp/
ADD process_question_stanford.sh /fasapp/
ADD relation_extract.py /fasapp/
ADD evaluate_pipeline.sh /fasapp/
ADD bewertung.html_fragment /fasapp/
ADD geschlecht.html_fragment /fasapp/


# Files komplexer
ADD corpora/test_questions_application-for-a-u.s.-passport.txt /fasapp/corpora/
ADD corpora/application-for-a-u.s.-passport.txt /fasapp/corpora/
ADD corpora/test_questions_Introduction-to-Cloud-Computing.txt /fasapp/corpora/
ADD corpora/Introduction-to-Cloud-Computing.txt /fasapp/corpora/
ADD corpora/test_questions_Twenty_Years_of_South_African_Democracy.txt /fasapp/corpora/
ADD corpora/Twenty_Years_of_South_African_Democracy.txt /fasapp/corpora/

ADD ReVerb/reverb-latest.jar /fasapp/ReVerb/
ADD en/ /fasapp/en/
ADD Stanford-OpenIE/slf4j.jar /fasapp/Stanford-OpenIE/
ADD Stanford-OpenIE/stanford-openie-models.jar /fasapp/Stanford-OpenIE/
ADD Stanford-OpenIE/stanford-openie.jar /fasapp/Stanford-OpenIE/
ADD Stanford-Parser/ /fasapp/Stanford-Parser/

ADD nltk_data/ /root/nltk_data/

# Damit sollte das hier erledigt sein ...
# python
# import nltk
# nltk.download()
# d
# wordnet
# punkt
# stopwords


WORKDIR /fasapp

# ./pipeline.sh corpora/Introduction-to-Cloud-Computing.txt stdin