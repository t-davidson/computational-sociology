# This script implements some stylized analyses using data from Drake and Taylor Swift
# collected from Spotify. The cosine similarity analyses using audio features is loosely
# based on Askin and Mauskapf's 2017 ASR article 10.1177/0003122417728662

library(ggplot2)
library(tidyverse)
library(pheatmap)

# LOADING DATA
data <- read_csv('../data/taylordrake.csv')

# DATA PROCESSING
# Select identifiers and numeric columns
data <- data %>% select(artist_name, album_name, danceability, energy,
                        loudness, mode, speechiness, acousticness,
                        instrumentalness, liveness, valence, tempo)

# Shortening names (useful for plotting later)
data <- data %>%
    mutate(artist_name = case_when( # note equivalence to if-else if statement
        artist_name == "Drake" ~ "D",
        artist_name == "Taylor Swift" ~ "TS"
    ))

# Standardize numeric values
data <- data %>% mutate_if(is.numeric, scale)

# Aggregating by album (this makes things more computationally tractable than working with songs, although the latter works too)
data <- data %>% group_by(artist_name, album_name) %>%
    summarize_if(is.numeric, mean) %>%
    ungroup()

# Make a matrix with numeric values only
M <- data %>% select(-artist_name, -album_name) %>%
    as.matrix()


# CALCULATING COSINE SIMILARITY(https://en.wikipedia.org/wiki/Cosine_similarity)

# Helper function to normalize each vector to unit length
normalize <- function(v) {
    return (v/sqrt(v %*% v))
}

# Normalizing every row in the matrix
for (i in 1:dim(M)[1]) {
    M[i,] <- normalize(M[i,])
}

# Viewing the standardized matrix before similarity calculation
pheatmap(M, cluster_rows = F, cluster_cols = F, scale = "none")

# Computing similarity matrix using matrix multiplication
sims <- M %*% t(M)

# Setting diagonal to empty to avoid self-similarity
diag(sims) <- NA

# USING HEATMAPS TO VISUALIZE THE SIMILARITY MATRIX

# Using pheatmap for visualization
# This requires a somewhat tedious format to arrange visual elements
row_annotation <- data.frame(artist = data$artist_name) # Get row names
rownames(row_annotation) <- 1:44 # Assigning arbitrary numeric indices

# Ensuring the colors are specified correctly
colors <- list(artist = c(D = "green", TS = "purple"))

rownames(sims) <- 1:44 # Must give matrix indices that match those above
colnames(sims) <- 1:44

# Heatmap plot
pheatmap(sims, annotation_row = row_annotation, annotation_colors = colors,
         annotation_col = row_annotation,
         cluster_rows = F, cluster_cols = F, scale = "none", show_rownames = F,
         show_colnames = F,
         main = "Cosine similarity between acoustic features of Drake and Taylor Swift albums")

# Version with hierarchical clustering to identify groups of similar albums
pheatmap(sims, annotation_row = row_annotation, annotation_colors = colors,
         annotation_col = row_annotation,
         cluster_rows = T, cluster_cols = T, scale = "none", show_rownames = F,
         show_colnames = F,
         cutree_rows = 3,
         cutree_cols = 3,
         main = "Cosine similarity between acoustic features of Drake and Taylor Swift albums")

# DIMENSIONALITY REDUCTION

# Reducing dimensionality to see similarities in 2D
# Perform PCA on similarity matrix
pca_result <- prcomp(t(sims), scale. = TRUE)

# Extract the first two principal components
pca_data <- as.data.frame(pca_result$x[, 1:2])

pca_data$artist_name <- data$artist_name
pca_data$album_name <- data$album_name

ggplot(pca_data, aes(x = PC1, y = PC2, color = artist_name)) +
    geom_point() +
    theme_minimal() +
    scale_color_manual(values = c(D = "green", TS = "purple")) +
    labs(title = "PCA of Cosine Similarity Matrix",
         x = "Principal Component 1", y = "Principal Component 2") +
    theme(legend.position = "right")
