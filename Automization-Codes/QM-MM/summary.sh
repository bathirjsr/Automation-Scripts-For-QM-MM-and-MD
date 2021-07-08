#! /bin/bash

## Command to print out Energy from ChemShell Summary file
awk '$1 ~ /^Energy/ {print $2}' SUMMARY.txt > tmp

## Energies in kcal/mol with respect to first energy
awk '{ if (NR == 1 ) { Value = $1 } { print ($1 - Value) * 627.5095 } }' tmp > tmp2

## Command to print out bond lengths from ChemShell Summary file
awk '$1 ~ /^Distance/ {print $3}' SUMMARY.txt > tmp-b && sed -i 's/[:]//g' tmp-b

##Combine bond and converted energies
paste tmp-b tmp2 | column -s $'	' -t > Bond-Energy.txt && rm tmp*
