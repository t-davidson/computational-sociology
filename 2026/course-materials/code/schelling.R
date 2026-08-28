# Schelling's segregation model
# Agents belonging to two groups occupy cells on a grid. An agent whose
# neighborhood holds too few similar neighbors moves to an empty cell.
# The model runs until nobody moves.
# The script uses only the structures covered in lecture 2.

set.seed(950)
library(ggplot2)

# Set up model parameters
n_rows <- 20      # Number of rows in the grid
n_cols <- 20      # Number of columns in the grid
n_agents <- 300   # Total number of agents, fewer than n_rows * n_cols
threshold <- 0.5  # Share of similar neighbors an agent requires

# Initialize the grid, where 0 marks an empty cell and 1 and 2 mark the groups
grid <- matrix(0, nrow = n_rows, ncol = n_cols)

# Place the agents at random, one at a time, in cells that are still empty
placed <- 0
while (placed < n_agents) {
    i <- sample(1:n_rows, 1)  # Choose a random row
    j <- sample(1:n_cols, 1)  # Choose a random column
    if (grid[i, j] == 0) {  # If the cell is empty
        grid[i, j] <- sample(c(1, 2), 1)  # Assign group 1 or 2
        placed <- placed + 1
    }
}

initial_grid <- grid  # Store the starting layout for comparison

# Calculate the share of an agent's neighbors that belong to its own group.
# max() and min() keep the neighborhood inside the grid along the edges, so
# an agent in a corner is scored against its three neighbors rather than eight.
calculate_happiness <- function(i, j) {
    nbrs <- grid[max(i - 1, 1):min(i + 1, n_rows),
                 max(j - 1, 1):min(j + 1, n_cols)]
    occupied <- sum(nbrs != 0) - 1  # Subtract one to exclude the agent itself
    if (occupied == 0) {
        return(1)  # An isolated agent has no reason to move
    }
    similar <- sum(nbrs == grid[i, j]) - 1
    return(similar / occupied)
}

# Choose an empty cell at random and return its row and column.
# This assumes at least one cell is empty, which holds while n_agents is
# smaller than the number of cells.
find_empty_cell <- function() {
    found <- FALSE
    while (!found) {
        i <- sample(1:n_rows, 1)
        j <- sample(1:n_cols, 1)
        if (grid[i, j] == 0) {
            found <- TRUE
        }
    }
    return(c(i, j))
}

# Sweep the grid until no agent moves. Agents are updated one at a time, so an
# agent that moves early in a sweep is evaluated again later in the same sweep.
iteration <- 1
all_happy <- FALSE
while (!all_happy) {
    moves <- 0  # Counter for agent moves
    for (i in 1:n_rows) {
        for (j in 1:n_cols) {
            if (grid[i, j] != 0) {  # If there is an agent at this location
                if (calculate_happiness(i, j) < threshold) {  # If unhappy
                    new_cell <- find_empty_cell()
                    grid[new_cell[1], new_cell[2]] <- grid[i, j]  # Move it
                    grid[i, j] <- 0  # Leave the previous cell empty
                    moves <- moves + 1
                }
            }
        }
    }
    print(paste0("Iteration: ", iteration, ", moves: ", moves))
    iteration <- iteration + 1
    if (moves == 0) {  # If no agents moved then all must be happy
        all_happy <- TRUE
    }
}

# Plot a grid, using gray for empty cells and one color for each group
plot_grid <- function(g, title) {
    df <- expand.grid(row = 1:nrow(g), col = 1:ncol(g))
    df$value <- factor(as.vector(g), levels = c(0, 1, 2))
    ggplot(df, aes(x = col, y = row, fill = value)) +
        geom_tile(color = "white") +
        scale_fill_manual(values = c("gray90", "#2C5080", "#B23A48")) +
        labs(title = title) +
        theme_minimal() +
        theme(
            axis.title = element_blank(),   # Suppress axis titles
            axis.text = element_blank(),    # Suppress axis labels
            panel.grid = element_blank(),
            legend.position = "none"        # Remove legend
        )
}

plot_grid(initial_grid, "Initial grid")
plot_grid(grid, "Final grid")
