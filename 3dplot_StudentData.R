# Load necessary libraries
if (!require("plotly")) install.packages("plotly", dependencies=TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies=TRUE)
library(plotly)  # For interactive 3D plotting
library(dplyr)   # For data manipulation

# Step 1: Read and Preprocess the Data

# Define the path to the data file
data_file <- './processed_data/Stud_per.dat'  # Adjust the path as needed

# Read the data, removing asterisks from the last column
data <- read.table(data_file, header = FALSE, stringsAsFactors = FALSE)

# Remove asterisks from the last column (labels)
data$V5 <- as.numeric(gsub('\\*', '', data$V5))

# Separate features and labels
X <- as.matrix(data[, 1:12])  # Features (columns 1 to 12)
y <- data$V13                 # Labels (column 13)

# Step 2: Apply PCA to Reduce Dimensions to 3
pca_result <- prcomp(X, center = TRUE, scale. = FALSE)

# Get the PCA-transformed data (first 3 principal components)
X_pca <- pca_result$x[, 1:3]

# Step 3: Original Weights and Intercept from AMPL Solutions

# Step 4: Original Weights and Intercept from AMPL Solutions

# Define SVM weights and intercepts for different C values
# Each w_ampl_* is a numeric vector of length 12
# Each b_ampl_* is a single numeric value

# SVM weights and intercept for C=1
w_ampl_C1 <- c(-0.006534, 0.0365097, 0.0661826, -0.0824734, 
               0.234922, -1.56612, 0.124494, 0.145322, 
               0.223796, 0.136067, 0.0980277, -0.058128)
b_ampl_C1 <- -0.212967

# SVM weights and intercept for C=0.1
w_ampl_C0.1 <- c(-0.00343424, 0.0400403, 0.0677323, -0.0821831, 
                 0.223859, -1.51249, 0.119707, 0.145398, 
                 0.201869, 0.126525, 0.0933757, -0.0701997)
b_ampl_C0.1 <- -0.203204

# SVM weights and intercept for C=0.01
w_ampl_C0.01 <- c(-0.00400844, 0.0217871, 0.0363535, -0.0816898, 
                  0.170778, -1.24084, 0.063453, 0.121993, 
                  0.116536, 0.0969071, 0.0576814, -0.0658453)
b_ampl_C0.01 <- -0.17115

# SVM weights and intercept for C=0.001
w_ampl_C0.001 <- c(-0.0143667, -0.00357952, 0.0299497, -0.0450995, 
                   0.0620717, -0.730294, 0.0247939, 0.0372134, 
                   0.0512618, 0.0156569, 0.0235519, -0.0214501)
b_ampl_C0.001 <- -0.103965

# SVM weights and intercept for C=0.006
w_ampl_C0.006 <- c(-0.00240939, 0.00722311, 0.0387971, -0.0798801, 
                   0.148373, -1.1225, 0.04228, 0.102944, 
                   0.100016, 0.0790058, 0.0598951, -0.0438163)
b_ampl_C0.006 <- -0.162278


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

# Transform  hyperplane (C=1)
transformed_C1 <- transform_hyperplane(w_ampl_C1, b_ampl_C1, pca_rot, pca_mean)
w_pca_C1 <- transformed_C1$w_pca
b_pca_C1 <- transformed_C1$b_pca

# Transform  hyperplane (C=0.1)
transformed_C0.1 <- transform_hyperplane(w_ampl_C0.1, b_ampl_C0.1, pca_rot, pca_mean)
w_pca_C0.1 <- transformed_C0.1$w_pca
b_pca_C0.1 <- transformed_C0.1$b_pca

# Transform  hyperplane (C=0.01)
transformed_C0.01 <- transform_hyperplane(w_ampl_C0.01, b_ampl_C0.01, pca_rot, pca_mean)
w_pca_C0.01 <- transformed_C0.01$w_pca
b_pca_C0.01 <- transformed_C0.01$b_pca

# Transform  hyperplane (C=0.001)
transformed_C0.001 <- transform_hyperplane(w_ampl_C0.001, b_ampl_C0.001, pca_rot, pca_mean)
w_pca_C0.001 <- transformed_C0.001$w_pca
b_pca_C0.001 <- transformed_C0.001$b_pca

# Transform  hyperplane (C=0.006)
transformed_C0.006 <- transform_hyperplane(w_ampl_C0.006, b_ampl_C0.006, pca_rot, pca_mean)
w_pca_C0.006 <- transformed_C0.006$w_pca
b_pca_C0.006 <- transformed_C0.006$b_pca

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

# Create meshgrid for hyperplane (C=1)
grid_C1 <- create_meshgrid(w_pca_C1, b_pca_C1)

# Create meshgrid for hyperplane (C=0.1)
grid_C0.1 <- create_meshgrid(w_pca_C0.1, b_pca_C0.1)

# Create meshgrid for hyperplane (C=0.01)
grid_C0.01 <- create_meshgrid(w_pca_C0.01, b_pca_C0.01)

# Create meshgrid for  hyperplane (C=0.001)
grid_C0.001 <- create_meshgrid(w_pca_C0.001, b_pca_C0.001)

# Create meshgrid for  hyperplane (C=0.006)
grid_C0.006 <- create_meshgrid(w_pca_C0.006, b_pca_C0.006)

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
  x = grid_C1$PC1, y = grid_C1$PC2, z = grid_C1$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'green',
  name = 'Hyp. C=1',
  showscale = FALSE
)

# Add the dual decision boundary surface (C=0.1)
fig <- fig %>% add_trace(
  x = grid_C0.1$PC1, y = grid_C0.1$PC2, z = grid_C0.1$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'purple',
  name = 'Hyp. C=0.1',
  showscale = FALSE
)

# Add the dual decision boundary surface (C=0.01)
fig <- fig %>% add_trace(
  x = grid_C0.01$PC1, y = grid_C0.01$PC2, z = grid_C0.01$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'lightgreen',
  name = 'Hyp. C=0.01',
  showscale = FALSE
)

# Add the dual decision boundary surface (C=0.001)
fig <- fig %>% add_trace(
  x = grid_C0.001$PC1, y = grid_C0.001$PC2, z = grid_C0.001$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'lightyellow',
  name = 'Hyp. C=0.001',
  showscale = FALSE
)

# Add the dual decision boundary surface (C=0.006)
fig <- fig %>% add_trace(
  x = grid_C0.001$PC1, y = grid_C0.006$PC2, z = grid_C0.006$PC3,
  type = 'mesh3d',
  opacity = 0.3,
  color = 'yellow',
  name = 'Hyp. C=0.006',
  showscale = FALSE
)

# Add labels and title
fig <- fig %>% layout(
  scene = list(
    xaxis = list(title = 'PCA Component 1'),
    yaxis = list(title = 'PCA Component 2'),
    zaxis = list(title = 'PCA Component 3')
  ),
  title = 'SVM Decision Boundaries in 3D PCA'
)

# Display the plot
fig
