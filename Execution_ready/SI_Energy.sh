#! /bin/bash
declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"

for((i=1;i<=${#dirs[@]};i++))
do
  dirname=$(basename -- "${dirs[i]}")
  dirnumber="${dirname##*Frame}"
  echo "${dirnumber}"
  echo "$i" "${dirs[i]}"
######RC##########
  RC=$(grep 'Final converged energy' "${dirs[i]}"/1-RC_Opt/RC_dlfind.log|awk '{printf "%5.12f", $NF}') 
  RC_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/1-RC_Opt/SP/RC_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  RC_ZPE=$(grep 'total ZPE' "${dirs[i]}"/1-RC_Opt/Frequency/RC_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  RC_B2_ZPE=$(awk -v t="$RC_SP" -v r="$RC_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
#######TS###########
  TS=$(grep 'Final converged energy' "${dirs[i]}"/3-TS_Opt/TS_Opt.log|awk '{printf "%5.12f", $NF}')
  TS_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/3-TS_Opt/SP/TS_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  TS_ZPE=$(grep 'total ZPE' "${dirs[i]}"/3-TS_Opt/Frequency/TS_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  TS_B2_ZPE=$(awk -v t="$TS_SP" -v r="$TS_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
#######PD###########
  PD=$(grep 'Final converged energy' "${dirs[i]}"/4-PD_Opt/PD_Opt.log|awk '{printf "%5.12f", $NF}')
  PD_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/4-PD_Opt/SP/PD_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  PD_ZPE=$(grep 'total ZPE' "${dirs[i]}"/4-PD_Opt/Frequency/PD_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  PD_B2_ZPE=$(awk -v p="$PD_SP" -v r="$PD_ZPE" 'BEGIN{printf "%5.12f", (p + r)}')

cat > Supplementary_Energy_"${dirnumber}".txt <<EOF
  ${dirnumber} RC
  QM(B1)/MM = ${RC}
  QM(B2+ZPE)/MM = ${RC_B2_ZPE}
  ${dirnumber} TS
  QM(B1)/MM = ${TS}
  QM(B2+ZPE)/MM = ${TS_B2_ZPE}
  ${dirnumber} PD
  QM(B1)/MM = ${PD}
  QM(B2+ZPE)/MM = ${PD_B2_ZPE}
EOF
done
