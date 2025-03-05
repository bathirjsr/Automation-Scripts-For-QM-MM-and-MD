#! /bin/bash
#Execution Syntax: QMMM.sh -i input.in -s <stepnumber> -a <atomnumber1> -b <atomnumber2> -t <transitionstate> -p <product state>  
#(input -a and -b only for Scan calculation and -t for TS optimization and -p for Product Optimization)
#Edit the script for changing the path for parse_amber.tcl file
#Change the vmd atomselect tcl script according to your substrate and system(QM region and MM region)
#Make sure to create an input file (input.in)
#s 0 QM and MM Modelling and Creating Files for RC_OPT
#s 1 RC Optimization
#s 1f RC Frequency
#s 1s RC Single Point Calculation
#s 2 Scan (HAT)
#s 3 TS Optimization
#s 3f TS Frequency
#s 3s TS Single Point Calculation
#s 4 PD Optimization
#s 4f PD Frequency
#s 4s PD Single Point Calculation
while getopts i:s:f: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
    f) func=${OPTARG};;
    *) echo "usage: $0 [-i] [-s] [-f]" >&2
       exit 1 ;;
esac
done

func_up="${func^^}"

user=$USER
host=$(hostname)

if [ "$step" = "1s" ]; then

source "${inp}"
jobname="RC-Single Point Energy"
echo "Starting Single Point Calculation"
mkdir ${func_up}
cp QM.dat ${func_up}/.
cp MM.dat ${func_up}/.
cp rc.opt.pdb ${func_up}/.
cp rc.opt.c ${func_up}/.
cp parse_amber.tcl ${func_up}/.
cp myresidues.dat ${func_up}/.
cp rc.prmtop ${func_up}/.
cp input.in ${func_up}/.

cd $func_up/ || exit
sed -i "1s/rc.pdb/rc.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RC_SP.chm <<ENDOFFILE
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

# Single Point Energy
energy coords= \${sys_name_id}.c  energy= \${sys_name_id}.e \\
theory=hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp/ \\
hamiltonian= $func \\
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


####
exit
ENDOFFILE
nohup chemsh RC_SP.chm > RC_SP.log &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Terminated" RC_SP.log)" -ge 1 ]; then
		echo "RC Terminated by User"
		exit
	else
		echo "SP Terminated normally"
	fi
echo "SP Terminated.Now Running Define"
define <<EOF


a coord
*
no
b all def2-TZVP
*
eht
y
$charge
n
u $unp
*
n
scf
iter
900

dft
on
func $func

*
EOF

echo "Executing Single Point Energy Calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_SP.chm >& RC_SP.log &"
 
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
if [ "$(grep -c "SCF convergence criteria cannot be satisfied in dscf" RC_SP.log)" -ge 1 ]; then
    echo "DSCF Failed. Now changing SCF iterlimit and Restarting"
    sed -i "s/$scfiterlimit      100/$scfiterlimit      900/" control
    omit=$(pidof chemsh.x)
	string="${omit//${IFS:0:1}/,}"
    tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_SP.chm >& RC_SP.log &"
	echo "$job $system $frame JOB SCF Error and Restarted" | mail -s "Job Restarted" simahjsr@gmail.com
	sleep 5
	if [ -z "$string" ]
	    then
	    calc=$(pidof chemsh.x)
	    else
	    calc=$(pidof -o "${string}" chemsh.x)    
	fi
	sleep 5
	while ps -p "${calc}" > /dev/null;do sleep 1;done;
	echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
else
        echo "RC SP Completed"
        echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi

elif [ "$step" = "3s" ]; then
source "${inp}"
jobname="TS-Single Point Energy"
echo "Starting Single Point Calculation"
mkdir ${func_up}
cp QM.dat ${func_up}/.
cp MM.dat ${func_up}/.
cp ts.opt.pdb ${func_up}/.
cp ts.opt.c ${func_up}/.
cp parse_amber.tcl ${func_up}/.
cp myresidues.dat ${func_up}/.
cp ts.prmtop ${func_up}/.
cp input.in ${func_up}/.

cd ${func_up}/ || exit
sed -i "1s/ts.pdb/ts.opt.pdb/" myresidues.dat
job=$(pwd)
cat > TS_SP.chm <<ENDOFFILE
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

# Single Point Energy
energy coords= \${sys_name_id}.c  energy= \${sys_name_id}.e \\
theory=hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp/ \\
hamiltonian= $func \\
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


####
exit
ENDOFFILE
nohup chemsh TS_SP.chm > TS_SP.log &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Terminated" TS_SP.log)" -ge 1 ]; then
		echo "TS_SP Terminated by User"
		exit
	else
		echo "TS_SP Terminated normally"
	fi
echo "SP Terminated.Now Running Define"
define <<EOF


a coord
*
no
b all def2-TZVP
*
eht
y
$charge
n
u $unp
*
n
scf
iter
900

dft
on
func $func

*
EOF

echo "Executing TS Single Point Energy Calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh TS_SP.chm >& TS_SP.log &"
 
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
if [ "$(grep -c "SCF convergence criteria cannot be satisfied in dscf" TS_SP.log)" -ge 1 ]; then
    echo "DSCF Failed. Now changing SCF iterlimit and Restarting"
    sed -i "s/$scfiterlimit      100/$scfiterlimit      900/" control
    omit=$(pidof chemsh.x)
	string="${omit//${IFS:0:1}/,}"
    tcsh -c "setenv PARNODES $nodes;nohup chemsh TS_SP.chm >& TS_SP.log &"
	echo "$job $system $frame JOB SCF Error and Restarted" | mail -s "Job Restarted" simahjsr@gmail.com
	sleep 5
	if [ -z "$string" ]
	    then
	    calc=$(pidof chemsh.x)
	    else
	    calc=$(pidof -o "${string}" chemsh.x)    
	fi
	sleep 5
	while ps -p "${calc}" > /dev/null;do sleep 1;done;
	echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
else
        echo "TS SP Completed"
        echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi

elif [ "$step" = "4s" ]; then
source "${inp}"
jobname="PD-Single Point Energy"
echo "Starting PD Single Point Calculation"
mkdir ${func_up}
cp QM.dat ${func_up}/.
cp MM.dat ${func_up}/.
cp pd.opt.pdb ${func_up}/.
cp pd.opt.c ${func_up}/.
cp parse_amber.tcl ${func_up}/.
cp myresidues.dat ${func_up}/.
cp pd.prmtop ${func_up}/.
cp input.in ${func_up}/.

cd ${func_up}/ || exit
sed -i "1s/pd.pdb/pd.opt.pdb/" myresidues.dat
job=$(pwd)
cat > PD_SP.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id pd.opt
set prmtop pd.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=pd.opt.c theory=dl_poly  : [ list \\
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

# optimize geometry with distance A-B fixed
energy coords= \${sys_name_id}.c  energy= \${sys_name_id}.e \\
theory=hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp/ \\
hamiltonian= $func \\
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
conn= pd.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]


####
exit
ENDOFFILE
nohup chemsh PD_SP.chm > PD_SP.log &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;

if [ "$(grep -c "Terminated" PD_SP.log)" -ge 1 ]; then
		echo "PD_SP Terminated by User"
		exit
	else
		echo "PD_SP Terminated normally"
	fi

echo "SP Terminated.Now Running Define"
define <<EOF


a coord
*
no
b all def2-TZVP
*
eht
y
$charge
n
u $unp
*
n
scf
iter
900

dft
on
func $func

*
EOF

echo "Executing PD Single Point Energy Calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

tcsh -c "setenv PARNODES $nodes;nohup chemsh PD_SP.chm >& PD_SP.log &"
 
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;

if [ "$(grep -c "SCF convergence criteria cannot be satisfied in dscf" PD_SP.log)" -ge 1 ]; then
    echo "DSCF Failed. Now changing SCF iterlimit and Restarting"
    sed -i "s/$scfiterlimit      100/$scfiterlimit      900/" control
    omit=$(pidof chemsh.x)
	string="${omit//${IFS:0:1}/,}"
    tcsh -c "setenv PARNODES $nodes;nohup chemsh PD_SP.chm >& PD_SP.log &"
	echo "$job $system $frame JOB SCF Error and Restarted" | mail -s "Job Restarted" simahjsr@gmail.com
	sleep 5
	if [ -z "$string" ]
	    then
	    calc=$(pidof chemsh.x)
	    else
	    calc=$(pidof -o "${string}" chemsh.x)    
	fi
	sleep 5
	while ps -p "${calc}" > /dev/null;do sleep 1;done;
	echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
else
        echo "PD SP Completed"
        echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi
fi

