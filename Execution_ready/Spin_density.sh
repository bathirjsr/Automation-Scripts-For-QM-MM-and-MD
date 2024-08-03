#!/bin/bash
for d in *_Opt
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
home=$(pwd)
for((i=1;i<=${#dirs[@]};i++))
do 
    cd "${dirs[i]}" || exit	
    proper << EOF
pop
log on
mulliken
end
grid
dens
q
EOF
cd $home || exit
done