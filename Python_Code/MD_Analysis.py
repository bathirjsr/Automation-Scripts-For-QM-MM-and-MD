import os
import tkinter as tk
from tkinter import filedialog
root=tk.Tk()
root.withdraw
if not os.path.exists(Analysis):
    os.makedirs(Analysis)
    print(f"Directory 'Analysis' created")
    os.chdir(Analysis)
def Autoimage():
    parm = filedialog.askopenfilename(title="Select a Parameter file")
    trajin = filedialog.askopenfilename(title="Select a trajectory file")
    print("$parm")
    print("$trajin")

Autoimage()

    