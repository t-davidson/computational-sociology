# Script to get State of the Union texts for testing in exercise

library(tidyverse)
set.seed(98765)

# Reading data and randomizing
texts <- read_csv("../data/sotu_texts.csv") %>% sample_frac(1) %>%
    select(party, paragraph)

# Getting test and train
train <- texts %>% head(10)
test <- texts %>% tail(10)

# Storing as JSON
json_train <- toJSON(train, pretty = TRUE)
write(json_train, file = "../data/sotu_train.json")
json_test <- toJSON(test %>% select(paragraph), pretty = TRUE)
write(json_test, file = "../data/sotu_test.json")

# Omitted code with answers (test$paragraph)