#!/bin/bash


##########################################
##        Define your dataset           ##
##         And your outfile name        ##
##########################################

infileA=WT_protein_sys_hbond_avg_WTagain.dat

##########################################
##         Predefined variables         ##
##########################################

## You can change the file names, but
## it'll be annoying to change the variables

outfile1A=hbond-clean-1A.dat
outfile2A=hbond-clean-2A.dat
outfile3A=hbond-clean-3A.dat

##########################################
##              Fileset A               ##
##  Make some files; do some analysis   ##
##########################################

## Clean the data. Remove lines less than
## 1% and print file with the
## 3 columns you want; keep header
## 1=Acceptor 3=Donor 5=Frac

awk 'NR == 1 {print $1,$3,$5}; NR > 1 { if ($5>0.0099) print $1, $3, $5 }' $infileA > $outfile1A

## Sum duplicate acceptor/donor columns

awk 'NR == 1; {s1[$1,$2] = $1; s2[$1,$2] = $2; s3[$1,$2] += $3} END { for (i in s3) print s1[i], s2[i], s3[i]}' $outfile1A > $outfile2A

## Clean up the output. Make alphabetical order
## by acceptor then by donor and print that
## in clean columns (with left-aligned AAs)

sort -nrk3 $outfile2A | awk '{ printf "%-15s %-15s %8s\n", $1, $2, $3 }' > $outfile3A
