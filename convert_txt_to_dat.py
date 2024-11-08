# convert_to_ampl_dat.py

import sys

def main(input_file, output_file):
    try:
        with open(input_file, 'r') as infile:
            lines = infile.readlines()

        N = []
        y = {}
        X = {}

        index = 1
        for line in lines:
            # Remove any trailing whitespaces or newline characters
            line = line.strip()
            # Remove any asterisks at the end of the line
            line = line.rstrip('*')
            if not line:
                continue  # Skip empty lines

            parts = line.split()
            if len(parts) != 5:
                print(f"Warning: Line {index} does not have exactly 5 elements. Skipping line.")
                continue

            try:
                features = [float(value) for value in parts[:4]]
                label = float(parts[4])
            except ValueError:
                print(f"Warning: Non-numeric value found on line {index}. Skipping line.")
                continue

            N.append(index)
            y[index] = int(label)
            X[index] = features
            index += 1

        dim = 4  # Number of features

        # Write to the AMPL .dat file
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

        print(f"Successfully converted {input_file} to {output_file}.")

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_to_ampl_dat.py input.txt output.dat")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        main(input_file, output_file)
