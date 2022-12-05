#! /bin/bash
# grep "$1" 3avr_H_amber.pdb > "$1"_test.pdb
# pdb4amber "$1"_test.pdb > "$1"_amber.pdb
# antechamber -fi pdb -fo mol2 -i "$1"_amber.pdb -o "$1"_amber.mol2 -pf y -nc 1 -c bcc
# parmchk2 -i "$1"_amber.mol2 -o "$1"_amber.frcmod -f mol2

pdb4amber -i $1.pdb -o $1_fixed.pdb
awk '!/REMARK/' $1_fixed.pdb > tmpfile 
mv tmpfile $1_fixed2.pdb
awk '!/HOH/' $1_fixed2.pdb > tmpfile
mv tmpfile $1_fixed_no_water.pdb
rm $1_fixed2.pdb $1_fixed.pdb 
echo "Enter Chain To Be Removed:"
read -r chain1 chain2
awk -v var1="$chain1" -v var2="$chain2" ' $5 != var1 && $5 != var2 {print $0}' $1_fixed_no_water.pdb > $1_fixed3.pdb
awk -v var1="$chain1" -v var2="$chain2" ' $4 != var1 && $4 != var2 {print $0}' $1_fixed3.pdb > $1_fixed4.pdb
pdb4amber -i $1_fixed4.pdb -o $1_fixed_chain.pdb
rm -r $1_fixed4.pdb $1_fixed3.pdb
echo "Rearranging The PDB"
echo "Enter last residue number of enzyme:"
read -r ENZYME
awk -v a="$ENZYME" '$6 <= a && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > Enzyme.pdb
echo 'TER' >> Enzyme.pdb
echo "Enter the residue number of METAL 1:"
read -r METAL1
awk -v b="$METAL1" '$6 == b && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > Metal1.pdb
echo 'TER' >> Metal1.pdb
echo "Enter the residue number of METAL 2:"
read -r METAL2
awk -v c="$METAL2" '$6 == c && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > Metal2.pdb
echo 'TER' >> Metal2.pdb
echo "Enter the residue number of OXYGEN/SUPEROXO:"
read -r OXY
awk -v d="$OXY" '$6 == d && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > Oxygen_species.pdb
echo 'TER' >> Oxygen_species.pdb
echo "Enter residue number of CO-SUBSTRATE:"
read -r COSUB
awk -v e="$COSUB" '$6 == e && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > Cosubstrate.pdb
echo 'TER' >> Cosubstrate.pdb
echo "Enter first and last residue number of substrate:"
read -r SUB1 SUB2
awk -v f="$SUB1" -v g="$SUB2" 'f <= $6 && $6 <= g && !/TER/ && !/END/ {print $0}' $1_fixed_chain.pdb > substrate.pdb
echo 'TER' >> Substrate.pdb
cat Enzyme.pdb Metal1.pdb Metal2.pdb Oxygen_species.pdb Cosubstrate.pdb Substrate.pdb > $1_rearranged.pdb
echo 'END' >> $1_rearranged.pdb
#!/usr/bin/env bash
chimera $1_rearranged.pdb addh.cmd
mv fixed_h.pdb $1_H.pdb
pdb4amber -i $1_H.pdb -o $1_H_renumbered.pdb
echo "Enter atom name Of Metal Atoms to generate pdb:"
read M1 M2
awk -v var3="$M1" '$3== var3 {print $0}'  $1_H_renumbered.pdb > $M1.pdb
awk -v var4="$M2" '$3== var4 {print $0}'  $1_H_renumbered.pdb > $M2.pdb
echo "Enter res name of non standard residues to generate pdb:"
read NS1 NS2 NS3 NS4
awk -v var="$NS1" '$4== var {print $0}'  $1_H_renumbered.pdb > $NS1.pdb
awk -v var="$NS2" '$4== var {print $0}'  $1_H_renumbered.pdb > $NS2.pdb
awk -v var="$NS3" '$4== var {print $0}'  $1_H_renumbered.pdb > $NS3.pdb
awk -v var="$NS4" '$4== var {print $0}'  $1_H_renumbered.pdb > $NS4.pdb
echo "input the charge of $NS1:"
read C1
echo "input the charge of $NS2:"
read C2
echo "input the charge of $NS3:"
read C3
echo "input the charge of $NS4:"
read C4
antechamber -fi pdb -fo mol2 -i $NS1.pdb -o $NS1.mol2 -c bcc -pf y -nc $C1 -at amber
antechamber -fi pdb -fo mol2 -i $NS2.pdb -o $NS2.mol2 -c bcc -pf y -nc $C2 -at amber
antechamber -fi pdb -fo mol2 -i $NS3.pdb -o $NS3.mol2 -c bcc -pf y -nc $C3 -at amber
antechamber -fi pdb -fo mol2 -i $NS4.pdb -o $NS4.mol2 -c bcc -pf y -nc $C4 -at amber
echo "input the charge of $M1:"
read CM1
echo "input the charge of $M2:"
read CM2
metalpdb2mol2.py -i $M1.pdb -o $M1.mol2 -c $CM1
metalpdb2mol2.py -i $M2.pdb -o $M2.mol2 -c $CM2 
parmchk2 -i $NS1.mol2 -o $NS1.frcmod -f mol2
parmchk2 -i $NS2.mol2 -o $NS2.frcmod -f mol2
parmchk2 -i $NS3.mol2 -o $NS3.frcmod -f mol2
parmchk2 -i $NS4.mol2 -o $NS4.frcmod -f mol2
