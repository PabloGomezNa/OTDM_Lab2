set N;
param n;
param C;

param y {N};
param X {N, 1..n};

# Variables
var alpha {N} >= 0, <= C;

# Objective Function
maximize Obj:
    sum {i in N} alpha[i] - 0.5 * sum {i in N, j in N} alpha[i] * alpha[j] * y[i] * y[j] * ( sum {k in 1..n} X[i,k] * X[j,k] );

# Constraints
subject to Balance:
    sum {i in N} alpha[i] * y[i] = 0;

# Declarations for test data
set N_test;
param y_test {N_test};
param X_test {N_test, 1..n};