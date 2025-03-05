#!/bin/python3
import sys
import re
from pathlib import Path

def extract_value(pattern, file_path, group_index=-1, format_string="{:.12f}"):
    """Extracts a value from a file based on a regex pattern."""
    try:
        with open(file_path, 'r') as file:
            for line in file:
                if re.search(pattern, line):
                    value = re.findall(pattern, line)[0][group_index]
                    return float(value)
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except IndexError:
        print(f"Pattern not found in file: {file_path}")
    return None

def main(arg):
    B1 = None
    if arg == "RC":
        B1 = extract_value(r'Final converged energy\s*=\s*([-+]?\d*\.\d+|\d+)', f"{arg}_dlfind.log")
    elif arg in ["TS", "RB_TS"]:
        B1 = extract_value(r'Final converged energy\s*=\s*([-+]?\d*\.\d+|\d+)', f"{arg}_Opt.log")
        try:
            frequency_files = Path("Frequency").glob("*.log")
            for idx, file in enumerate(frequency_files):
                with open(file, 'r') as freq_file:
                    lines = freq_file.readlines()
                    print(f"Frequencies from {file}: {lines[:4]}")
                if idx == 3:  # Limit to first 4 files
                    break
        except Exception as e:
            print(f"Error processing frequencies: {e}")
    else:
        B1 = extract_value(r'Final converged energy\s*=\s*([-+]?\d*\.\d+|\d+)', f"{arg}_Opt.log")
    
    B2 = extract_value(r'Energy \(     hybrid\):\s*([-+]?\d*\.\d+|\d+)', f"SP/{arg}_SP.log")
    
    try:
        zpe_kj_raw = extract_value(r'total ZPE\s*=\s*([-+]?\d*\.\d+|\d+)', f"Frequency/{arg}_Freq.log")
        ZPE_J = float((f"{zpe_kj_raw/497 ,group.endswith,end.) =:`-->`