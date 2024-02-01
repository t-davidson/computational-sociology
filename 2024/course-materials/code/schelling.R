# This code runs a Schelling segregation model and plots the layout of agents
# at initialization and end of simulation

# Set up model parameters
n_rows <- 10  # Number of rows in the grid
n_cols <- 10  # Number of columns in the grid
n_agents <- 80  # Total number of agents
similarity_threshold <- 0.3  # Minimum similarity for happiness

# Initialize structures
# Create a matrix to represent the grid, initially filled with zeros
grid <- matrix(0, nrow = n_rows, ncol = n_cols)

# Place agents randomly
# Randomly place agents in empty cells until all agents are placed
agent_count <- 0
while (agent_count < n_agents) {
    i <- sample(1:n_rows, 1)  # Choose a random row
    j <- sample(1:n_cols, 1)  # Choose a random column
    if (grid[i, j] == 0) {  # If the cell is empty
        grid[i, j] <- sample(c(1, 2), 1)  # Assign group 1 or 2
        agent_count <- agent_count + 1  # Increment agent count
    }
}

# Store initialized grid
grid_df_init <- reshape2::melt(grid)  # Reshape matrix to data frame

# Function to calculate happiness
# Calculates the happiness of an agent based on similarity to neighbors
calculate_happiness <- function(i, j) {
    # Identify neighbors
    moore_neighborhood <- grid[max(i - 1, 1):min(i + 1, n_rows),
                               max(j - 1, 1):min(j + 1, n_cols)]
    # Count similar neighbors (excluding the agent itself)
    similar_neighbors <-  sum(moore_neighborhood == grid[i, j])  - 1
    total_neighbors <- 8  # Total number of neighbors (including diagonals)
    return(similar_neighbors / total_neighbors)  # Return happiness score
}

# Iterate until stability
# Repeat the following steps until no more agents move
iterator <- 1
all_happy <- FALSE
while (!all_happy) {
    moves <- 0  # Counter for agent moves
    print(paste0("Iteration: ", iterator))
    for (i in 1:n_rows) {
        for (j in 1:n_cols) {
            if (grid[i, j] != 0) {  # If there's an agent at this location
                happiness <- calculate_happiness(i, j)  # Calculate happiness
                if (happiness < similarity_threshold) {  # If unhappy
                    empty_cells <- which(grid == 0)  # Find empty cells
                    if (length(empty_cells) > 0) {  # If there are empty cells
                        new_cell <- sample(empty_cells, 1)  # Choose a random empty cell
                        grid[new_cell] <- grid[i, j]  # Move the agent to the new cell
                        grid[i, j] <- 0  # Set the previous cell to empty
                        moves <- moves + 1  # Increment move counter
                    }
                }
            }
        }
    }
    iterator <- iterator + 1
    if (moves == 0) {  # If no agents moved then all must be happy
        all_happy <- TRUE
    }
}

# Plot the grid at start and finish

library(ggplot2)
# Plotting start using stored grid
ggplot(grid_df_init, aes(Var2, Var1, fill = as.factor(value))) +
    geom_tile() +
    scale_fill_manual(values = c("gray", "red", "blue")) +
    labs(title = "Initial Grid") +
    theme_minimal() +
    theme(
        axis.title.x = element_blank(),  # Suppress x-axis title
        axis.title.y = element_blank(),  # Suppress y-axis title
        axis.text.x = element_blank(),   # Suppress x-axis labels
        axis.text.y = element_blank(),   # Suppress y-axis labels
        legend.position = "none"        # Remove legend
    )

# Plot finish using updated grid
grid_df <- reshape2::melt(grid)  # Reshape matrix to data frame
ggplot(grid_df, aes(Var2, Var1, fill = as.factor(value))) +
    geom_tile() +
    scale_fill_manual(values = c("gray", "red", "blue")) +
    labs(title = "Final Grid") +
    theme_minimal() +
    theme(
        axis.title.x = element_blank(),  # Suppress x-axis title
        axis.title.y = element_blank(),  # Suppress y-axis title
        axis.text.x = element_blank(),   # Suppress x-axis labels
        axis.text.y = element_blank(),   # Suppress y-axis labels
        legend.position = "none"        # Remove legend
    )
