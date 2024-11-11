#This dataset https://www.kaggle.com/datasets/rabieelkharoua/students-performance-dataset

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
# StudentID,Age,Gender,Ethnicity,ParentalEducation,StudyTimeWeekly,Absences,Tutoring,ParentalSupport,
# Extracurricular,Sports,Music,Volunteering,GPA,GradeClass

def process_and_save_data(input_file, output_train_file):
    data = pd.read_csv(input_file) #Load
    
    #We wont use the column GPA as its the same as the GradeClass bur in numerical
    data = data.drop(columns = ['GPA']) 

    #Aditionally, we need two target, we can group the grades as good grades and bad grades
    #In the variable Grade Class if the values is either 1,2 o 3, we will assign it as 0, otherwise we will assign it as 1
    data['GradeClass'] = data['GradeClass'].apply(lambda x: 1 if x in [1,2,3] else -1) #MUST BE 1/-1 IN THE SVM
    
    #Define the features and the target
    feature_columns = ['Age', 'Gender', 'Ethnicity', 'ParentalEducation','StudyTimeWeekly','Absences','Tutoring','Extracurricular','ParentalSupport','Sports','Music','Volunteering']  # Replace with actual feature names
    
    dim = len(feature_columns) #define dim as the number of features
    N = list(range(len(data)))  #Define N as the number of rows in the dataset
    target_column = 'GradeClass'  

    # Split features and label
    X = data[feature_columns].values
    y = data[target_column].values


    # Apply feature scaling to the features
    scaler = StandardScaler()
    X = scaler.fit_transform(X)

    #Lastly we need to format the csv to a format with all the feattures followed by the target, the same as the gensvmdat.exe
    with open(output_file, 'w') as outfile:
            # Write the set N
            outfile.write("set N := ")
            outfile.write(' '.join(map(str, N)))
            outfile.write(";\n\n")

            # Write the dimension
            outfile.write(f"param dim := {dim};\n\n")

            # Write the labels
            outfile.write("param y :=\n")
            for i in N:
                outfile.write(f"{i} {y[i]}\n")
            outfile.write(";\n\n")

            # Write the features
            outfile.write("param X :\n")
            outfile.write(' '.join(map(str, range(1, dim+1))))
            outfile.write(" :=\n")
            for i in N:
                features_str = ' '.join(f"{x:.6f}" for x in X[i])
                outfile.write(f"{i} {features_str}\n")
            outfile.write(";\n")


#Then we can run the script
data = r'.\raw_data\Student_performance_data.csv'
output_file = '.\processed_data\Student_performance_data.dat'

process_and_save_data(data, output_file)

