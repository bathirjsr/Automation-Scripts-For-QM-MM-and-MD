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
wd=$(pwd)
for((i=1;i<=${#dirs[@]};i++))
do
cd ../Data/"${dirs[i]}"/QMMM/ || exit
declare -a qmdirs
j=1
for d in */
do
    qmdirs[j++]="${d%/}"
done

    for((j=1;j<=${#qmdirs[@]};j++))
    do
        dirname=$(basename -- "${qmdirs[j]}")
        dirnumber="${dirname##*Frame}"
        echo "${dirnumber}"
        echo "$j" "${qmdirs[j]}"

    cpptraj.cuda <<EOF
    parm Frame${dirnumber}/1-RC_Opt/rc.prmtop
    trajin Frame${dirnumber}/1-RC_Opt/rc.opt.pdb
    distance GLU_O1_${dirnumber} :GU1@OE1 :FE1 out ${wd}/${dirs[i]}_${dirnumber}_FE_RC_dist.dat
    distance GLU_O2_${dirnumber} :GU1@OE2 :FE1 out ${wd}/${dirs[i]}_${dirnumber}_FE_RC_dist.dat
    distance SUC_O1_${dirnumber} :SC1@O1 :FE1 out ${wd}/${dirs[i]}_${dirnumber}_FE_RC_dist.dat
    distance SUC_O2_${dirnumber} :SC1@O2' :FE1 out ${wd}/${dirs[i]}_${dirnumber}_FE_RC_dist.dat

    run 
    exit
EOF
    done
cd "${wd}" || exit
done