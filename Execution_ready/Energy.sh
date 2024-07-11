#!/bin/sh
if [ "$1" = "RC" ]
then
B1=$(grep 'Final converged energy' ${1}_dlfind.log|awk '{printf "%5.12f", $NF}')
elif [ "$1" = "TS" ]
then
grep 'frequencies' Frequency/TS_Freq.log | head -n 4
else
B1=$(grep 'Final converged energy' ${1}_Opt.log|awk '{printf "%5.12f", $NF}')
fi
B2=$(grep 'Energy (     hybrid):' SP/${1}_SP.log|awk '{printf "%5.12f", $(NF-1)}')
ZPE_KJ=$(grep 'total ZPE' Frequency/${1}_Freq.log|awk '{printf "%7.5f", $(NF-1)}')
ZPE=$(grep 'total ZPE' Frequency/${1}_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
B3=$(awk -v t="$B2" -v r="$ZPE" 'BEGIN{printf "%5.12f", (t + r)}')

echo ${1}
echo "B1 = ${B1}"
echo "B2 = ${B2}"
echo "ZPE_KJ = ${ZPE_KJ}"
echo "ZPE = ${ZPE}"
echo "B3 = ${B3}"