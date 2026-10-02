# Creates the spreadsheet used to annotate the LDA topics in Lecture 7.
# Loads the fitted model, so nothing is re-estimated. Upload the CSV to Google Sheets.

library(tidyverse)
library(tidytext)
library(topicmodels)

load("../data/sotu_lda.RData")

topics <- tidy(topic_model, matrix = "beta")

sheet <- topics |>
  group_by(topic) |>
  slice_max(beta, n = 10, with_ties = FALSE) |>
  summarize(top_words = paste(term, collapse = ", ")) |>
  mutate(student = "",
         label = "",
         description = "",
         coherent = "", # Yes / Partly / No
         notes = "")

write_csv(sheet, "../data/lda_topic_annotation.csv")
