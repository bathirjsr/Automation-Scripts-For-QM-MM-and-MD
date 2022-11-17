#!/bin/bash
if [[ ! -e ../Analysis ]]; then
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
wd=$(pwd)
for((i=1;i<=${#dirs[@]};i++))
do
    cpptraj.cuda <<EOF
    parm ../"${dirs[i]}"/MD/EFE_solv.prmtop
    trajin ../"${dirs[i]}"/MD/Analysis/6-md_auto.nc
    distance C5 :346@O1 :FE1 out ${wd}/${dirs[i]}_FE_C5.dat time 0.02
    run 
    exit
EOF
    done
cd "${wd}" || exit