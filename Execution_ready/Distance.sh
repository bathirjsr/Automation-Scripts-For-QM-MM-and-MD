#!/bin/bash
if [[ ! -e ../Analysis ]]; then
    mkdir ../Analysis
elif [[ ! -d ../Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi

declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
cd ../Analysis || exit 
for((i=1;i<=${#dirs[@]};i++))
do
    cpptraj.cuda <<EOF
parm ../Mutations/${dirs[i]}/MD/3avr_SO_solv.prmtop
trajin ../Mutations/${dirs[i]}/MD/Analysis/6-md_auto.nc
distance :OY1@O2 :A11@C2 out ${dirs[i]}_O2_C2_dist.dat time 0.02
run 
exit
EOF
gnuplot <<EOF
set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "Distance ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:552]

set output "${dirs[i]}O2_C2.eps";
p "${dirs[i]}_O2_C2_dist.dat" w l lc rgb "red" lw 1.0 notitle, \

EOF
done