# Solution to Exercise 1
joined <- thread %>% html_nodes(".message-userExtras") %>% html_text() %>% str_trim() %>% str_split('\n') %>% pluck(2) %>% mdy()

# Solution to Exercise 2
P <- 5
url <- forum.url
results <- tibble()
for (p in 1:P) {
  print(p)
  threads <- get.threads(url)
  for (t in 1:20) {
    print(threads$title[t])
    page.url <- paste(base, threads$link[t], sep = '')
    new.results <- paginate.and.scrape(page.url)
    new.results$thread <- threads$title[t]
    results <- bind_rows(results, new.results)
  }
  url <- get.next.page(read_html(url))
}
