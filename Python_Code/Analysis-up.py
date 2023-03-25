#!/bin/python
import os
import re
import xlsxwriter

# Create a new workbook
workbook = xlsxwriter.Workbook('output.xlsx')

# Add a new worksheet
worksheet = workbook.add_worksheet()

# Write headers
worksheet.write('A1', 'File Name')
worksheet.write('B1', 'Energy')

# Define the pattern to match
pattern = r"Final converged energy:\s+(-?\d+\.\d+)"

# Compile the regex pattern
regex = re.compile(pattern)

# Loop over all files in the directory
current_row = 2
for filename in os.listdir('.'):
    # Check if the file name matches the pattern
    if filename.endswith('dlfind.log'):
        # Open the file
        with open(filename, 'r') as f:
            # Read the contents
            data = f.read()

            # Search for the matching pattern
            match = regex.search(data)

            # If a match is found, extract the energy value
            if match:
                energy = match.group(1)

                # Write the extracted data to the worksheet
                worksheet.write(f'A{current_row}', filename)
                worksheet.write(f'B{current_row}', float(energy))

                # Increment the row counter
                current_row += 1

# Close the workbook
workbook.close()
