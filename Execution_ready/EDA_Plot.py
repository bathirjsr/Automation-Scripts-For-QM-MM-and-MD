#!/bin/python3
# %%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from Bio import PDB
from Bio.PDB.Polypeptide import three_to_one
import sys


# %%
# Function to parse PDB file and map residue numbers to one-letter codes
def parse_pdb_residues(pdb_file):
    parser = PDB.PDBParser(QUIET=True)
    structure = parser.get_structure('protein', pdb_file)
    residue_map = {}
    
    for model in structure:
        for chain in model:
            for residue in chain:
                res_id = residue.get_id()[1]  # Residue number
                res_name = residue.get_resname()  # Three-letter residue code
                try:
                    res_letter = three_to_one(res_name)  # Convert to one-letter code
                except KeyError:
                    res_letter = 'X'  # Use 'X' if the conversion fails
                residue_map[res_id] = res_letter
    
    return residue_map

# Function to plot the graph
def plot_eda_graph(eda_file, pdb_file, output_svg):
    # Read EDA data
    data = pd.read_csv(eda_file, delim_whitespace=True)
    residues = data['Residue']
    eda = data['TotalDiffE']
    
    # Parse PDB file to get residue names
    residue_map = parse_pdb_residues(pdb_file)
    
    # Determine the top 3 and bottom 3 EDA values
    top_3_indices = np.argsort(eda)[-3:]
    bottom_3_indices = np.argsort(eda)[:3]
    
    # Create a block plot (step plot) with Residue on the x-axis and EDA on the y-axis
    plt.figure()
    plt.step(residues, eda, where='mid', linewidth=2, color='blue')
    plt.scatter(residues, eda, color='red')
    
    # Label only the top 3 and bottom 3 EDA values with residue numbers and names
    for i in top_3_indices:
        res_num = residues[i]
        res_name = residue_map.get(res_num, 'X')  # Use 'X' if not found
        plt.text(res_num, eda[i] + 0.02, f'{res_name}{res_num}: {eda[i]:.2f}', ha='center', color='black', fontsize=10, family='Arial')
    
    for i in bottom_3_indices:
        res_num = residues[i]
        res_name = residue_map.get(res_num, 'X')  # Use 'X' if not found
        plt.text(res_num, eda[i] + 0.02, f'{res_name}{res_num}: {eda[i]:.2f}', ha='center', color='black', fontsize=10, family='Arial')
    
    # Adding labels and title
    plt.xlabel('Residues', fontsize=12, family='Arial')
    plt.ylabel('EDA (\u0394E)(kcal mol$^{-1}$)',
               fontsize=12, family='Arial')
    
    # Save the plot as an SVG file
    plt.grid(False)
    plt.savefig(output_svg, format='svg')
    plt.close()

# %%
# Example usage:
# Ask user for the path to the EDA.dat file
# Take inputs from command line arguments
eda_file = sys.argv[1]  # First command line argument
pdb_file = sys.argv[2]  # Second command line argument

# Ask user for the output SVG file path
#output_svg = input("Enter the path to save the output SVG file: ").strip()

plot_eda_graph(eda_file, pdb_file, "EDA_Plot.svg")


