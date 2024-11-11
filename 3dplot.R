# Load necessary libraries
if (!require("plotly")) install.packages("plotly", dependencies=TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies=TRUE)
library(plotly)  # For interactive 3D plotting
library(dplyr)   # For data manipulation

# Step 1: Read and Preprocess the Data

# Define the path to the data file
data_file <- './raw_data/data_1000.dat'  # Adjust the path as needed

# Read the data, removing asterisks from the last column
data <- read.table(data_file, header = FALSE, stringsAsFactors = FALSE)

# Remove asterisks from the last column (labels)
data$V5 <- as.numeric(gsub('\\*', '', data$V5))

# Separate features and labels
X <- as.matrix(data[, 1:4])  # Features (columns 1 to 4)
y <- data$V5                 # Labels (column 5)

# Step 2: Apply PCA to Reduce Dimensions to 3
pca_result <- prcomp(X, center = TRUE, scale. = FALSE)

# Get the PCA-transformed data (first 3 principal components)
X_pca <- pca_result$x[, 1:3]

# Step 3: Original Weights and Intercept from AMPL Solutions

# Primal SVM weights and intercept for C=1
w_ampl_C1 <- c(3.6414, 3.99128, 3.64292, 3.95706)
b_ampl_C1 <- -7.66663

# Dual SVM weights and intercept for C=0.1
w_ampl_C0.1 <- c(2.14555, 2.16028, 2.0836, 2.17814)
b_ampl_C0.1 <- -4.34526

# Step 4: Transform the Weights to the PCA Space

# Function to transform weights and intercept into PCA space
transform_hyperplane <- function(w, b, pca_rot, pca_mean) {
  # Transpose the rotation matrix to align dimensions (3 x 4)
  w_pca <- as.numeric(t(pca_rot[, 1:3]) %*% w)  # Resulting in a vector of length 3
  
  # Adjust the intercept to account for PCA centering
  b_pca <- sum(w * pca_mean) + b
  
  return(list(w_pca = w_pca, b_pca = b_pca))
}

# Get PCA rotation matrix and mean
pca_rot <- pca_result$rotation  # (4 x 3)
pca_mean <- pca_result$center   # Vector of length 4

# Transform primal hyperplane (C=1)
transformed_primal <- transform_hyperplane(w_ampl_C1, b_ampl_C1, pca_rot, pca_mean)
w_pca_primal <- transformed_primal$w_pca
b_pca_primal <- transformed_primal$b_pca

# Transform dual hyperplane (C=0.1)
transformed_dual <- transform_hyperplane(w_ampl_C0.1, b_ampl_C0.1, pca_rot, pca_mean)
w_pca_dual <- transformed_dual$w_pca
b_pca_dual <- transformed_dual$b_pca

# Step 5: Prepare Data for Plotting

# Map labels to descriptive strings
plot_data <- data.frame(
  PC1 = X_pca[, 1],
  PC2 = X_pca[, 2],
  PC3 = X_pca[, 3],
  Label = ifelse(y == -1, 'Class -1', 'Class 1')
)

# Convert Label to factor to ensure correct ordering
plot_data$Label <- factor(plot_data$Label, levels = c('Class -1', 'Class 1'))

# Step 6: Create Meshgrids for Both Decision Boundaries

# Function to create meshgrid and calculate PC3 for the hyperplane
create_meshgrid <- function(w_pca, b_pca) {
  # Define ranges for the grid based on PCA components
  x_seq <- seq(min(X_pca[, 1]) - 1, max(X_pca[, 1]) + 1, length.out = 50)
  y_seq <- seq(min(X_pca[, 2]) - 1, max(X_pca[, 2]) + 1, length.out = 50)
  grid <- expand.grid(PC1 = x_seq, PC2 = y_seq)
  
  # Calculate PC3 based on the hyperplane equation
  grid$PC3 <- -(w_pca[1] * grid$PC1 + w_pca[2] * grid$PC2 + b_pca) / w_pca[3]
  
  # Remove any rows with infinite or NaN values (optional)
  grid <- grid %>% filter(is.finite(PC3))
  
  return(grid)
}

# Create meshgrid for primal hyperplane (C=1)
grid_primal <- create_meshgrid(w_pca_primal, b_pca_primal)

# Create meshgrid for dual hyperplane (C=0.1)
grid_dual <- create_meshgrid(w_pca_dual, b_pca_dual)

# Step 7: Plot the Data and Both Decision Boundaries in 3D

# Create the plot
fig <- plot_ly()

# Add data points for Class -1
fig <- fig %>% add_trace(
  data = plot_data %>% filter(Label == 'Class -1'),
  x = ~PC1, y = ~PC2, z = ~PC3,
  type = 'scatter3d',
  mode = 'markers',
  name = 'Class -1',
  marker = list(size = 3, color = 'red')
)

# Add data points for Class 1
fig <- fig %>% add_trace(
  data = plot_data %>% filter(Label == 'Class 1'),
  x = ~PC1, y = ~PC2, z = ~PC3,
  type = 'scatter3d',
  mode = 'markers',
  name = 'Class 1',
  marker = list(size = 3, color = 'blue')
)

# Add the primal decision boundary surface (C=1)
fig <- fig %>% add_trace(
  x = grid_primal$PC1, y = grid_primal$PC2, z = grid_primal$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'green',
  name = 'Primal Hyperplane (C=1)',
  showscale = FALSE
)

# Add the dual decision boundary surface (C=0.1)
fig <- fig %>% add_trace(
  x = grid_dual$PC1, y = grid_dual$PC2, z = grid_dual$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'purple',
  name = 'Dual Hyperplane (C=0.1)',
  showscale = FALSE
)

# Add labels and title
fig <- fig %>% layout(
  scene = list(
    xaxis = list(title = 'PCA Component 1'),
    yaxis = list(title = 'PCA Component 2'),
    zaxis = list(title = 'PCA Component 3')
  ),
  title = 'SVM Decision Boundaries (Primal C=1 and Dual C=0.1) in 3D PCA Space'
)

# Display the plot
fig
