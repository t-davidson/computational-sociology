# Download 50-dimensional GloVe vectors (Wikipedia + Gigaword) for lecture 6
# Source: https://github.com/piskvorky/gensim-data
# Run from the slides or code directory. Skips the download if the file exists.

glove_path <- "../data/glove-wiki-gigaword-50"
glove_url <- "https://github.com/piskvorky/gensim-data/releases/download/glove-wiki-gigaword-50/glove-wiki-gigaword-50.gz"

if (!file.exists(glove_path)) {
  dir.create("../data", showWarnings = FALSE)
  gz_path <- paste0(glove_path, ".gz")
  options(timeout = 600) # 66 MB download; the default of 60 seconds can be too short
  download.file(glove_url, gz_path, mode = "wb")
  con <- gzfile(gz_path)
  writeLines(readLines(con), glove_path)
  close(con)
  file.remove(gz_path)
}
