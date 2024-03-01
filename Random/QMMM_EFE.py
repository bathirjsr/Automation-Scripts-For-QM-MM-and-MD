import argparse
import sys

# Define the command-line argument parser
parser = argparse.ArgumentParser(description="QMMM Script",
                                 formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-i', '--input', type=str, help='Input file name')
parser.add_argument('-s', '--step', type=int, help='Step number')
parser.add_argument('-a', '--atomnumber1', type=int, help='Atom number 1')
parser.add_argument('-b', '--atomnumber2', type=int, help='Atom number 2')
parser.add_argument('-c', '--C', type=str, help='C argument')
parser.add_argument('-d', '--D', type=str, help='D argument')
parser.add_argument('-t', '--transition', type=str, help='Transition state')
parser.add_argument('-p', '--product', type=str, help='Product state')

# Check if the first argument is 'help'
if len(sys.argv) > 1 and sys.argv[1] == "help":
    print("""
!!!!Follow the Guidelines properly !!!!!
Execution Syntax: QMMM.py -i input.in -s <stepnumber> -a <atomnumber1> -b <atomnumber2> -t <transitionstate> -p <product state>
(input -a and -b only for Scan calculation and -t for TS optimization and -p for Product Optimization)
Edit the script for changing the path for parse_amber.tcl file
Change the vmd atomselect tcl script according to your substrate and system(QM region and MM region)
Make sure to create an input file (input.in)

Contents of Input File

#Input for QMMM Modelling
parsefile=               #Parse_amber.tcl File path
system=                          #System(Filename of the parameter)
parm=                            #Parameter File path
frame=                           #Frame Number
trajin=                          #Non-Autoimaged Trajectory File
resname="FE1 OY1 SC1 GU1 HD1 HD2"    #RC Residues
substrate=M3L                          #Substrate Residue
numberofres=1-552                      #Residue range
basis=def2-SVP                         #basis
charge=0                               #Charge of the system
unp=4                                  #Unpaired electrons in Iron center
nodes=20                               #Number of processors
tleapinput=                #tleap input file path used for building the MD files

Steps of QMMM Calculations (Execution Folder given in Brackets)
-s 0 QM and MM Modelling and Creating Files for RC_OPT (6-md Folder)
-s 1 RC Optimization (1-RC_Opt Folder)
-s 1f RC Frequency (1-RC_Opt Folder)
-s 1s RC Single Point Calculation (1-RC_Opt Folder)
-s 2 Scan (HAT) (1-RC_Opt Folder)
-s 3 TS Optimization (2-Scan Folder)
-s 3f TS Frequency (3-TS_Opt Folder)
-s 3s TS Single Point Calculation (3-TS_Opt Folder)
-s 4 PD Optimization (2-Scan Folder)
-s 4f PD Frequency (4-PD Folder)
-s 4s PD Single Point Calculation (4-PD Folder)
""")
    sys.exit()

# Parse the command-line arguments
args = parser.parse_args()

# Use the parsed arguments
#print(f"Input file: {args.input}")
#print(f"Step number: {args.step}")




# Continue for other arguments as needed
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

class QMMMDialog(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="QMMM File and Data Selections")
        self.set_border_width(10)
        self.set_size_request(400, 600)

        # Vertical box to hold widgets
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.add(vbox)

        # Parameter File
        self.create_file_chooser_button(vbox, "Select Parameter File (*.prmtop)", "*.prmtop", "parm")
        # Trajectory File
        self.create_file_chooser_button(vbox, "Select Trajectory File (*.nc)", "*.nc", "trajin")
        # tleap Input File
        self.create_file_chooser_button(vbox, "Select tleap Input File (*.in)", "*tleap.in", "tleapinput")
        # Parse_amber File
        self.create_file_chooser_button(vbox, "Select Parse_amber File (*.tcl)", "*.tcl", "parsefile")

        # Active Site Residues
        self.create_text_entry(vbox, "Active Site except Substrate (Eg. HD1,OY1 )", "resname")
        # Substrate Residues
        self.create_text_entry(vbox, "Substrate Residues (Eg. M3L or LAR )", "substrate")
        # Range of Residues
        self.create_text_entry(vbox, "Range of Residues (Eg. 1-552)", "numberofres")
        # Frame Number
        self.create_text_entry(vbox, "Frame Number", "frame")
        # Basis Set
        self.create_text_entry(vbox, "Basis Set (Eg. def2-SVP)", "basis")
        # Total Charge
        self.create_text_entry(vbox, "Total Charge of the QM Region", "charge")
        # Number of Unpaired Electrons
        self.create_text_entry(vbox, "Number of Unpaired Electrons", "unp")
        # Number of CPUs
        self.create_text_entry(vbox, "Number of CPUs", "nodes")

        # Submit button
        submit_button = Gtk.Button(label="Submit")
        submit_button.connect("clicked", self.on_submit_clicked)
        vbox.pack_start(submit_button, True, True, 0)

    def create_file_chooser_button(self, vbox, button_label, file_filter_pattern, data):
        button = Gtk.Button(label=button_label)
        button.connect("clicked", self.on_file_clicked, file_filter_pattern, data)
        vbox.pack_start(button, True, True, 0)

    def create_text_entry(self, vbox, placeholder_text, data):
        entry = Gtk.Entry()
        entry.set_placeholder_text(placeholder_text)
        vbox.pack_start(entry, True, True, 0)
        setattr(self, data + '_entry', entry)

    def on_file_clicked(self, widget, file_filter_pattern, data):
        dialog = Gtk.FileChooserDialog(title="Please choose a file", parent=self, action=Gtk.FileChooserAction.OPEN)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)

        file_filter = Gtk.FileFilter()
        file_filter.add_pattern(file_filter_pattern)
        dialog.add_filter(file_filter)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            print(f"{data} selected: {dialog.get_filename()}")
            setattr(self, data, dialog.get_filename())
        dialog.destroy()

    def on_submit_clicked(self, widget):
        # Example of accessing one of the entries and files chosen
        print(f"Active Site Residues: {self.resname_entry.get_text()}")
        if hasattr(self, 'parm'):
            print(f"Parameter File: {self.parm}")
        # Add similar lines to access and print other attributes

        # Here you would add your logic to use the collected data

        Gtk.main_quit()

def main():
    win = QMMMDialog()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
