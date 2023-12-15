import tkinter as tk
from tkinter import filedialog, Toplevel
import subprocess
import os


def browse_file(entry, file_type):
    """ Open a dialog to choose a file and set the file path in the entry """
    file_path = filedialog.askopenfilename(
        filetypes=[(file_type, f"*.{file_type}")])
    entry.delete(0, tk.END)
    entry.insert(0, file_path)


def create_file_entry(window, row, label_text, file_type):
    """ Create a file entry with a label, text entry, and browse button """
    tk.Label(window, text=f"{label_text} (.{file_type}):").grid(
        row=row, column=0)
    file_entry = tk.Entry(window, width=50)
    file_entry.grid(row=row, column=1)
    tk.Button(window, text="Browse", command=lambda: browse_file(
        file_entry, file_type)).grid(row=row, column=2)
    return file_entry


def autoimage_form():
    """ Create a form for Autoimage analysis input """
    window = Toplevel()
    window.title("Autoimage Analysis")

    parm_entry = create_file_entry(window, 0, "Parameter file", "prmtop")
    traj_entry = create_file_entry(window, 1, "Trajectory file", "nc")

    # Submit button
    tk.Button(window, text="Submit", command=lambda: run_autoimage(
        parm_entry.get(), traj_entry.get())).grid(row=2, columnspan=3)


def run_autoimage(parm_file, traj_file):
    if parm_file and traj_file:
        # Create cpptraj input file
        cpptraj_input = f"parm {parm_file}\ntrajin {traj_file}\ntrajout {os.path.splitext(traj_file)[0]}_auto.nc\nrun"
        with open('cpptraj_input_file.in', 'w') as file:
            file.write(cpptraj_input)

        # Run cpptraj command
        subprocess.run(['cpptraj', '-i', 'cpptraj_input_file.in'])
        print(
            f"Autoimage analysis completed with parm file: {parm_file} and trajectory file: {traj_file}")
    else:
        print("Parameter file and trajectory file are required.")


def main():
    root = tk.Tk()
    root.title("MD Analysis Tool")

    analysis_options = {
        "Autoimage": autoimage_form,
        # Add other options here like "RMS": rms_form, "Hbond": hbond_form, etc.
        "Exit": root.destroy
    }

    for analysis, command in analysis_options.items():
        tk.Button(root, text=analysis, command=command).pack()

    root.mainloop()


if __name__ == "__main__":
    main()
