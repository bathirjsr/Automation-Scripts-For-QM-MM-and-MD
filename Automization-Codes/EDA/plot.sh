#!/bin/bash
cp TS-RC_tot_avg.dat gnu.dat
sed "s/^[ \t]*//" -i gnu.dat

cat > plot.gnu <<ENDOFFILE
set encoding iso_8859_1
#set palette defined ( 0 "red", 1 "yellow", 2 "cyan", 3 "blue", 4 "magenta")
set terminal postscript eps enhanced color size 3in,3in 
set xlabel "Residue Number"
set ylabel "Energy (kcal/mol)"
set key right top
#set yrange [-3:3]
set xrange [0:466]
#set title "EDA"
set output "EDA.eps";
plot "gnu.dat" u (\$1):(\$2) with impulses t "T74A"
ENDOFFILE


for i in 247 249 319 450 451 452 461

do

awk -v x=$i '$1!=x{print}' gnu.dat > tmp && mv tmp gnu.dat

done

gnuplot plot.gnu
convert -density 300 EDA.eps EDA.png
