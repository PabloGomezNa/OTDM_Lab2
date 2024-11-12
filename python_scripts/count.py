import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
import pandas as pd
import re



def read_ampl_data(file_path):
    with open(file_path, 'r') as file:
        data = file.read()


    #Extract list of y
    y_match = re.search(r'param\s+y_test\s*:=(.+?);', data, re.DOTALL)
    y_data = y_match.group(1).strip().split('\n')
    y = {}
    for line in y_data:
        parts = line.strip().split()
        if len(parts) >= 2:
            index = int(parts[0])
            label = int(parts[1])
            y[index] = label


    return y 

#get the return values of function read_ampl_data

y=read_ampl_data(r'.\processed_data\data_test_200.dat')


#In y there are pnly +1 and -1 classes, count the number of +1 and -1 classes
count_plus_one = 0
count_minus_one = 0
for key in y:
    if y[key] == 1:
        count_plus_one += 1
    else:
        count_minus_one += 1

print("Number of +1 classes: ", count_plus_one)
print("Number of -1 classes: ", count_minus_one)
