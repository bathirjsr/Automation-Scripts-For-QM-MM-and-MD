import MDAnalysis as mda
import numpy as np
# Function to calculate distances
def calculate_distances(resname1, name1, resname2, name2, prmtop_file, pdb_file, output_file, input_type, append=True):
    # Load the topology and PDB file
    u = mda.Universe(prmtop_file, pdb_file)

    # Select atoms
    selection1 = u.select_atoms(f'resname {resname1} and name {name1}')
    selection2 = u.select_atoms(f'resname {resname2} and name {name2}')
    
    # Check if selections are not empty
    if len(selection1) == 0 or len(selection2) == 0:
        print("One of the selections is empty. Please check your selection criteria.")
        return

    # Open output file for writing or appending based on the append parameter
    mode = 'a' if append else 'w'

    # Open output file for appending
    with open(output_file, mode) as f:
        f.write("-------------------------------------------------\n")
        
        # Calculate distances
        for atom1 in selection1:
            for atom2 in selection2:
                distance = np.linalg.norm(atom1.position - atom2.position)
                f.write(f"{atom1.resname}@{atom1.name}-{atom2.resname}@{atom2.name:<10}{distance:.2f}\n")
        
    print(f"Distances calculated and {'appended to' if append else 'written to'} {output_file}")
# Get the first input (RC or TS)
input_type = input("Enter the input type (RC or TS): ").strip().upper()

# Define file names based on input type
if input_type == "RC":
    prmtop_file = "rc.prmtop"
    pdb_file = "rc.opt.pdb"
elif input_type == "TS":
    prmtop_file = "ts.prmtop"
    pdb_file = "ts.opt.pdb"
elif input_type == "PD":
    prmtop_file = "pd.prmtop"
    pdb_file = "pd.opt.pdb"
else:
    print("Invalid input. Please enter 'RC' or 'TS' or 'PD'.")
    sys.exit(1)


# Example usage for multiple distance calculations
calculate_distances('AG1', 'C2', 'OY1', 'O2',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=False)
calculate_distances('AG1', 'C2', 'AG1', 'C1',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)
calculate_distances('AG1', 'C1', 'OY1', 'O1',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)
calculate_distances('AG1', 'C2', 'AG1', 'C3',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)
calculate_distances('AG1', 'C3', 'AG1', 'C4',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)
calculate_distances('AG1', 'C4', 'AG1', 'C5',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)
calculate_distances('AG1', 'C3', 'OY1', 'O1',prmtop_file,pdb_file,'Distance{input_type}.txt',input_type, append=True)

