import argparse
import sys

def parse_arguments():
    parser = argparse.ArgumentParser(description='Process input arguments.')
    parser.add_argument('-g', '--gpu', required=True, help='GPU ID')
    parser.add_argument('-p', '--prmtop', required=True, help='Parameter file')
    parser.add_argument('-c', '--coords', required=True, help='Input coordinate')
    parser.add_argument('-n', '--nprocs', required=True, help='Number of CPU processors')
    parser.add_argument('-x', '--ngpu', required=True, help='Number of GPU processors')
    parser.add_argument('-r', '--residues', required=True, help='Residues restraining')
    parser.add_argument('-s', '--step', required=True, help='Simulation step')
    parser.add_argument('-m', '--resmask', required=True, help='Residue mask')
    return parser.parse_args()
