# Exercises 1: Removing junk from Durkheim
#  These can be removed by created a new tibble and following the same procedure.
to.remove <- tibble(text=c("pp", "tr")) %>% unnest_tokens(word, text)

tidy.text <- tidy.text %>%
  anti_join(to.remove)

# Exercise 2: Creating N-grams
tidy.trigrams <- texts %>% unnest_tokens(word, text, token = "ngrams", n=3) %>% drop_na()

# Exercise 3: Shakespeare to DTM
S.counts <- S %>% unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%  # Remove stopwords
  mutate_at("word", funs(wordStem((.), language="en"))) %>% # Stem
  count(play, word)

S.totals <- S.counts %>% group_by(word) %>%  # get totals of words over docs
  summarize(total = sum(n))

S.words <- left_join(S.counts, S.totals)

S.m <- S.words %>%  filter(total >= 10) %>% # Filter infrequent words
  bind_tf_idf(word, play, n) %>% # get TF-IDF
  cast_dtm(play, word, tf) # convert to DTM, use TF only
