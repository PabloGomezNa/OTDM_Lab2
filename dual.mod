set N;
param dim;
param C;

param y {N};
param X {N, 1..dim};

# Variables
var alpha {N} >= 0, <= C;

# Objective Function
maximize Obj:
    sum {i in N} alpha[i] - 0.5 * sum {i in N, j in N} alpha[i] * alpha[j] * y[i] * y[j] * ( sum {k in 1..dim} X[i,k] * X[j,k] );

# Constraints
subject to Balance:
    sum {i in N} alpha[i] * y[i] = 0;
