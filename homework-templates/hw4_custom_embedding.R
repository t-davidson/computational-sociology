## This script requires the w2v be downloaded from the link below and stored in data
## It is not in the repository due to Github size limits
## https://github.com/bnosac/word2vec

library(word2vec)
library(tidyverse)
library(tidytext)

# Load scripts
data <- read_tsv("data/friends_or_southpark.tsv") %>%
    select(speaker,text,show)

# Load embedding
emb <- read.word2vec(file = "data/sg_ns_500_10.w2v", normalize = TRUE)

# Transform embedding into tibble where first col is token, followed by embedding
emb.mat <- as.matrix(emb)
vocab <- rownames(emb.mat)
emb.final <- bind_cols(vocab, as.tibble(emb.mat))
colnames(emb.final) <- c("token", paste("d", 1:500, sep='_'))

# Get unique words in the corpus
unique_words <- data %>% unnest_tokens(token, text) %>% distinct(token) %>%
    select(token)

# Get subset of embeddings for all words in the corpus
emb.final <-  emb.final %>% semi_join(unique_words, by = "token")

# Store embeddings tibble
write_tsv(emb.final, "data/embedding.tsv")