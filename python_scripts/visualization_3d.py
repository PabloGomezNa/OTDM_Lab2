import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # Import 3D plotting tools
from sklearn.decomposition import PCA

data = np.loadtxt(r'.\raw_data\data_100test.dat')  # Replace 'data.txt' with your data file name if different




# Assuming your data is already loaded in the variable `data`
X = data[:, :4]  # First 4 columns are features
y = data[:, 4]   # Last column is the label

# Apply PCA to reduce dimensions to 3 for visualization
pca = PCA(n_components=3)
X_pca = pca.fit_transform(X)

# Project the weights from AMPL solution into the PCA space (first three dimensions)
w_ampl = np.array([2.73514, 1.50309, 2.32227, 2.28589])
b_ampl = -4.3102

# Transform the weights to the PCA space
w_pca = pca.components_.dot(w_ampl)

# Plot the data in 3D
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Plot data points with different markers/colors based on class
for i in range(len(y)):
    if y[i] == 1:
        ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2], color='b', marker='o', label='Class 1' if i == 0 else "")
    else:
        ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2], color='r', marker='x', label='Class -1' if i == 0 else "")

# Create a meshgrid for decision boundary visualization
x_min, x_max = X_pca[:, 0].min() - 1, X_pca[:, 0].max() + 1
y_min, y_max = X_pca[:, 1].min() - 1, X_pca[:, 1].max() + 1
z_min, z_max = X_pca[:, 2].min() - 1, X_pca[:, 2].max() + 1
xx, yy = np.meshgrid(np.linspace(x_min, x_max, 100), np.linspace(y_min, y_max, 100))

# Calculate the corresponding z values for the decision boundary
zz = -(w_pca[0] * xx + w_pca[1] * yy + b_ampl) / w_pca[2]  # Using w_pca and b_ampl for the boundary

# Plot the decision boundary
ax.plot_surface(xx, yy, zz, color='k', alpha=0.3, edgecolor='none')

# Formatting the plot
ax.set_xlabel('PCA Component 1')
ax.set_ylabel('PCA Component 2')
ax.set_zlabel('PCA Component 3')
ax.set_title('SVM Decision Boundary (Projected using 3D PCA)')
ax.legend()
plt.show()
