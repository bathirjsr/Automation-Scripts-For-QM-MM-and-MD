#!/bin/bash
while getopts i:s:a:n: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
	a) A=${OPTARG};;
	n) increment=${OPTARG};;
	*) echo "usage: $0 [-i] [-s] [-a] [-b] [-t] [-p]" >&2
       exit 1 ;;
esac
done

if [ "$step" = "2" ]; then
source "${inp}"
jobname="Scan Calculation"
    if [[ ! -e TS_Sampling ]]; then
        mkdir TS_Sampling
    elif [[ ! -d TS_Sampling ]]; then
        echo "2-Scan already exists but is not a directory" 1>&2
    fi

cp *_${a}* TS_Sampling/.
cp scan.prmtop TS_Sampling/.
cp control TS_Sampling/.
cp parse_amber.tcl TS_Sampling/.
cp QM.dat TS_Sampling/.
cp MM.dat TS_Sampling/.
cp input.in TS_Sampling/.
cp RC_Scan.chm TS_Sampling/.

cd TS_Sampling/ || exit
gunzip *.gz
mv scan_${a}.c scan_0.c
mv scan_${a}.pdb scan_0.pdb
sed -i "1s/set incr -0.1/set incr ${increment}/" RC_Scan.chm
job=$(pwd)

echo "Executing Scan calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_Scan.chm >& RC_Scan.log &"
 
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5

while ps -p "${calc}" > /dev/null;do sleep 1;done;
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed ${system} ${host}" simahjsr@gmail.com


elif [ "$step" = "RB" ]; then
source "${inp}"
jobname="RB-Scan"
if [[ ! -e  TS_Sampling]]; then
    mkdir TS_Sampling
elif [[ ! -d TS_Sampling ]]; then
    echo "TS_Sampling already exists but is not a directory" 1>&2
fi

echo "Starting RB Scan"
cp pd.opt.c TS_Sampling/.
cp pd.opt.pdb TS_Sampling/.
cp pd.prmtop TS_Sampling/.
cp alpha TS_Sampling/.
cp beta TS_Sampling/.
cp control TS_Sampling/.
cp parse_amber.tcl TS_Sampling/.
cp QM.dat TS_Sampling/.
cp MM.dat TS_Sampling/.
cp myresidues.dat TS_Sampling/.
cp input.in TS_Sampling/.

cd TS_Sampling/ || exit
sed -i "1s/pd.pdb/rebound_0.pdb/" myresidues.dat
sed -i "2s/target=QM/target=fatone/" myresidues.dat
cp pd.opt.c rebound_0.c
cp pd.opt.pdb rebound_0.pdb
cp pd.prmtop rebound.prmtop
job=$(pwd)


omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_Scan.chm >& RB_Scan.log &"
 
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed ${system} ${host}" simahjsr@gmail.com

fi