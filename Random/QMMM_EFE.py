import gi
import os
import subprocess
import sys

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib

class QMMMApplication(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="QMMM Setup")
        self.set_border_width(10)

        grid = Gtk.Grid()
        self.add(grid)

        # Define widgets and add them to the grid with placeholder texts
        self.entries = {}
        input_fields = {
            'parm': 'Path to parameter file (e.g., solv.prmtop)',
            'trajin': 'Path to trajectory file (e.g., trajectory.nc)',
            'resname': 'Active site except substrate (e.g., HD1, OY1)',
            'substrate': 'Substrate residues (e.g., M3L or LAR)',
            'tleapinput': 'Tleap input file path (e.g., tleap.in)',
            'parsefile': 'Parse_amber TCL file path',
            'numberofres': 'Range of residues (e.g., 1-552)',
            'frame': 'Frame number',
            'basis': 'Basis set (e.g., def2-SVP)',
            'charge': 'Total charge of the QM region',
            'unp': 'Number of unpaired electrons',
            'nodes': 'Number of CPUs',
        }
        for i, (field, placeholder) in enumerate(input_fields.items()):
            label = Gtk.Label(label=field.capitalize())
            entry = Gtk.Entry()
            entry.set_placeholder_text(placeholder)  # Set placeholder text
            button = Gtk.Button(label="Browse")
            button.connect("clicked", self.on_browse_clicked, field)
            self.entries[field] = entry
            grid.attach(label, 0, i, 1, 1)
            grid.attach(entry, 1, i, 1, 1)
            grid.attach(button, 2, i, 1, 1)

        submit_button = Gtk.Button(label="Submit")
        submit_button.connect("clicked", self.on_submit_clicked)
        grid.attach_next_to(submit_button, label, Gtk.PositionType.BOTTOM, 3, 1)

        self.connect("destroy", Gtk.main_quit)

    def on_browse_clicked(self, widget, field):
        dialog = Gtk.FileChooserDialog(title="Please choose a file", parent=self, action=Gtk.FileChooserAction.OPEN)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.entries[field].set_text(dialog.get_filename())
        dialog.destroy()

    def on_submit_clicked(self, widget):
        # Collect values from entries
        values = {field: entry.get_text() for field, entry in self.entries.items()}
        print(values)  # Placeholder for actual operations
        Gtk.main_quit()

        # Here you would add the logic for file operations and external process executions

def main():
    win = QMMMApplication()
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
