import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import statsmodels.api as sm
from tables import *
from matplotlib.colors import LinearSegmentedColormap

## Read in the data files generated with cpptraj
dwt1 = np.genfromtxt("I191A_corr_mat.dat",delimiter=None)

#-----------------------------------------------------------------------------#
#                               Self-Plots                                    #
#-----------------------------------------------------------------------------#

## Uncomment placesx2, placesy2, labelsx2, labelsy2 to explicitly define
## axis labels (e.g., to match real biological numbering)
# #Explicity choose where to put x and y ticks
# placesx2 = [0, 100, 200, 300, 333, 347, 400, 430]
# placesy2 = [25, 55, 108, 122, 155, 255, 355, 455]
# ## Note: we're not using the inverted y axis
# ## so therefore, this starts at bottom left
#
# #Define those very x and y tick labels
# labelsx2 = [1130, 1230, 1330, 1430, ' ', 1842, ' ', 'DNA']
# labelsy2 = ['DNA', 1895, 1842, 1463, 1430, 1330, 1230, 1130]

def mc_plot(data,outfile):
    """Generate a matrix correlation plot"""
    # global placesx2, placesy2, labelsx2, labelsy2
    sm.graphics.plot_corr(data,normcolor=(-1.0,1.0),cmap='RdYlBu')
    ax = plt.gca()
    ax.axes.get_xaxis()
    # ax.set_xticks(placesx2)
    # ax.set_xticklabels(labelsx2, fontdict=None, minor=False)
    ax.axes.get_yaxis()
    # ax.set_yticks(placesy2)
    # ax.set_yticklabels(labelsy2, fontdict=None, minor=False)
    ax.set_title('')
    plt.savefig(outfile)
    plt.close(outfile)


## Define a list of tuples with (data, outfile)
## This is for each individual file -- plot each replicate to check
self_datasets = [
  (dwt1, "I191A_corr_mat.png"),
  #(dwt2, "WT_protein_system-2_mc.png"),
  #(dwt3, "WT_protein_system-3_mc.png"),
  #(dwt4, "WT_protein_system-4_mc.png"),
  #(da1, "MUT_A_system-1_mc.png"),
  #(da2, "MUT_A_system-2_mc.png"),
  #(da3, "MUT_A_system-3_mc.png"),
]

for data,outfile in self_datasets:
    mc_plot(data,outfile)
