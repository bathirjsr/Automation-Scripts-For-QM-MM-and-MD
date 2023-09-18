import os
import pytraj as pt
import tkinter as tk
from tkinter import filedialog
root=tk.Tk()
root.withdraw

directory_path = "Analysis"
if not os.path.exists(directory_path):
    os.makedirs(directory_path)
    print(f"Directory '{directory_path}' created")
    os.chdir(directory_path)
def Autoimage():
    parm = filedialog.askopenfilename(title="Select a Parameter file")
    trajin = filedialog.askopenfilename(title="Select a trajectory file")
    parmfile = os.path.basename(parm)
    trajfile = os.path.basename(trajin)
    parmfilename = parmfile.split('_')
    trajfilename = trajfile.split('.')
    parameter = parmfilename[0]
    trajectory = trajfilename[0]

    traj = pt.datafiles.load_tz2_ortho()[:]
    traj = pt.autoimage(traj)
    
    # with open("Autoimage_{parameter}.in", "w") as autoimage:
    #     autoimage.write("parm {parmfile}")
    #     autoimage.write("parm {parameter}")
    #     autoimage.write("autoimage")
    #     autoimage.write("trajout {trajectory}_auto.nc")
    #     autoimage.write("run")
    #     autoimage.write("exit")

    print(parm)
    print(trajin)

Autoimage()

    