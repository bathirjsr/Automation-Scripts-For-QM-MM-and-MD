#!/bin/bash

#Syntax:
#nohup Submit_track.sh -i <inputfile> (not required for gaussian calculation) -s <step> -c <Chemshell .chm file or Gaussian .COM file> > Submit_track.log &
# steps available : -s Gauss (for Gaussian)
# -s 1,2,3,4 for RC,Scan,TS and PD opt respectively
while getopts i:s:c: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
	c) chm=${OPTARG};;
	*) echo "usage: $0 [-i] " >&2
       exit 1 ;;
esac
done

chmname=$(basename -- "$chm")
chmext="${chmname##*.}"
chmfile="${chmname%.*}"

if [ $step = "Gauss" ];
then
job=$(pwd)
host=$(hostname)
jobname="Gaussian-${chmfile}"

echo "$jobname at ${job} JOB started" | mail -s "Job Started ${jobname}" simahjsr@gmail.com
g16 < ${chmfile}.com > ${chmfile}.log

echo "RC Completed"
echo "Job Completed in ${host} on $(date) for ${jobname} at ${job} " | mail -s "Job Completed ${jobname}" simahjsr@gmail.com


elif [ $step = "1" ];
then
source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="RC-Optimization"

tcsh -c "setenv PARNODES $nodes;nohup chemsh ${chmfile}.chm >& ${chmfile}.log &"
echo "$job $system $frame JOB started" | mail -s "Job Started" simahjsr@gmail.com

sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;

echo "RC Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ $step = "2" ];
then
source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="RC-Scan"

tcsh -c "setenv PARNODES $nodes;nohup chemsh ${chmfile}.chm >& ${chmfile}.log &"
echo "$job $system $frame JOB started" | mail -s "Job Started" simahjsr@gmail.com

sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;

echo "RC Completed"


echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ $step = "3" ];
then
source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="3-TS_Opt"

tcsh -c "setenv PARNODES $nodes;nohup chemsh ${chmfile}.chm >& ${chmfile}.log &"
echo "$job $system $frame JOB started" | mail -s "Job Started-${jobname}" simahjsr@gmail.com

sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;

echo "RC Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ $step = "4" ];
then
source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="4-PD_Opt"

tcsh -c "setenv PARNODES $nodes;nohup chemsh ${chmfile}.chm >& ${chmfile}.log &"
echo "$job $system $frame JOB started" | mail -s "Job Started-${jobname}" simahjsr@gmail.com

sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;

echo "RC Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

fi
