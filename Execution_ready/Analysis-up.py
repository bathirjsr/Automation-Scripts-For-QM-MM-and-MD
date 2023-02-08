#!/bin/python

import os
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('-s', type=str, dest='step')
parser.add_argument('-r', type=str, dest='rebound')
args = parser.parse_args()

if not os.path.exists('../Analysis'):
    os.makedirs('../Analysis')
elif not os.path.isdir('../Analysis'):
    print("Analysis already exists but is not a directory")

os.chdir('../MD/6-md/') or exit

with open('QM.tcl', 'w') as f:
    f.write('''mol load pdb rc.pdb
atomselect top "(resname FE1 OY1 SC1 GU1 HD1 HD2 and not backbone and not type HA H) or (resname M2L and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)"
atomselect0 num
atomselect0 writepdb QM.pdb
exit
''')

subprocess.call(['vmd', '-dispdev', 'text', '-e', 'QM.tcl'])
os.rename('QM.pdb', '../../Analysis/QM.pdb')

os.chdir('../../QMMM') or exit

dirs = [d.rstrip('/') for d in os.listdir() if os.path.isdir(d)]
print(f"There are {len(dirs)} dirs in the current path")

if args.step == "Energy":
    for i, dirname in enumerate(dirs, start=1):
        dirnumber = dirname[-5:]
        print(dirnumber)
        print(i, dirname)
        rc = subprocess.check_output(f'grep "Final converged energy" "{dirname}/1-RC_Opt/RC_dlfind.log" | awk \'{{printf "%5.12f", $NF}}\'', shell=True).strip().decode()
        rc_sp = subprocess.check_output(f'grep "Energy (     hybrid):" "{dirname}/1-RC_Opt/SP/RC_SP.log" | awk \'{{printf "%5.12f", $(NF-1)}}\'', shell=True).strip().decode()
        rc_zpe = subprocess.check_output(f'grep "total ZPE" "{dirname}/1-RC_Opt/Frequency/RC_Freq.log" | awk \'{{printf "%7.5f", $(NF-1)}}\' | awk \'{{printf "%5.12f", $1/(1000*4.184*627.5095)}}\'', shell=True).strip().decode()
        rc_b2_zpe = float(rc_sp) + float(rc_zpe)
        ts = subprocess.check_output(f'grep "Final converged energy" "{dirname}/3-TS_Opt/TS_Opt.log" | awk \'{{printf "%5.12f", $NF}}\'', shell=True).strip
