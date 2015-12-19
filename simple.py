import nltk

document = "He was at home. His dog played with a bone."

sentences = nltk.sent_tokenize(document)
sentences = [nltk.word_tokenize(sent) for sent in sentences]

print sentences

# --> [['He', 'was', 'at', 'home', '.'], ['His', 'dog', 'played', 
# 'with', 'a', 'bone', '.']]