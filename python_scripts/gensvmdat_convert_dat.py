# convert_to_ampl_dat.py. This only works for the files generated bt the gensvmdat.exe as its only 4 dimensions and always have 
#the same format

import sys

def main(input_file, output_file):
    try:
        with open(input_file, 'r') as infile:
            lines = infile.readlines()

        #Create empty list to store all the values
        N = []
        y = {}
        X = {}

        index = 1
        for line in lines:
            #Remove any whitespaces
            line = line.strip()
            #Remove  asterisks 
            line = line.rstrip('*')
            if not line:
                continue  # Skip possible empty lines

            parts = line.split() # Split the line by whitespace, as they share the same format we know that the first 4 values are the features and the last one is the label
            if len(parts) != 5:
                print(f"Warning: Line {index} does not have exactly 5 elements. Skipping line.")
                continue

            try:
                features = [float(value) for value in parts[:4]]
                label = float(parts[4])
            except ValueError:
                print(f"Warning: Non-numeric value found on line {index}. Skipping line.")
                continue

            #Then we append the values to the lists ibtained
            N.append(index)
            y[index] = int(label)
            X[index] = features
            index += 1

        dim = 4  # Number of features, that we know its constant accros all the gensvmdat.exe files

        # Write to the AMPL .dat file
        with open(output_file, 'w') as outfile:
            #Write the set N
            outfile.write("set N := ")
            outfile.write(' '.join(map(str, N)))
            outfile.write(";\n\n")

            #Write dimension
            outfile.write(f"param dim := {dim};\n\n")

            #Write labels
            outfile.write("param y :=\n")
            for i in N:
                outfile.write(f"{i} {y[i]}\n")
            outfile.write(";\n\n")

            #Write the X features
            outfile.write("param X :\n")
            outfile.write(' '.join(map(str, range(1, dim+1))))
            outfile.write(" :=\n")
            for i in N:
                features_str = ' '.join(f"{x:.6f}" for x in X[i])
                outfile.write(f"{i} {features_str}\n")
            outfile.write(";\n")

        print(f"Successfully converted {input_file} to {output_file}.")

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")


#We use the parser to get the arguments from the command line
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_to_ampl_dat.py input.txt output.dat")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        main(input_file, output_file)


#To create all the files we used:
#py .\convert_txt_to_dat.py .\raw_data\data_100.dat .\processed_data\data_processed_100.dat
#py .\convert_txt_to_dat.py .\raw_data\data_500.dat .\processed_data\data_processed_500.dat
#py .\convert_txt_to_dat.py .\raw_data\data_1000.dat .\processed_data\data_processed_1000.dat
#py .\convert_txt_to_dat.py .\raw_data\data_10000.dat .\processed_data\data_processed_10000.dat