import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA

data = np.loadtxt(r'.\raw_data\data_100test.dat')  # Replace 'data.txt' with your data file name if different


# Assuming your data is already loaded in the variable `data`
X = data[:, :4]  # First 4 columns are features
y = data[:, 4]   # Last column is the label

# Apply PCA to reduce to 2D for visualization
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)

# Project weights onto the PCA space
# w_ampl is the weight vector from your AMPL solution
w_ampl = np.array([2.73514, 1.50309, 2.32227, 2.28589])
b_ampl = -4.3102

# Transform the original weights into the PCA-reduced space
w_pca = pca.transform([w_ampl])[0]  # Projecting the weights to 2D

# Plot data points
plt.figure(figsize=(10, 6))
for i in range(len(y)):
    if y[i] == 1:
        plt.scatter(X_pca[i, 0], X_pca[i, 1], color='b', marker='o', label='Class 1' if i == 0 else "")
    else:
        plt.scatter(X_pca[i, 0], X_pca[i, 1], color='r', marker='x', label='Class -1' if i == 0 else "")

# Plot decision boundary
x_min, x_max = X_pca[:, 0].min() - 1, X_pca[:, 0].max() + 1
y_min, y_max = X_pca[:, 1].min() - 1, X_pca[:, 1].max() + 1
xx, yy = np.meshgrid(np.linspace(x_min, x_max, 100), np.linspace(y_min, y_max, 100))

# Calculate decision boundary
Z = w_pca[0] * xx + w_pca[1] * yy + b_ampl
plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors='k')  # Decision boundary

# Formatting the plot
plt.xlabel('PCA Component 1')
plt.ylabel('PCA Component 2')
plt.title('SVM Decision Boundary (Projected using PCA)')
plt.legend()
plt.grid(True)
plt.show()
