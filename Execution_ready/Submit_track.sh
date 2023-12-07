#!/bin/bash

#Execute with "./submit-track.sh -i input.in"

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
source "${inp}"
chmname=$(basename -- "$chm")
chmext="${chmname##*.}"
chmfile="${chmname%.*}"

if [ "$step" = "Gauss" ];
then
job=$(pwd)
host=$(hostname)
jobname="Gaussian-${chmfile}"

echo "$jobname at ${job} JOB started" | mail -s "Job Started ${jobname}" simahjsr@gmail.com
g16 < "${chmfile}".com > "${chmfile}".log

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${jobname} at ${job} " | mail -s "Job Completed ${jobname}" simahjsr@gmail.com


elif [ "$step" = "1" ];
then
source "${inp}"
job=$(pwd)
host=$(hostname)
jobname="RC-Optimization"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "1s" ];
then 
job=$(pwd)
host=$(hostname)
jobname="RC_SP"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "1f" ];
then
job=$(pwd)
host=$(hostname)
jobname="RC_Freq"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "2" ];
then
job=$(pwd)
host=$(hostname)
jobname="RC-Scan"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "3" ];
then
job=$(pwd)
host=$(hostname)
jobname="3-TS_Opt"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "3s" ];
then
job=$(pwd)
host=$(hostname)
jobname="TS_SP"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "3f" ];
then
job=$(pwd)
host=$(hostname)
jobname="TS_Freq"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "4" ];
then
job=$(pwd)
host=$(hostname)
jobname="4-PD_Opt"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "4s" ];
then
job=$(pwd)
host=$(hostname)
jobname="PD_SP"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "4f" ];
then
job=$(pwd)
host=$(hostname)
jobname="PD_Freq"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_Scan"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_TS" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_TS"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_PD" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_PD"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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

echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_TS_SP" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_TS-Single Point"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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
echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_TS_Freq" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_TS-Frequency"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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
echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_PD_SP" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_PD-Single Point"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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
echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com

elif [ "$step" = "RB_PD_Freq" ];
then
job=$(pwd)
host=$(hostname)
jobname="RB_PD-Frequency"

omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

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
echo "${jobname} Completed"
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi
