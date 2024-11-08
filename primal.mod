set N;          # Set of data point indices
param dim;      # Dimension of feature vectors
param C;        # Regularization parameter

param y {N};    # Class labels
param X {N, 1..dim};  # Feature vectors

# Variables
var w {1..dim};
var b;
var xi {N} >= 0;

# Objective Function
minimize Obj:
    0.5 * sum {j in 1..dim} w[j]^2 + C * sum {i in N} xi[i];

# Constraints
subject to Margin {i in N}:
    y[i] * (sum {j in 1..dim} w[j] * X[i,j] + b) >= 1 - xi[i];
