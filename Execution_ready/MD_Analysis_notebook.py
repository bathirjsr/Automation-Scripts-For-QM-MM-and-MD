!/usr/bin/env python3
# %%

import MDAnalysis as mda
from MDAnalysis.analysis import rms,diffusionmap, align
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tkinter as tk

# %%
prmtop_file = input("Enter the path to the prmtop file: ")
readline.set_completer_delims(' \t\n;')
readline.parse_and_bind("tab: complete")
nc_file = input("Enter the path to the .nc file: ")
readline.set_completer_delims(' \t\n;')
readline.parse_and_bind("tab: complete")
u = mda.Universe(prmtop_file, nc_file)
len(u.trajectory)



# %% [markdown]
# 

# %%
# Calculate RMSD
rmsd = rms.RMSD(u, u, ref_frame=0, select='backbone')
rmsd.run()

# Convert frames to time
time_step = 0.1  # time step in nanoseconds
time = np.arange(len(rmsd.rmsd)) * time_step

# Calculate average RMSD
average_rmsd = np.mean(rmsd.rmsd[:, 2])

# Create a DataFrame with time and RMSD values
rmsd_df = pd.DataFrame({
    'Time (ns)': time,
    'RMSD (Å)': rmsd.rmsd[:, 2]
})

# %%

# Print the DataFrame and average RMSD
print("RMSD DataFrame:")
print(rmsd_df)
print(f"\nAverage RMSD: {average_rmsd:.2f} Å")

# %%
# Configure Matplotlib to use Arial font
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = 'Arial'

# Plot RMSD with high quality settings
plt.figure(figsize=(12, 8), dpi=300)  # Set figure size and resolution
plt.plot(time, rmsd.rmsd[:, 2], label='Backbone RMSD', linewidth=2)
plt.xlabel('Time (ns)', fontsize=24)
plt.ylabel('RMSD (Å)', fontsize=24)
plt.ylim(0, 10)
plt.xlim(-10,1010)
plt.title('RMSD', fontsize=32)
plt.legend(fontsize=24)
plt.grid(False)
plt.xticks(fontsize=24)
plt.yticks(fontsize=24)
plt.tight_layout()
plt.show()

# %%
# Calculate RMSF
rmsf = rms.RMSF(u.select_atoms('name CA')).run()
rmsf_values = rmsf.rmsf

# %%
# Configure Matplotlib to use Arial font
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = 'Arial'

# Plot RMSF with high quality settings
plt.figure(figsize=(12, 8), dpi=300)  # Set figure size and resolution
plt.plot(rmsf.resids, rmsf_values, label='RMSF', linewidth=2)
plt.xlabel('Residue', fontsize=14)
plt.ylabel('RMSF (Å)', fontsize=14)
plt.title('RMSF', fontsize=16)
plt.legend(fontsize=12)
plt.ylim(0, 10)
plt.grid(False)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.savefig('rmsf_plot.png', dpi=300)  # Save the plot as a high-quality picture
plt.show()


