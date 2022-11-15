#! /bin/bash
grep "$1" 3avr_H_amber.pdb > "$1"_test.pdb
pdb4amber "$1"_test.pdb > "$1"_amber.pdb
antechamber -fi pdb -fo mol2 -i "$1"_amber.pdb -o "$1"_amber.mol2 -pf y -nc 1 -c bcc
parmchk2 -i "$1"_amber.mol2 -o "$1"_amber.frcmod -f mol2