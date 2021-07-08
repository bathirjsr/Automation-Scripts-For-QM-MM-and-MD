#!/bin/bash

#Execute with "./submit-track.sh -i input.in"

while getopts i: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
    *) echo "usage: $0 [-i] " >&2
       exit 1 ;;
esac
done


source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="RC-Optimization"

tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_dlfind.chm >& RC_dlfind.log &"
echo "$job $system $frame JOB started" | mail -s "Job Started" shobhitc@mtu.edu

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
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" shobhitc@mtu.edu
