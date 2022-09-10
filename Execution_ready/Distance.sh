#!/bin/sh
if [[ ! -e Analysis ]]; then
    mkdir Analysis
elif [[ ! -d Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi

declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
cd Analysis || exit 
for((i=1;i<=${#dirs[@]};i++))
do
    cpptraj.cuda <<EOF
parm ../${dirs[i]}/MD/3avr_solv.prmtop
trajin ../${dirs[i]}/MD/Analysis/6-md_auto.nc
distance :OY1@O1 :M3L@CM1 out ${dirs[i]}_CM1_dist.dat time 0.02
distance :OY1@O1 :M3L@CM2 out ${dirs[i]}_CM2_dist.dat time 0.02
distance :OY1@O1 :M3L@CM3 out ${dirs[i]}_CM3_dist.dat time 0.02
distance :OY1@O1 :M3L@NZ out ${dirs[i]}_NZ_dist.dat time 0.02
run 
exit
EOF
done