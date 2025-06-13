#!/bin/bash
while getopts i:s: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
    *) echo "usage: $0 [-i] [-s] " >&2
       exit 1 ;;
esac
done
if [ "$step" = "1fk" ]; then
source "${inp}"
jobname="RC-Frequency"
echo "Starting Frequency calculation"
mkdir Frequency_KIE
cp QM.dat Frequency_KIE/.
cp MM.dat Frequency_KIE/.
cp rc.opt.pdb Frequency_KIE/.
cp rc.opt.c Frequency_KIE/.
cp alpha Frequency_KIE/.
cp beta Frequency_KIE/.
cp control Frequency_KIE/.
cp parse_amber.tcl Frequency_KIE/.
cp rc.prmtop Frequency_KIE/.
cp input.in Frequency_KIE/.

cd Frequency_KIE/ || exit
job=$(pwd)
cat > RC_Freq_KIE.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rc.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rc.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rc.opt.c theory=dl_poly  : [ list \\
amber_prmtop_file=\$prmtop \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
mxexcl=2000  \\
mxlist=40000 \\
cutoff=1000 \\
use_pairlist = no \\
save_dl_poly_files = yes \\
exact_srf=yes \\
list_option=none ]

set atom_charges [ list_amber_atom_charges ]
##################
matrix dl-find.energy new volatile
dl-find coords=rc.opt.c list_option=full thermal=true nzero=1 active_atoms= \$qm_atoms \\
theory=hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp \\
hamiltonian= b3-lyp \\
scftype= uhf  ]  \\
mm_theory= dl_poly  : [ list \\
amber_prmtop_file= \$prmtop \\
exact_srf=yes \\
use_pairlist=no \\
mxlist=40000 \\
cutoff=1000 \\
mxexcl=2000  \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
conn= rc.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]
########

 exit
ENDOFFILE

echo "Executing KIE Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_Freq_KIE.chm >& RC_Freq_KIE.log &"
 
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

elif [ "$step" = "3fk" ]; then
source "${inp}"
jobname="TS-Frequency"
echo "Starting TS Frequency calculation"
mkdir Frequency_KIE
cp QM.dat Frequency_KIE/.
cp MM.dat Frequency_KIE/.
cp ts.opt.pdb Frequency_KIE/.
cp ts.opt.c Frequency_KIE/.
cp alpha Frequency_KIE/.
cp beta Frequency_KIE/.
cp control Frequency_KIE/.
cp parse_amber.tcl Frequency_KIE/.
cp myresidues.dat Frequency_KIE/.
cp ts.prmtop Frequency_KIE/.
cp input.in Frequency_KIE/.

cd Frequency_KIE/ || exit
job=$(pwd)
cat > TS_Freq_KIE.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id ts.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop ts.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=ts.opt.c theory=dl_poly  : [ list \\
amber_prmtop_file=\$prmtop \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
mxexcl=2000  \\
mxlist=40000 \\
cutoff=1000 \\
use_pairlist = no \\
save_dl_poly_files = yes \\
exact_srf=yes \\
list_option=none ]

set atom_charges [ list_amber_atom_charges ]
##################
matrix dl-find.energy new volatile
dl-find coords=ts.opt.c active_atoms= \$qm_atoms list_option=full thermal=true nzero=1 \\
theory=hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp \\
hamiltonian= b3-lyp \\
scftype= uhf  ]  \\
mm_theory= dl_poly  : [ list \\
amber_prmtop_file= \$prmtop \\
exact_srf=yes \\
use_pairlist=no \\
mxlist=40000 \\
cutoff=1000 \\
mxexcl=2000  \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
conn= ts.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]
########

 exit
ENDOFFILE

echo "Executing TS Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

tcsh -c "setenv PARNODES $nodes;nohup chemsh TS_Freq_KIE.chm >& TS_Freq_KIE.log &"
 
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
