#!/bin/bash

## Define variables
## f will name your files, RES is the first residue name, RESB is the second residue name
## g is the file generated through rmagic-EDA-avg-diffs.r
f="P221A"
g="/home/chem-adm/PhD/PHF8/PHF8-variants/JmjC_P221A/QM-MM/snap1/1rc-opt/EDA/EDA-TS-RC/TS-RC_tot_avg.dat"
RESA="P221"
RESB="A"

## Coul
## Set up the information for Chimera
## Note: attribute cannot start with a capital letter
echo "#PHF8${RESA}PHF8${RESB}" > ${f}_EDA_tot_chimera.txt
echo "attribute: phf8${RESA}${RESB}tot" >> ${f}_EDA_tot_chimera.txt
echo "match mode: 1-to-1" >> ${f}_EDA_tot_chimera.txt
echo "recipient: residues" >> ${f}_EDA_tot_chimera.txt

## This will skip the header and print the residue number ($1) and the total difference ($2)
awk 'NR > 1 {printf "\t:%-3s\t%-22s\n", $1, $2}' $g >> ${f}_EDA_tot_chimera.txt

