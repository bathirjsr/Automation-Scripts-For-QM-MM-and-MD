#!/bin/bash
src=$(pwd)
declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
for((i=1;i<=${#dirs[@]};i++))
do
cd "${dirs[i]}"/MD/6-md/ || continue 1
    cpptraj.cuda <<EOF
parm ../3avr_SO_solv.prmtop
trajin ../Analysis/6-md_auto.nc 1 50000 5
trajout 6-md_less.nc
run 
clear all
parm ../3avr_SO_solv.prmtop
trajin 6-md_less.nc 5001 10000
autoimage
trajout 6-md_mmpbsa.nc
run
exit
EOF
cd "${src}" || exit 

done