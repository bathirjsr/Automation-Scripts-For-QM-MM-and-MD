#!/bin/sh

declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
for((i=1;i<=${#dirs[@]};i++))
do
cd ${dirs[i]}/MD/6-md/
    cpptraj.cuda <<EOF
parm ../3avr_solv.prmtop
trajin ../Analysis/6-md_auto.nc 1 50000 5
trajout 6-md_less.nc
run 
exit
EOF
cd ../../../
done