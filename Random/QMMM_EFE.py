import sys
import subprocess
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

class QMMMApplication(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="QMMM Setup")
        self.set_border_width(10)
        self.set_default_size(400, 300)  # Adjusted for visibility

        # Create a scrolled window
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_hexpand(True)
        scrolled_window.set_vexpand(True)
        self.add(scrolled_window)

        # Create a grid inside the scrolled window
        grid = Gtk.Grid()
        #grid.set_column_spacing(10)  # Add some spacing for readability
        scrolled_window.add(grid)

        # Define which fields require a browse button
        browse_fields = ['parm', 'trajin', 'tleapinput', 'parsefile']

        # Define all input fields and their placeholder texts
        input_fields = {
            'parm': 'Select Parameter File',
            'trajin': 'Select Trajectory File',
            'resname': 'Active Site except Substrate (E.g., HD1, OY1)',
            'substrate': 'Substrate Residues (E.g., M3L or LAR)',
            'tleapinput': 'tleap Input File',
            'parsefile': 'Parse_amber File',
            'numberofres': 'Range of Residues (E.g., 1-552)',
            'frame': 'Frame Number',
            'basis': 'Basis Set (E.g., def2-SVP)',
            'charge': 'Total Charge of the QM Region',
            'unp': 'Number of Unpaired Electrons',
            'nodes': 'Number of CPUs',
        }

        # Create widgets for each input field
        self.entries = {}
        for i, (field, placeholder) in enumerate(input_fields.items()):
            label = Gtk.Label(label=field.capitalize())
            entry = Gtk.Entry()
            entry.set_placeholder_text(placeholder)
            self.entries[field] = entry
            grid.attach(label, 0, i, 1, 1)
            grid.attach(entry, 1, i, 1, 1)

            # Conditionally add a browse button
            if field in browse_fields:
                button = Gtk.Button(label="Browse")
                button.connect("clicked", self.on_browse_clicked, field)
                grid.attach(button, 2, i, 1, 1)

        # Add a submit button at the end
        submit_button = Gtk.Button(label="Submit")
        submit_button.connect("clicked", self.on_submit_clicked)
        grid.attach(submit_button, 0, len(input_fields) + 1, 3, 1)

    def on_browse_clicked(self, widget, field):
        dialog = Gtk.FileChooserDialog(title="Please choose a file", parent=self, action=Gtk.FileChooserAction.OPEN)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.entries[field].set_text(dialog.get_filename())
        dialog.destroy()

    def on_submit_clicked(self, widget):
        # Collect and print values for demonstration
        print({field: entry.get_text() for field, entry in self.entries.items()})
        Gtk.main_quit()

def main():
    win = QMMMApplication()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
