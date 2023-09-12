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
while getopts i:s:a:b:c:d:t:p: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
	a) A=${OPTARG};;
	b) B=${OPTARG};;
        c) C=${OPTARG};;
	d) D=${OPTARG};;
	t) transition=${OPTARG};;
	p) product=${OPTARG};;	
    *) echo "usage: $0 [-i] [-s] [-a] [-b] [-t] [-p]" >&2
       exit 1 ;;
esac
done


if [ "$1" = "help" ];
then
echo " 
!!!!Follow the Guidelines properly !!!!!
Execution Syntax: QMMM.sh -i input.in -s <stepnumber> -a <atomnumber1> -b <atomnumber2> -t <transitionstate> -p <product state>  
(input -a and -b only for Scan calculation and -t for TS optimization and -p for Product Optimization)
Edit the script for changing the path for parse_amber.tcl file
Change the vmd atomselect tcl script according to your substrate and system(QM region and MM region)
Make sure to create an input file (input.in)

Contents of Input File

#Input for QMMM Modelling
parsefile=				#Parse_amber.tcl File path
system=                      		#System(Filename of the parameter)
parm=                        		#Parameter File path
frame=                             	#Frame Number
trajin=                  		#Non-Autoimaged Trajectory File
resname=\"FE1 OY1 SC1 GU1 HD1 HD2\"     #RC Residues
substrate=M3L                           #Substrate Residue
numberofres=1-552                       #Residue range
basis=def2-SVP                          #basis
charge=0                                #Charge of the system
unp=4                                   #Unpaired electrons in Iron center
nodes=20                                #Number of processors
tleapinput=				#tleap input file path used for building the MD files

Steps of QMMM Calculations (Execution Folder given in Brackets)
-s 0 QM and MM Modelling and Creating Files for RC_OPT (6-md Folder)
-s 1 RC Optimization (1-RC_Opt Folder)
-s 1f RC Frequency (1-RC_Opt Folder)
-s 1s RC Single Point Calculation (1-RC_Opt Folder)
-s 2 Scan (HAT) (1-RC_Opt Folder)
-s 3 TS Optimization (2-Scan Folder)
-s 3f TS Frequency (3-TS_Opt Folder)
-s 3s TS Single Point Calculation (3-TS_Opt Folder)
-s 4 PD Optimization (2-Scan Folder)
-s 4f PD Frequency (4-PD Folder)
-s 4s PD Single Point Calculation (4-PD Folder)
"
exit
fi

user=$USER
host=$(hostname)

if [ "$step" = "0" ]; then

if [ -z "$inp" ]; then 

parm=$(zenity --file-selection --file-filter=*solv.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
trajin=$(zenity --file-selection --file-filter=*.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
resname=$(zenity --entry --title="Active Site except Substrate (Eg. HD1 OY1 )")
[[ "$?" != "0" ]] && exit 1
substrate=$(zenity --entry --title="Substrate Residues (Eg. M3L or LAR )")
[[ "$?" != "0" ]] && exit 1
tleapinput=$(zenity --file-selection --file-filter=*tleap.in --title="Tleap Input file (Eg. 3avr_tleap.in )")
[[ "$?" != "0" ]] && exit 1
parsefile=$(zenity --file-selection --file-filter=*.tcl --title="Parse_amber File")
[[ "$?" != "0" ]] && exit 1
numberofres=$(zenity --entry --title="Range of residues (Eg. 1-552)")
[[ "$?" != "0" ]] && exit 1
frame=$(zenity --entry --title="Frame Number")
[[ "$?" != "0" ]] && exit 1
basis=$(zenity --entry --title="Basis Set (Eg. def2-SVP)")
[[ "$?" != "0" ]] && exit 1
charge=$(zenity --entry --title="Total charge of the QM region")
[[ "$?" != "0" ]] && exit 1
unp=$(zenity --entry --title="Number of Unpaired electrons")
[[ "$?" != "0" ]] && exit 1
nodes=$(zenity --entry --title="Number of CPUs")
[[ "$?" != "0" ]] && exit 1

{ 
date
echo "parm=""${parm}"
echo "trajin=""${trajin}"
echo "resname=""${resname}"
echo "substrate=""${substrate}"
echo "tleapinput=""${tleapinput}"
echo "parsefile=""${parsefile}"
echo "numberofres=""${numberofres}"
echo "frame=""${frame}"
echo "basis=""${basis}"
echo "charge=""${charge}"
echo "unp=""${unp}"
echo "nodes=""${nodes}"
} >> QMMM_EFE.log
{
echo "parm=""${parm}"
echo "trajin=""${trajin}"
echo "resname=""\"${resname}\""
echo "substrate=""${substrate}"
echo "tleapinput=""${tleapinput}"
echo "parsefile=$(pwd)/parse_amber.tcl"
echo "numberofres=""${numberofres}"
echo "frame=""${frame}"
echo "basis=""${basis}"
echo "charge=""${charge}"
echo "unp=""${unp}"
echo "nodes=""${nodes}"
} > input.in

cp "$parsefile" .
gedit parse_amber.tcl "$tleapinput"							#Check for correct path of parse_amber.tcl
echo "Did you check parse_amber.tcl and made sure atoms are grouped correctly as such in tleap input?"
read -r parse_amber
if [ "$parse_amber" = "yes" ]; then
echo "Modelling proceeds"
else
exit
fi

fi
{ 
date
echo "parm=""${parm}"
echo "trajin=""${trajin}"
echo "resname=""${resname}"
echo "substrate=""${substrate}"
echo "tleapinput=""${tleapinput}"
echo "parsefile=""${parsefile}"
echo "numberofres=""${numberofres}"
echo "frame=""${frame}"
echo "basis=""${basis}"
echo "charge=""${charge}"
echo "unp=""${unp}"
echo "nodes=""${nodes}"
} >> QMMM_EFE.log
source "${inp}"
parmname=$(basename -- "$parm")
#parmext="${parmname##*.}"
system="${parmname%.*}"

#CREATING INPUT FILES FOR CPPTRAJ FOR PREPARING RC COMPLEX FILES
cat > ReactionComplex_"${frame}".in << ENDOFFILE
parm ${parm}
trajin ${trajin} ${frame} ${frame}
autoimage
trajout ${frame}.pdb
run
clear all
parm ${parm}
trajin ${frame}.pdb
reference ${frame}.pdb
strip :Na+,Cl-
strip !(:$numberofres<:12.0) outprefix stripped12
trajout stripped12.${system}.pdb
run
clear all
parm stripped12.${system}.prmtop
trajin stripped12.${system}.pdb
trajout rc_${frame}.pdb
trajout rc_${frame}.rst restart
run
exit
ENDOFFILE
cat ReactionComplex_"${frame}".in

#CREATING RC COMPLEX FILES
nohup cpptraj -i ReactionComplex_"${frame}".in > ReactionComplex_"${frame}".out &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Error" ReactionComplex_"${frame}".out)" -ge 1 ]; then
                echo "Cpptraj Error"
                exit
        else
                echo "Generated Frame PDB"
fi

cp stripped12."${system}".prmtop rc_"${frame}".prmtop
sed -i "9s/1/0/" rc_"${frame}".prmtop

#MAKING QMMM MODEL
echo "Creating QMMM Model"
cat > QM_MM_"${frame}".tcl <<ENDOFFILE
mol load pdb rc_${frame}.pdb
atomselect top "same residue as (within 8 of (resname $resname $substrate))"
atomselect0 num
atomselect0 writepdb MM_${frame}.pdb
set myfile [open mm_${frame}.txt w]
puts \$myfile [atomselect0 list]
close \$myfile
atomselect top "(resname $resname and not backbone and not type HA H) or (resname $substrate and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)"
atomselect1 num
atomselect1 writepdb QM_${frame}.pdb
atomselect1 writexyz QM_${frame}.xyz
set myfile1 [open qm_${frame}.txt w]
puts \$myfile1 [atomselect1 list]
close \$myfile1
exit
ENDOFFILE

echo "Using rc.pdb"
echo "Using Residues:${resname}"
echo "Using Substrate:${substrate}"

vmd -dispdev text -e QM_MM_"${frame}".tcl

vmd QM_"${frame}".pdb
echo "Does QM Model looks correct?"
read -r decision_QM
if [ "$decision_QM" = "yes" ]; then
echo "QM Modelling Success"
else
exit
fi

vmd MM_"${frame}".pdb
echo "Does MM Model looks correct?"
read -r decision_MM
if [ "$decision_MM" = "yes" ]; then
echo "MM Modelling Success"
else
exit
fi
cat > residues_"${frame}".dat <<EOF
EOF
for x in ${resname} ${substrate} ;
do
awk -v i="${x}" '$4==i {resname=$4;resid=$5} END{print resname resid}' rc_"${frame}".pdb >> residues_"${frame}".dat
done
myresidues=$(awk 'BEGIN { ORS = " " } { print }' residues_"${frame}".dat )
echo "myresidues=""\"${myresidues}\"" >> input.in

cat > addone-awk <<ENDOFFILE

BEGIN{
   RS = " "
}

{
a = \$1
++a
printf( "%d " , a )
}

ENDOFFILE
awk -f addone-awk mm_"${frame}".txt > MM_"${frame}".dat
sed -i '1s/^/set active {/' MM_"${frame}".dat
echo "}" >> MM_"${frame}".dat
awk -f addone-awk qm_"${frame}".txt > QM_"${frame}".dat
sed -i '1s/^/set qm_atoms {/' QM_"${frame}".dat
echo "}" >> QM_"${frame}".dat

#MAKING DIRECTORIES
if [[ ! -e ../../QMMM ]]; then
    mkdir ../../QMMM
elif [[ ! -d ../../QMMM ]]; then
    echo "QMMM already exists but is not a directory" 1>&2
fi

if [[ ! -e ../../QMMM/Frame"${frame}" ]]; then
    mkdir ../../QMMM/Frame"${frame}"
elif [[ ! -d ../../QMMM/Frame"${frame}" ]]; then
    echo "QMMM already exists but is not a directory" 1>&2
fi

if [[ ! -e ../../QMMM/Frame"${frame}"/1-RC_Opt ]]; then
    mkdir ../../QMMM/Frame"${frame}"/1-RC_Opt
elif [[ ! -d ../../QMMM/Frame"${frame}"/1-RC_Opt ]]; then
    echo "1-RC_Opt already exists but is not a directory" 1>&2
fi

#COPYING FILES TO THE RC_Opt DIRECTORIES
cp rc_"${frame}".pdb ../../QMMM/Frame"${frame}"/1-RC_Opt/rc.pdb
cp rc_"${frame}".rst ../../QMMM/Frame"${frame}"/1-RC_Opt/rc.rst
cp rc_"${frame}".prmtop ../../QMMM/Frame"${frame}"/1-RC_Opt/rc.prmtop
cp QM_"${frame}".dat ../../QMMM/Frame"${frame}"/1-RC_Opt/QM.dat
cp MM_"${frame}".dat ../../QMMM/Frame"${frame}"/1-RC_Opt/MM.dat
cp parse_amber.tcl ../../QMMM/Frame"${frame}"/1-RC_Opt/.
cp input.in ../../QMMM/Frame"${frame}"/1-RC_Opt/.
cd ../../QMMM/Frame"${frame}"/1-RC_Opt || exit

cat > RC_dlfind.chm <<ENDOFFILE
# adenine - Amber example with polarisation turned off
# hybrid with electrostaic embedding
global sys_name_id
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id rc
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rc.prmtop
set inpcrd rc.rst
load_amber_coords inpcrd=\$inpcrd prmtop=\$prmtop coords=rc.c
# # for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rc.c theory=dl_poly  : [ list \\
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

# optimize geometry
dl-find coords=rc.c maxcycle=999 active_atoms= \$active residues= \$myresidues list_option=full result=\${sys_name_id}.opt.c \\
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
conn= rc.c \\
save_dl_poly_files = yes \\
list_option=none ]]

####
# save structure
read_pdb  file= \${sys_name_id}.pdb  coords=hybrid.dl_poly.coords
write_pdb file= \${sys_name_id}.opt.pdb coords= \${sys_name_id}.opt.c
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.turbomole.coords

  exit

ENDOFFILE


elif [ "$step" = "1" ]; then
source "${inp}"
job=$(pwd)
jobname="RC-Optimization"
nohup chemsh RC_dlfind.chm > RC_dlfind.log &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Terminated" RC_dlfind.log)" -ge 1 ]; then
		echo "RC Terminated by User"
		exit
	else
		echo "RC Terminated normally"
	fi
echo "RC Terminated.Now Running Define"
define <<EOF


a coord
*
no
b all def2-SVP
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
func b3-lyp

*
EOF
echo "Executing RC Optimization"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_dlfind.chm >& RC_dlfind.log &"
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
if [ "$(grep -c "Energy evaluation failed" RC_dlfind.log)" -ge 1 ]; then
        echo "DSCF Failed. Now changing SCF iterlimit and Restarting"
        sed -i "s/$scfiterlimit      100/$scfiterlimit      900/" control
        omit=$(pidof chemsh.x)
	string="${omit//${IFS:0:1}/,}"
        tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_dlfind.chm >& RC_dlfind.log &"
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
        echo "RC Completed"
        echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi

elif [ "$step" = "1f" ]; then
source "${inp}"
jobname="RC-Frequency"
echo "Starting Frequency calculation"
mkdir Frequency
cp QM.dat Frequency/.
cp MM.dat Frequency/.
cp rc.opt.pdb Frequency/.
cp rc.opt.c Frequency/.
cp alpha Frequency/.
cp beta Frequency/.
cp control Frequency/.
cp parse_amber.tcl Frequency/.
cp rc.prmtop Frequency/.
cp input.in Frequency/.

cd Frequency/ || exit
sed -i "1s/rc.pdb/rc.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RC_Freq.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rc.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
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
force coords=rc.opt.c active_atoms= \$qm_atoms hessian=h formula=twopoint \\
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

echo "Executing Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_Freq.chm >& RC_Freq.log &"
 
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

elif [ "$step" = "1s" ]; then
source "${inp}"
jobname="RC-Single Point Energy"
echo "Starting Single Point Calculation"
mkdir SP
cp QM.dat SP/.
cp MM.dat SP/.
cp rc.opt.pdb SP/.
cp rc.opt.c SP/.
cp parse_amber.tcl SP/.
cp myresidues.dat SP/.
cp rc.prmtop SP/.
cp input.in SP/.

cd SP/ || exit
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
func b3-lyp

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
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed ${system} ${host}" simahjsr@gmail.com

elif [ "$step" = "2" ]; then
source "${inp}"
jobname="Scan Calculation"
if [[ ! -e ../2-Scan ]]; then
    mkdir ../2-Scan
elif [[ ! -d ../2-Scan ]]; then
    echo "2-Scan already exists but is not a directory" 1>&2
fi

cp rc.opt.c ../2-Scan/.
cp rc.opt.pdb ../2-Scan/.
cp rc.prmtop ../2-Scan/.
cp alpha ../2-Scan/.
cp beta ../2-Scan/.
cp control ../2-Scan/.
cp parse_amber.tcl ../2-Scan/.
cp QM.dat ../2-Scan/.
cp MM.dat ../2-Scan/.
cp myresidues.dat ../2-Scan/.
cp input.in ../2-Scan/.

cd ../2-Scan/ || exit
sed -i "1s/rc.pdb/scan_0.pdb/" myresidues.dat
sed -i "2s/target=QM/target=fatone/" myresidues.dat
cp rc.opt.c scan_0.c
cp rc.opt.pdb scan_0.pdb
cp rc.prmtop scan.prmtop
job=$(pwd)
cat > RC_Scan.chm <<ENDOFFILE
global sys_name_id
set control_input_settings [ open SUMMARY.txt  a]
puts \$control_input_settings "Summary of scan."
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id scan
set res [ pdb_to_res "\${sys_name_id}_0.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=fatone ]
set prmtop scan.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
# define QM/MM settings:
energy energy=e coords=scan_0.c theory=dl_poly  : [ list \\
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

#-------------------------------------------------------------
# optimize geometry

#reduce
set A $A
set B $B

set stepnum 20
set incr -0.1

set r1 [interatomic_distance coords=scan_0.c i=\$A j=\$B]
set initdist [expr \$r1 - 0 ]
set bincr [expr \$incr * 1.8897261329]

for {set i 0} { \$i < \$stepnum} {incr i} {

set ReactionCoordinate [expr (\$initdist + \$bincr * \$i) ]

#-------------------------------------------------------------
# optimize geometry with distance A-B fixed
dl-find maxcycle=900 coords= scan_\${i}.c  \\
result= scan_[expr (\$i+1)].c \\
tolerance= 0.0012 \\
restraints= [ list [ list bond \$A \$B \$ReactionCoordinate 3.0 ] ] \\
active_atoms= \$active \\
theory= hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp \\
hamiltonian= b3lyp \\
scftype= uhf  ]  \\
mm_theory= dl_poly  : [ list \\
amber_prmtop_file= \$prmtop \\
exact_srf=yes \\
use_pairlist=no \\
mxlist=40000 \\
cutoff=1000 \\
mxexcl=2000  \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ]  \\
               conn= scan_0.c \\
                save_dl_poly_files = yes \\
         list_option=none ]]

# save structure and orbitals of this step
exec cp scan_[expr (\$i+1)].c scan_[expr (\$i+1)].c_save
exec gzip  scan_[expr (\$i+1)].c_save
exec cp alpha alpha_[expr (\$i+1)]
exec cp beta beta_[expr (\$i+1)]
exec gzip alpha_[expr (\$i+1)]
exec gzip beta_[expr (\$i+1)]
read_pdb  file= scan_0.pdb  coords=dummy.coords
write_pdb file= scan_[expr (\$i+1)].pdb coords=scan_[expr (\$i+1)].c
exec gzip scan_[expr (\$i+1)].pdb


# write summary to file
puts \$control_input_settings "======================================"
puts \$control_input_settings "structure [expr (\$i+1)]"

set energy [ get_matrix_element matrix= dl-find.energy indices= { 0 0 } ]
puts \$control_input_settings [format "Energy:%14.6f" \$energy]

set r1 [interatomic_distance coords=scan_[expr (\$i+1)].c i=\$A j=\$B unit=angstrom ]
puts \$control_input_settings [format "Distance R1(A-B) :%4.3f" \$r1]

flush \$control_input_settings

#---------------------------------------------------------------------------

}


# cleanup
catch {delete_object hybrid.turbomole.coords}
catch {file delete dummy.coords}
flush \$control_input_settings
close \$control_input_settings

exit
ENDOFFILE

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

elif [ "$step" = "3" ]; then
source "${inp}"
jobname="TS-Optimization"
if [[ ! -e ../${transition}-TS_Opt ]]; then
    mkdir ../${transition}-TS_Opt
elif [[ ! -d ../${transition}-TS_Opt ]]; then
    echo "${transition}-TS_Opt already exists but is not a directory" 1>&2
fi

cp scan_"${transition}".c ../${transition}-TS_Opt/.
cp scan_"${transition}".pdb.gz ../${transition}-TS_Opt/.
cp scan_"${transition}".pdb ../${transition}-TS_Opt/.
cp scan.prmtop ../${transition}-TS_Opt/.
cp alpha_"${transition}".gz ../${transition}-TS_Opt/.
cp beta_"${transition}".gz ../${transition}-TS_Opt/.
cp control ../${transition}-TS_Opt/.
cp parse_amber.tcl ../${transition}-TS_Opt/.
cp QM.dat ../${transition}-TS_Opt/.
cp MM.dat ../${transition}-TS_Opt/.
cp myresidues.dat ../${transition}-TS_Opt/.
cp input.in ../${transition}-TS_Opt/.

cd ../${transition}-TS_Opt/ || exit
sed -i "1s/scan_0.pdb/ts.pdb/" myresidues.dat
sed -i "2s/target=fatone/target=QM/" myresidues.dat
gunzip ./*.gz
cp alpha_"${transition}" alpha
cp beta_"${transition}" beta
cp scan_"${transition}".c ts.c
cp scan_"${transition}".pdb ts.pdb
cp scan.prmtop ts.prmtop
job=$(pwd)
cat > TS_Opt.chm <<ENDOFFILE

global sys_name_id
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id ts
set res [ pdb_to_res "\${sys_name_id}.pdb" ]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop ts.prmtop
# set inpcrd
# load_amber_coords inpcrd=\$inpcrd prmtop=\$prmtop coords=dummy.c
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=ts.c theory=dl_poly  : [ list \\
					    amber_prmtop_file=\$prmtop \\
					    scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
					    save_dl_poly_files = yes \\
   					    exact_srf=yes ]

set atom_charges [ list_amber_atom_charges ]

##change: add "basis= {6-31G* all}"
set qmflags { hamiltonian=b3lyp scftype= uhf basis= {def2-SVP all} read_control= yes }
set qm_theory turbomole

matrix dl-find.energy new volatile

dl-find coords=\${sys_name_id}.c active_atoms= \$active \\
        result=\${sys_name_id}.opt.c coordinates=hdlc residues= \$res \\
		optimiser=lbfgs tolerance=0.00135 trustradius=const \\
		dimer=true delta=0.01 \\
	    maxcycle=1000 maxene=900 \\
		dump= 50 list_option=full \\
		tsrelative=true \\
		maxstep=0.5 \\
        theory=hybrid : [ list \\
        coupling= shift \\
        qm_region= \$qm_atoms \\
        atom_charges= \$atom_charges \\
        qm_theory= turbomole : \$qmflags  \\
        mm_theory= dl_poly  : [ list \\
        amber_prmtop_file= \$prmtop \\
        exact_srf=yes \\
        conn= ts.c \\
    use_pairlist=no \\
mxlist=70000 \\
mxexcl=2000  \\
cutoff=1000 \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
                save_dl_poly_files = yes \\
         list_option=none ]]
read_pdb  file= \${sys_name_id}.pdb  coords=hybrid.dl_poly.coords
write_pdb file= \${sys_name_id}.opt.pdb coords= \${sys_name_id}.opt.c
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.turbomole.coords

exit

ENDOFFILE

echo "Executing TS Optimization calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh TS_Opt.chm >& TS_Opt.log &"
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed" simahjsr@gmail.com 

elif [ "$step" = "3f" ]; then
source "${inp}"
jobname="TS-Frequency"
echo "Starting TS Frequency calculation"
mkdir Frequency
cp QM.dat Frequency/.
cp MM.dat Frequency/.
cp ts.opt.pdb Frequency/.
cp ts.opt.c Frequency/.
cp alpha Frequency/.
cp beta Frequency/.
cp control Frequency/.
cp parse_amber.tcl Frequency/.
cp myresidues.dat Frequency/.
cp ts.prmtop Frequency/.
cp input.in Frequency/.

cd Frequency/ || exit
sed -i "1s/ts.pdb/ts.opt.pdb/" myresidues.dat
job=$(pwd)
cat > TS_Freq.chm <<ENDOFFILE
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
force coords=ts.opt.c active_atoms= \$qm_atoms hessian=h formula=twopoint \\
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

tcsh -c "setenv PARNODES $nodes;nohup chemsh TS_Freq.chm >& TS_Freq.log &"
 
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

elif [ "$step" = "3s" ]; then
source "${inp}"
jobname="TS-Single Point Energy"
echo "Starting Single Point Calculation"
mkdir SP
cp QM.dat SP/.
cp MM.dat SP/.
cp ts.opt.pdb SP/.
cp ts.opt.c SP/.
cp parse_amber.tcl SP/.
cp myresidues.dat SP/.
cp ts.prmtop SP/.
cp input.in SP/.

cd SP/ || exit
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
func b3-lyp

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
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed ${system} ${host}" simahjsr@gmail.com


elif [ "$step" = "4" ]; then
source "${inp}"
jobname="PD-Optimization"
if [[ ! -e ../${product}-IM_Opt ]]; then
    mkdir ../${product}-IM_Opt
elif [[ ! -d ../${product}-IM_Opt ]]; then
    echo "${product}-IM_Opt already exists but is not a directory" 1>&2
fi

echo "Starting PD Optimization"
cp scan_"${product}".c ../${product}-IM_Opt/.
cp scan_"${product}".pdb.gz ../${product}-IM_Opt/.
cp scan_"${product}".pdb ../${product}-IM_Opt/.
cp scan.prmtop ../${product}-IM_Opt/.
cp alpha_"${product}".gz ../${product}-IM_Opt/.
cp alpha_"${product}" ../${product}-IM_Opt/.
cp beta_"${product}".gz ../${product}-IM_Opt/.
cp beta_"${product}" ../${product}-IM_Opt/.
cp control ../${product}-IM_Opt/.
cp parse_amber.tcl ../${product}-IM_Opt/.
cp QM.dat ../${product}-IM_Opt/.
cp MM.dat ../${product}-IM_Opt/.
cp myresidues.dat ../${product}-IM_Opt/.
cp input.in ../${product}-IM_Opt/.

cd ../${product}-IM_Opt/ || exit
sed -i "1s/scan_0.pdb/pd.pdb/" myresidues.dat
sed -i "2s/target=fatone/target=QM/" myresidues.dat
gunzip ./*.gz
cp alpha_"${product}" alpha
cp beta_"${product}" beta
cp scan_"${product}".c pd.c
cp scan_"${product}".pdb pd.pdb
cp scan.prmtop pd.prmtop
job=$(pwd)
cat > PD_Opt.chm <<ENDOFFILE

global sys_name_id
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id pd
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop pd.prmtop
#set inpcrd pd.rst
#load_amber_coords inpcrd=\$inpcrd prmtop=\$prmtop coords=rc.c
# # for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=pd.c theory=dl_poly  : [ list \\
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
#set qm_atoms {5369-5385 2943-2948 4111-4121 2912-2922 5386-5412}

# optimize geometry
dl-find coords=pd.c maxcycle=999 active_atoms= \$active residues= \$myresidues list_option=full result=\${sys_name_id}.opt.c \\
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
                conn= pd.c \\
                save_dl_poly_files = yes \\
         list_option=none ]]

####
# save structure
read_pdb  file= \${sys_name_id}.pdb  coords=hybrid.dl_poly.coords
write_pdb file= \${sys_name_id}.opt.pdb coords= \${sys_name_id}.opt.c
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.turbomole.coords

exit

ENDOFFILE
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh PD_Opt.chm >& PD_Opt.log &"
 
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

elif [ "$step" = "4f" ]; then
source "${inp}"
jobname="PD-Frequency"
echo "Starting PD Frequency calculation"
mkdir Frequency
cp QM.dat Frequency/.
cp MM.dat Frequency/.
cp pd.opt.pdb Frequency/.
cp pd.opt.c Frequency/.
cp alpha Frequency/.
cp beta Frequency/.
cp control Frequency/.
cp parse_amber.tcl Frequency/.
cp myresidues.dat Frequency/.
cp pd.prmtop Frequency/.
cp input.in Frequency/.

cd Frequency/ || exit
sed -i "1s/pd.pdb/pd.opt.pdb/" myresidues.dat
job=$(pwd)
cat > PD_Freq.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id pd.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
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
##################
matrix dl-find.energy new volatile
force coords=pd.opt.c active_atoms= \$qm_atoms hessian=h formula=twopoint \\
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
conn= pd.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]
########

 exit
ENDOFFILE

echo "Executing PD Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh PD_Freq.chm >& PD_Freq.log &"
 
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

elif [ "$step" = "4s" ]; then
source "${inp}"
jobname="PD-Single Point Energy"
echo "Starting PD Single Point Calculation"
mkdir SP
cp QM.dat SP/.
cp MM.dat SP/.
cp pd.opt.pdb SP/.
cp pd.opt.c SP/.
cp parse_amber.tcl SP/.
cp myresidues.dat SP/.
cp pd.prmtop SP/.
cp input.in SP/.

cd SP/ || exit
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
func b3-lyp

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
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed ${system} ${host}" simahjsr@gmail.com


###############################################################################################################################################################


								#REBOUND



###############################################################################################################################################################



elif [ "$step" = "RB" ]; then
source "${inp}"
jobname="RB-Scan"
if [[ ! -e ../Rebound ]]; then
    mkdir ../Rebound
elif [[ ! -d ../Rebound ]]; then
    echo "Rebound already exists but is not a directory" 1>&2
fi

echo "Starting RB Scan"
cp pd.opt.c ../Rebound/.
cp pd.opt.pdb ../Rebound/.
cp pd.prmtop ../Rebound/.
cp alpha ../Rebound/.
cp beta ../Rebound/.
cp control ../Rebound/.
cp parse_amber.tcl ../Rebound/.
cp QM.dat ../Rebound/.
cp MM.dat ../Rebound/.
cp myresidues.dat ../Rebound/.
cp input.in ../Rebound/.

cd ../Rebound/ || exit
sed -i "1s/pd.pdb/rebound_0.pdb/" myresidues.dat
sed -i "2s/target=QM/target=fatone/" myresidues.dat
cp pd.opt.c rebound_0.c
cp pd.opt.pdb rebound_0.pdb
cp pd.prmtop rebound.prmtop
job=$(pwd)
cat > RB_Scan.chm <<ENDOFFILE

global sys_name_id
set control_input_settings [ open SUMMARY.txt  a]
puts \$control_input_settings "Summary of scan."
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id rebound
set res [ pdb_to_res "\${sys_name_id}_0.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=fatone ]
set prmtop rebound.prmtop
energy energy=e coords=rebound_0.c theory=dl_poly  : [ list \\
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

#-------------------------------------------------------------
# optimize geometry

#reduce
set A $A
set B $B

set stepnum 30
set incr -0.1

set r1 [interatomic_distance coords=rebound_0.c i=$A j=$B]
set initdist [expr \$r1 - 0 ]
set bincr [expr \$incr * 1.8897261329]

for {set i 0} { \$i < \$stepnum} {incr i} {

set ReactionCoordinate [expr (\$initdist + \$bincr * \$i) ]

#-------------------------------------------------------------
# optimize geometry with distance A-B fixed
dl-find maxcycle=900 coords= rebound_\${i}.c  \\
result= rebound_[expr (\$i+1)].c \\
tolerance= 0.0012 \\
restraints= [ list [ list bond $A $B \$ReactionCoordinate 3.0 ] ] \\
active_atoms= \$active \\
theory= hybrid : [ list \\
coupling= shift \\
qm_region= \$qm_atoms \\
atom_charges= \$atom_charges \\
qm_theory= turbomole : [list   \\
read_control= yes \\
scratchdir=/data/$user/temp \\
hamiltonian= b3lyp \\
scftype= uhf  ]  \\
mm_theory= dl_poly  : [ list \\
amber_prmtop_file= \$prmtop \\
exact_srf=yes \\
use_pairlist=no \\
mxlist=40000 \\
cutoff=1000 \\
mxexcl=2000  \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ]  \\
               conn= rebound_0.c \\
                save_dl_poly_files = yes \\
         list_option=none ]]

# save structure and orbitals of this step
exec cp rebound_[expr (\$i+1)].c rebound_[expr (\$i+1)].c_save
exec gzip  rebound_[expr (\$i+1)].c_save
exec cp alpha alpha_[expr (\$i+1)]
exec cp beta beta_[expr (\$i+1)]
exec gzip alpha_[expr (\$i+1)]
exec gzip beta_[expr (\$i+1)]
read_pdb  file= rebound_0.pdb  coords=dummy.coords
write_pdb file= rebound_[expr (\$i+1)].pdb coords=rebound_[expr (\$i+1)].c
exec gzip rebound_[expr (\$i+1)].pdb


# write summary to file
puts \$control_input_settings "======================================"
puts \$control_input_settings "structure [expr (\$i+1)]"

set energy [ get_matrix_element matrix= dl-find.energy indices= { 0 0 } ]
puts \$control_input_settings [format "Energy:%14.6f" \$energy]

set r1 [interatomic_distance coords=rebound_[expr (\$i+1)].c i=$A j=$B unit=angstrom ]
puts \$control_input_settings [format "Distance R1(A-B) :%4.3f" \$r1]

flush \$control_input_settings

#---------------------------------------------------------------------------

}


# cleanup
catch {delete_object hybrid.turbomole.coords}
catch {file delete dummy.coords}
flush \$control_input_settings
close \$control_input_settings

exit
ENDOFFILE
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


elif [ "$step" = "RB_TS" ]; then
source "${inp}"
jobname="RB_TS-Optimization"
if [[ ! -e RB_TS ]]; then
    mkdir RB_TS
elif [[ ! -d RB_TS ]]; then
    echo "RB_TS already exists but is not a directory" 1>&2
fi

cp rebound_"${transition}".c RB_TS/.
cp rebound_"${transition}".pdb.gz RB_TS/.
cp rebound_"${transition}".pdb RB_TS/.
cp rebound.prmtop RB_TS/.
cp alpha_"${transition}".gz RB_TS/.
cp beta_"${transition}".gz RB_TS/.
cp control RB_TS/.
cp parse_amber.tcl RB_TS/.
cp QM.dat RB_TS/.
cp MM.dat RB_TS/.
cp myresidues.dat RB_TS/.
cp input.in RB_TS/.

cd RB_TS/ || exit
sed -i "1s/rebound_0.pdb/rb_ts.pdb/" myresidues.dat
sed -i "2s/target=fatone/target=QM/" myresidues.dat
gunzip ./*.gz
cp alpha_"${transition}" alpha
cp beta_"${transition}" beta
cp rebound_"${transition}".c rb_ts.c
cp rebound_"${transition}".pdb rb_ts.pdb
cp rebound.prmtop rb_ts.prmtop
job=$(pwd)
cat > RB_TS_Opt.chm <<ENDOFFILE

global sys_name_id
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id rb_ts
set res [ pdb_to_res "\${sys_name_id}.pdb" ]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rb_ts.prmtop
# set inpcrd
# load_amber_coords inpcrd=\$inpcrd prmtop=\$prmtop coords=dummy.c
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rb_ts.c theory=dl_poly  : [ list \\
					    amber_prmtop_file=\$prmtop \\
					    scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
					    save_dl_poly_files = yes \\
   					    exact_srf=yes ]

set atom_charges [ list_amber_atom_charges ]

##change: add "basis= {6-31G* all}"
set qmflags { hamiltonian=b3lyp scftype= uhf basis= {def2-SVP all} read_control= yes }
set qm_theory turbomole

matrix dl-find.energy new volatile

dl-find coords=\${sys_name_id}.c active_atoms= \$active \\
        result=\${sys_name_id}.opt.c coordinates=hdlc residues= \$res \\
		optimiser=lbfgs tolerance=0.00135 trustradius=const \\
		dimer=true delta=0.01 \\
	    maxcycle=1000 maxene=900 \\
		dump= 50 list_option=full \\
		tsrelative=true \\
		maxstep=0.5 \\
        theory=hybrid : [ list \\
        coupling= shift \\
        qm_region= \$qm_atoms \\
        atom_charges= \$atom_charges \\
        qm_theory= turbomole : \$qmflags  \\
        mm_theory= dl_poly  : [ list \\
        amber_prmtop_file= \$prmtop \\
        exact_srf=yes \\
        conn= rb_ts.c \\
    use_pairlist=no \\
mxlist=70000 \\
mxexcl=2000  \\
cutoff=1000 \\
debug_memory=no \\
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
                save_dl_poly_files = yes \\
         list_option=none ]]
read_pdb  file= \${sys_name_id}.pdb  coords=hybrid.dl_poly.coords
write_pdb file= \${sys_name_id}.opt.pdb coords= \${sys_name_id}.opt.c
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.turbomole.coords

exit

ENDOFFILE

# nohup chemsh RB_TS_Opt.chm > RB_TS_Opt.log &
# process=$!
# while ps -p ${process} > /dev/null;do sleep 1;done;
# if [ "$(grep -c "Terminated" TS_Opt.log)" -ge 1 ]; then
# 		echo "TS Terminated by User"
# 		exit
# 	else
# 		echo "TS Terminated normally"
# 	fi
# define <<EOF


# a coord
# *
# no
# b all def2-SVP
# *
# eht
# y
# $charge
# n
# u $unp
# *
# n
# scf
# iter
# 900

# dft
# on
# func b3-lyp

# *
# EOF

echo "Executing TS Optimization calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_TS_Opt.chm >& RB_TS_Opt.log &"
sleep 5
if [ -z "$string" ]
then
calc=$(pidof chemsh.x)
else
calc=$(pidof -o "${string}" chemsh.x)    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do sleep 1;done;
echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job}" | mail -s "Job Completed" simahjsr@gmail.com 

elif [ "$step" = "RB_TS_Freq" ]; then
source "${inp}"
jobname="RB_TS-Frequency"
echo "Starting TS Frequency calculation"
mkdir Frequency
cp QM.dat Frequency/.
cp MM.dat Frequency/.
cp rb_ts.opt.pdb Frequency/.
cp rb_ts.opt.c Frequency/.
cp alpha Frequency/.
cp beta Frequency/.
cp control Frequency/.
cp parse_amber.tcl Frequency/.
cp myresidues.dat Frequency/.
cp rb_ts.prmtop Frequency/.
cp input.in Frequency/.

cd Frequency/ || exit
sed -i "1s/rb_ts.pdb/rb_ts.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RB_TS_Freq.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
source myresidues.dat
set sys_name_id rb_ts.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues} target=QM ]
set prmtop rb_ts.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rb_ts.opt.c theory=dl_poly  : [ list \\
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
force coords=rb_ts.opt.c active_atoms= \$qm_atoms hessian=h formula=twopoint \\
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
conn= rb_ts.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]
########

 exit
ENDOFFILE

echo "Executing TS Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_TS_Freq.chm >& RB_TS_Freq.log &"
 
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

elif [ "$step" = "RB_TS_SP" ]; then
source "${inp}"
jobname="RB_TS-Single Point Energy"
echo "Starting Single Point Calculation"
mkdir SP
cp QM.dat SP/.
cp MM.dat SP/.
cp rb_ts.opt.pdb SP/.
cp rb_ts.opt.c SP/.
cp parse_amber.tcl SP/.
cp myresidues.dat SP/.
cp rb_ts.prmtop SP/.
cp input.in SP/.

cd SP/ || exit
sed -i "1s/rb_ts.pdb/rb_ts.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RB_TS_SP.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rb_ts.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rb_ts.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rb_ts.opt.c theory=dl_poly  : [ list \\
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
conn= rb_ts.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]


####
exit
ENDOFFILE
nohup chemsh RB_TS_SP.chm > RB_TS_SP.log &
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
func b3-lyp

*
EOF

echo "Executing TS Single Point Energy Calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_TS_SP.chm >& RB_TS_SP.log &"
 
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


elif [ "$step" = "RB_PD" ]; then
source "${inp}"
jobname="RB_PD-Optimization"
if [[ ! -e RB_PD ]]; then
    mkdir RB_PD
elif [[ ! -d RB_PD ]]; then
    echo "${product}-IM_Opt already exists but is not a directory" 1>&2
fi

echo "Starting PD Optimization"
cp rebound_"${product}".c RB_PD/.
cp rebound_"${product}".pdb.gz RB_PD/.
cp rebound_"${product}".pdb RB_PD/.
cp rebound.prmtop RB_PD/.
cp alpha_"${product}".gz RB_PD/.
cp alpha_"${product}" RB_PD/.
cp beta_"${product}".gz RB_PD/.
cp beta_"${product}" RB_PD/.
cp control RB_PD/.
cp parse_amber.tcl RB_PD/.
cp QM.dat RB_PD/.
cp MM.dat RB_PD/.
cp myresidues.dat RB_PD/.
cp input.in RB_PD/.

cd RB_PD/ || exit
sed -i "1s/rebound_0.pdb/rb_pd.pdb/" myresidues.dat
sed -i "2s/target=fatone/target=QM/" myresidues.dat
gunzip ./*.gz
cp alpha_"${product}" alpha
cp beta_"${product}" beta
cp rebound_"${product}".c rb_pd.c
cp rebound_"${product}".pdb rb_pd.pdb
cp rebound.prmtop rb_pd.prmtop
job=$(pwd)
cat > RB_PD_Opt.chm <<ENDOFFILE

global sys_name_id
source parse_amber.tcl
source MM.dat
source QM.dat
set sys_name_id rb_pd
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rb_pd.prmtop
energy energy=e coords=rb_pd.c theory=dl_poly  : [ list \\
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
dl-find coords=rb_pd.c maxcycle=999 active_atoms= \$active residues= \$myresidues list_option=full result=\${sys_name_id}.opt.c \
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
debug_memory=no \
scale14 = [ list [ expr 1 / 1.2 ] 0.5  ] \\
                conn= rb_pd.c \\
                save_dl_poly_files = yes \\
         list_option=none ]]

####
# save structure
read_pdb  file= \${sys_name_id}.pdb  coords=hybrid.dl_poly.coords
write_pdb file= \${sys_name_id}.opt.pdb coords= \${sys_name_id}.opt.c
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.turbomole.coords

exit

ENDOFFILE
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_PD_Opt.chm >& RB_PD_Opt.log &"
 
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

elif [ "$step" = "RB_PD_Freq" ]; then
source "${inp}"
jobname="RB_PD-Frequency"
echo "Starting RB_PD Frequency calculation"
mkdir Frequency
cp QM.dat Frequency/.
cp MM.dat Frequency/.
cp rb_pd.opt.pdb Frequency/.
cp rb_pd.opt.c Frequency/.
cp alpha Frequency/.
cp beta Frequency/.
cp control Frequency/.
cp parse_amber.tcl Frequency/.
cp myresidues.dat Frequency/.
cp rb_pd.prmtop Frequency/.
cp input.in Frequency/.

cd Frequency/ || exit
sed -i "1s/rb_pd.pdb/rb_pd.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RB_PD_Freq.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rb_pd.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rb_pd.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rb_pd.opt.c theory=dl_poly  : [ list \\
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
force coords=rb_pd.opt.c active_atoms= \$qm_atoms hessian=h formula=twopoint \\
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
conn= rb_pd.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]
########

 exit
ENDOFFILE

echo "Executing RB_PD Frequency calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"
tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_PD_Freq.chm >& RB_PD_Freq.log &"
 
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

elif [ "$step" = "RB_PD_SP" ]; then
source "${inp}"
jobname="RB_PD-Single Point Energy"
echo "Starting PD Single Point Calculation"
mkdir SP
cp QM.dat SP/.
cp MM.dat SP/.
cp rb_pd.opt.pdb SP/.
cp rb_pd.opt.c SP/.
cp parse_amber.tcl SP/.
cp myresidues.dat SP/.
cp rb_pd.prmtop SP/.
cp input.in SP/.

cd SP/ || exit
sed -i "1s/rb_pd.pdb/rb_pd.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RB_PD_SP.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rb_pd.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set prmtop rb_pd.prmtop
# for the time being we have to calculate an energy to be able to call list_amber_atom_charges
energy energy=e coords=rb_pd.opt.c theory=dl_poly  : [ list \\
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
conn= rb_pd.opt.c \\
save_dl_poly_files = yes \\
list_option=none ]]


####
exit
ENDOFFILE
nohup chemsh RB_PD_SP.chm > RB_PD_SP.log &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;

if [ "$(grep -c "Terminated" PD_SP.log)" -ge 1 ]; then
		echo "RB_PD_SP Terminated by User"
		exit
	else
		echo "RB_PD_SP Terminated normally"
	fi

echo "RB_TS SP Terminated.Now Running Define"
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
func b3-lyp

*
EOF

echo "Executing RB_PD Single Point Energy Calculation"
omit=$(pidof chemsh.x)
string="${omit//${IFS:0:1}/,}"

tcsh -c "setenv PARNODES $nodes;nohup chemsh RB_PD_SP.chm >& RB_PD_SP.log &"
 
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
