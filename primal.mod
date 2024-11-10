set N;          # Set of data point indices
param n;        # Dimension of feature vectors
param C;        # Regularization parameter

param y {N};          # Class labels
param X {N, 1..n};    # Feature vectors

# Variables
var w {1..n};
var b;
var xi {N} >= 0;
	
# Objective Function
minimize Obj:
    0.5 * sum {j in 1..n} w[j]^2 + C * sum {i in N} xi[i];

# Constraints
subject to Margin {i in N}:
    y[i] * (sum {j in 1..n} w[j] * X[i,j] + b) >= 1 - xi[i];

# Declarations for test data
set N_test;
param y_test {N_test};
param X_test {N_test, 1..n};
