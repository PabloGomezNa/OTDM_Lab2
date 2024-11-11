import re
import random

def read_ampl_data(file_path):
    with open(file_path, 'r') as file:
        data = file.read()

    print(data)
    # Extract set N
    N_match = re.search(r'set\s+N\s*:=\s*(.+?);', data, re.DOTALL)
    N_list = N_match.group(1).split()
    N = list(map(int, N_list))

    # Extract dim
    dim_match = re.search(r'param\s+(dim|n)\s*:=\s*(\d+);', data)
    dim = int(dim_match.group(2))

    # Extract y
    y_match = re.search(r'param\s+y\s*:=(.+?);', data, re.DOTALL)
    y_data = y_match.group(1).strip().split('\n')
    y = {}
    for line in y_data:
        parts = line.strip().split()
        if len(parts) >= 2:
            index = int(parts[0])
            label = int(parts[1])
            y[index] = label

    # Extract X
    X_match = re.search(r'param\s+X\s*:\s*(.+?)\s*:=\s*(.+?);', data, re.DOTALL)
    X_indices = X_match.group(1).strip().split()
    X_data = X_match.group(2).strip().split('\n')
    X = {}
    for line in X_data:
        parts = line.strip().split()
        if len(parts) >= dim + 1:
            index = int(parts[0])
            features = list(map(float, parts[1:dim+1]))
            X[index] = features

    return N, dim, y, X

def write_ampl_data(file_path, N_set_name, N_indices, y_param_name, y_data, X_param_name, X_data, dim):
    with open(file_path, 'w') as file:
        # Write set N
        file.write(f'set {N_set_name} := {" ".join(map(str, N_indices))};\n\n')

        # Write dim if necessary
        if 'train' in file_path:
            file.write(f'param n := {dim};\n\n')

        # Write y
        file.write(f'param {y_param_name} :=\n')
        for index in N_indices:
            file.write(f'{index} {y_data[index]}\n')
        file.write(';\n\n')

        # Write X
        file.write(f'param {X_param_name} : {" ".join(map(str, range(1, dim+1)))} :=\n')
        for index in N_indices:
            features = X_data[index]
            features_str = ' '.join(f'{feat:.6f}' for feat in features)
            file.write(f'{index} {features_str}\n')
        file.write(';\n\n')

def split_data(N, y, X, test_size):
    N_indices = N.copy()
    random.shuffle(N_indices)
    test_count = int(len(N_indices) * test_size)
    test_indices = sorted(N_indices[:test_count])
    train_indices = sorted(N_indices[test_count:])
    return train_indices, test_indices

def main():
    # File paths
    input_file = r'.\processed_data\data_processed_10000.dat'  # Replace with your input data file name
    train_file = r'.\processed_data\data_train_8000.dat'
    test_file = r'.\processed_data\data_test_2000.dat'

    test_prop = 0.2


    # Read the data
    N, dim, y, X = read_ampl_data(input_file)

    # Split the data
    train_indices, test_indices = split_data(N, y, X, test_size=test_prop)  # 20% test size

    # Write training data
    write_ampl_data(
        train_file,
        N_set_name='N',
        N_indices=train_indices,
        y_param_name='y',
        y_data=y,
        X_param_name='X',
        X_data=X,
        dim=dim
    )

    # Write testing data
    write_ampl_data(
        test_file,
        N_set_name='N_test',
        N_indices=test_indices,
        y_param_name='y_test',
        y_data=y,
        X_param_name='X_test',
        X_data=X,
        dim=dim
    )

if __name__ == '__main__':
    main()
