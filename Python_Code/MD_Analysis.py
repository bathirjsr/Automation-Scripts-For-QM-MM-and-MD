import os
import tkinter as tk
from tkinter import filedialog
root=tk.Tk()
root.withdraw

directory_path = "Analysis"
if not os.path.exists($directory_path):
    os.makedirs($directory_path)
    print(f"Directory 'Analysis' created")
    os.chdir(Analysis)
def Autoimage():
    parm = filedialog.askopenfilename(title="Select a Parameter file")
    trajin = filedialog.askopenfilename(title="Select a trajectory file")
    print("$parm")
    print("$trajin")

Autoimage()

    