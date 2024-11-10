param N;
param n;
param nu;
param y {1..N};
param A {1..N, 1..n};

var w {1..n};
var l {1..N} >= 0, <= nu;

maximize fobj:
    sum {i in 1..N} l[i]
    - 1/2 * sum {i in 1..N, j in 1..N, p in 1..n}
        l[i] * y[i] * l[j] * y[j] * A[i, p] * A[j, p];

subject to Constraints:
    sum {j in 1..N} y[j] * l[j] = 0;

subject to Weights {i in 1..n}:
    w[i] = sum {j in 1..N} l[j] * A[j, i] * y[j];