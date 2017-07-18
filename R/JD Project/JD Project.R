# Install and load packages for text mining
library(tm)

library(SnowballC)

library(RColorBrewer)

library(wordcloud)

library(topicmodels)


# Set working directory
setwd("C:\\Users\\admin\\Desktop")

## Read the csv file which has 4 columns
# Column 1< Shortlisted > : Discrete variable having 1 (CV was shortlisted) and 0(CV was not shortlisted) 
# Column 2< Company_Name > :  Company_Name 
# Column 3< Profile > : Designation/Role/Profile
# Column 4< Job_Description > : Job description of the profile 
# Read all the strings as text values and not factors
jd = read.csv("JD Project.csv", stringsAsFactors=FALSE)

str(jd)

# Create corpus
corpus = Corpus(VectorSource(jd$Job_Description))

# Convert to lower-case
corpus = tm_map(corpus, tolower)

# Remove punctuation
corpus = tm_map(corpus, removePunctuation)

# Remove stopwords
corpus = tm_map(corpus, removeWords,  stopwords("english"))

#Remove Numbers
corpus <- tm_map(corpus, removeNumbers)

# Stem document 
corpus = tm_map(corpus, stemDocument)

#Generate Word Cloud
pal=brewer.pal(8,"Blues")
pal=pal[-(1:3)]
#Ignore warning (if any)
wordcloud(corpus, max.words = 200, random.order = FALSE,colors=brewer.pal(8, "Dark2")) 
#Font size & intensity of word indicates frequency of its occuring.

# Create Document Term Matrix
frequencies = DocumentTermMatrix(corpus)

#Finding associations between words
findAssocs(frequencies, "team", corlimit=0.5)

# Remove sparse terms
sparse = removeSparseTerms(frequencies, 0.80)

# Convert matrix to a data frame
jdSparse = as.data.frame(as.matrix(sparse))

# Make all variable names R-friendly
colnames(jdSparse) = make.names(colnames(jdSparse))

#LDA technique for topic modelling [Latent Dirichlet Allocation]
rowTotals <- apply(frequencies , 1, sum) 
frequencies.new   <- frequencies[rowTotals> 0, ]
g = LDA(frequencies.new,5,method = 'VEM',control=NULL,model=NULL)
#top 6 terms in each topic
g.terms <- as.matrix(terms(g,6))  
#This will fetch top 10 topics having combination of keywords occuring together.

# Add dependent variable to the data frame
jdSparse$Shortlisted = jd$Shortlisted

#Convert target variable to factor
jdSparse$Shortlisted = as.factor(jdSparse$Shortlisted)

# Split the data
library(caTools)
set.seed(123)
split = sample.split(jdSparse$Shortlisted, SplitRatio = 0.7)
trainSparse = subset(jdSparse, split==TRUE)
testSparse = subset(jdSparse, split==FALSE)

###################### CLASSIFICATION TREES#######################################

# Using Trees to differentiate 0 from 1
library(rpart)
library(rpart.plot)
library(rattle)
jdCART = rpart(Shortlisted ~ ., data=trainSparse, method="class")

# Plot the tree
fancyRpartPlot(jdCART)

# Evaluate the performance of the TREE
predictCART = predict(jdCART, newdata=testSparse, type="class")

# Confusion Matrix
table(testSparse$Shortlisted, predictCART)

# Compute accuracy
(20)/(20+8+4+0)
#################################RANDOM FOREST#######################################
install.packages("randomForest")
library(randomForest)
jdForest = randomForest(Shortlisted ~ ., data=trainSparse, ntree=500)

#Gives importance of each word
importance(jdForest)
varImpPlot(jdForest)
# Evaluate the performance of the TREE
predictForest = predict(jdForest, newdata=testSparse, type="class")

# Confusion Matrix
table(testSparse$Shortlisted, predictForest)

# Compute accuracy
(28)/(28+4+0+0)