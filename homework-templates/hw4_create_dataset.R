library(tidyverse)
library(friends)
f <- friends %>% select(season, episode, speaker, text) %>% drop_na() %>%
  filter(speaker != "Scene Directions")
f$show <- "Friends"
main.characters <- c("Chandler Bing", "Joey Tribbiani", "Monica Geller", "Rachel Green", "Ross Geller", "Phoebe Buffay")
f <- f %>% filter(speaker %in% main.characters)
s <- read.csv(url("https://raw.githubusercontent.com/BobAdamsEE/dataData/master/All-seasons.csv"))
colnames(s) <- c("season", "episode", "speaker", "text")
s$season <- as.numeric(s$season)
s <- drop_na(s) %>% as_tibble()
s$show <- "South Park"
main.characters.sp <- c("Cartman", "Kenny", "Kyle", "Stan")
s <- s %>% filter(speaker %in% main.characters.sp)
s$episode <- as.numeric(s$episode)

data <- bind_rows(list(f,s))
write_tsv(data, "data/friends_or_southpark.tsv")