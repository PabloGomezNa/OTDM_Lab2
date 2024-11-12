import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

def process_and_save_data(input_file, output_file):
    # Load the dataset
    data = pd.read_csv(input_file)
    
    # Drop the 'GPA' column as it's redundant with 'GradeClass'
    data = data.drop(columns=['GPA'])
    
    # Reassign 'GradeClass' to binary labels: 1 for good grades (1,2,3), -1 for bad grades
    data['GradeClass'] = data['GradeClass'].apply(lambda x: 1 if x in [1, 2, 3] else -1)
    
    # Define feature columns
    feature_columns = [
        'Age', 'Gender', 'Ethnicity', 'ParentalEducation',
        'StudyTimeWeekly', 'Absences', 'Tutoring', 'Extracurricular',
        'ParentalSupport', 'Sports', 'Music', 'Volunteering'
    ]
    
    # Extract features and target
    X = data[feature_columns].values
    y = data['GradeClass'].values
    
    # Apply feature scaling
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Combine scaled features with the target label
    combined_data = np.hstack((X_scaled, y.reshape(-1, 1)))
    
    # Save to the output file with space-separated values
    # Each line will have feature1 feature2 ... featureN label
    np.savetxt(output_file, combined_data, fmt='%.6f', delimiter=' ', comments='', header='')

# Example usage
if __name__ == "__main__":
    input_csv = r'.\raw_data\Student_performance_data.csv'
    output_dat = r'.\processed_data\Stud_per.dat'
    
    process_and_save_data(input_csv, output_dat)
