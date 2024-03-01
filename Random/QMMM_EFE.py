import sys
import subprocess
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

class QMMMApplication(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="QMMM Setup")
        self.set_border_width(10)
        self.set_default_size(400, 200)  # Set initial size

        # Use a scrolled window to make the content dynamically adjust to the size of the window
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_hexpand(True)
        scrolled_window.set_vexpand(True)
        self.add(scrolled_window)

        # Create a grid to place inside the scrolled window
        grid = Gtk.Grid()
        grid.set_column_homogeneous(True)
        grid.set_row_homogeneous(True)
        scrolled_window.add(grid)

        # Define widgets and add them to the grid
        self.entries = {}
        browse_fields = ['parm', 'trajin', 'tleapinput', 'parsefile']
        input_fields = ['parm', 'trajin', 'active', 'substrate', 'tleapinput', 'parsefile', 'numberofres', 'frame', 'basis', 'charge', 'unp', 'nodes']
        placeholders = {
            'parm': 'Select Parameter File',
            'trajin': 'Select Trajectory File',
            'active': 'Active Site except Substrate (Eg. HD1 OY1 )',
            'substrate': 'Substrate Residues (Eg. M3L or LAR )',
            'tleapinput' : 'Select tleap File from MCPB',
            'parsefile' : 'Select Parse_amber File',
            'numberofres' : 'Total number of residues(Eg. 1-552)',
            'frame' : 'Enter the Frame Number to be used',
            'basis' : 'Enter Basis set(Eg. def2-SVP)',
            'charge' : 'Enter Charge of the System',
            'unp' : 'Number of unpaired electrons',
            'nodes' : 'Number of processors to use',
        }

        for i, field in enumerate(input_fields):
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


        submit_button = Gtk.Button(label="Submit")
        submit_button.connect("clicked", self.on_submit_clicked)
        grid.attach(submit_button, 0, len(input_fields), 3, 1)

    def on_browse_clicked(self, widget, field):
        dialog = Gtk.FileChooserDialog(title="Please choose a file", parent=self, action=Gtk.FileChooserAction.OPEN)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.entries[field].set_text(dialog.get_filename())
        dialog.destroy()

    def on_submit_clicked(self, widget):
        # Placeholder for actual operations
        print({field: entry.get_text() for field, entry in self.entries.items()})
        Gtk.main_quit()

def main():
    win = QMMMApplication()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
