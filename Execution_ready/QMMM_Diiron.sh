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
while getopts i:s:a:b:t:p: flag
do
    case "${flag}" in
	i) inp=${OPTARG};;
	s) step=${OPTARG};;
	a) A=${OPTARG};;
	b) B=${OPTARG};;
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
source "${inp}"
user=$USER
host=$(hostname)
if [ "$step" = "0" ]; then
cp "$parsefile" .
gedit parse_amber.tcl "$tleapinput"							#Check for correct path of parse_amber.tcl
echo "Did you check parse_amber.tcl and made sure atoms are grouped correctly as such in tleap input?"
read -r parse_amber
if [ "$parse_amber" = "yes" ]; then
echo "Modelling proceeds"
else
exit
fi

#CREATING INPUT FILES FOR CPPTRAJ FOR PREPARING RC COMPLEX FILES
cat > Frame_"${frame}".in << ENDOFFILE
parm ${parm}
trajin ${trajin} ${frame} ${frame}
autoimage
trajout ${frame}.pdb
run
exit
ENDOFFILE
cat Frame_"${frame}".in
cat > Water_strip_"${frame}".in <<ENDOFFILE
parm ${parm}
trajin ${frame}.pdb
reference ${frame}.pdb
strip :Na+,Cl-
strip !(:$numberofres<:12.0) outprefix stripped12
trajout stripped12.${system}.pdb
run
exit
ENDOFFILE
cat Water_strip_"${frame}".in
cat > ReactionComplex_"${frame}".in <<ENDOFFILE
parm stripped12.${system}.prmtop
trajin stripped12.${system}.pdb
trajout rc.pdb
trajout rc.rst restart
run
exit
ENDOFFILE
cat ReactionComplex_"${frame}".in

#CREATING RC COMPLEX FILES
nohup cpptraj -i Frame_"${frame}".in > Frame_"${frame}".out &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Error" Frame_"${frame}".out)" -ge 1 ]; then
                echo "Cpptraj Error"
                exit
        else
                echo "Generated Frame PDB"
        fi
nohup cpptraj -i Water_strip_"${frame}".in > Water_strip_"${frame}".out &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Error" Water_strip_"${frame}".out)" -ge 1 ]; then
                echo "Cpptraj Error"
                exit
        else
                echo "Generated WaterStripped PDB and prmtop"
        fi
nohup cpptraj -i ReactionComplex_"${frame}".in > ReactionComplex_"${frame}".out &
process=$!
while ps -p ${process} > /dev/null;do sleep 1;done;
if [ "$(grep -c "Error" ReactionComplex_"${frame}".out)" -ge 1 ]; then
                echo "Cpptraj Error"
                exit
        else
                echo "Generated RC files for RC_OPT"
        fi
cp stripped12."${system}".prmtop rc.prmtop
sed -i "9s/1/0/" rc.prmtop

#MAKING QMMM MODEL
echo "Creating QMMM Model"
cat > QM_MM_"${frame}".tcl <<ENDOFFILE
mol load pdb rc.pdb
atomselect top "same residue as (within 8 of (resname $resname $substrate))"
atomselect0 num
atomselect0 writepdb MM_${frame}.pdb
set myfile [open mm_${frame}.txt w]
puts \$myfile [atomselect0 list]
close \$myfile
atomselect top "(resname $resname and not backbone and not name HA H) or resname $substrate"
atomselect1 num
atomselect1 writepdb QM_${frame}.pdb
atomselect1 writexyz QM_${frame}.xyz
set myfile1 [open qm_${frame}.txt w]
puts \$myfile1 [atomselect1 list]
close \$myfile1
atomselect top "(resname $resname and name H) or (resname FE1 FE2) or (resname OY1 and name O1) or (resname NMA and name C13)"
set resid [atomselect1 get resid]
foreach elementid \$resid {dict set tmp \$elementid 1}
set id [dict keys \$tmp]
set resname [atomselect1 get resname]
foreach elementname \$resname {dict set tmp1 \$elementname 1}
set name [dict keys \$tmp1]
set myresidues [open qm_mm_${frame}.sh w]
puts \$myresidues "resid=(\$id)"
puts \$myresidues "resname=(\$name)"
puts \$myresidues "myresidues=()"
puts \$myresidues "n=\\\${#resname\\[@]}"
puts \$myresidues "for i in \\\$(seq 1 \\\$n);"
puts \$myresidues "do"
puts \$myresidues "myresidues+=(\\\${resname\\[i-1]}\\\${resid\\[i-1]})"
puts \$myresidues "done"
puts \$myresidues "cat > myresidues_${frame}.dat <<ENDOFFILE"
puts \$myresidues "set res \\[ pdb_to_res \\"rc.pdb\\"]"
puts \$myresidues "set myresidues  \\[ inlist function=combine residues= \\\\\\\$res sets= {\\\${myresidues\\[*]}} target=QM ]"
puts \$myresidues "ENDOFFILE"
close \$myresidues
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

chmod +x qm_mm_"${frame}".sh
./qm_mm_"${frame}".sh

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
cp rc.pdb ../../QMMM/Frame"${frame}"/1-RC_Opt/.
cp rc.rst ../../QMMM/Frame"${frame}"/1-RC_Opt/.
cp rc.prmtop ../../QMMM/Frame"${frame}"/1-RC_Opt/.
cp QM_"${frame}".dat ../../QMMM/Frame"${frame}"/1-RC_Opt/QM.dat
cp MM_"${frame}".dat ../../QMMM/Frame"${frame}"/1-RC_Opt/MM.dat
cp myresidues_"${frame}".dat ../../QMMM/Frame"${frame}"/1-RC_Opt/myresidues.dat
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
source myresidues.dat
set sys_name_id rc
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

# optimize geometry with distance A-B fixed
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
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.\${qm_theory}.coords

  exit

ENDOFFILE

elif [ "$step" = "1" ]; then
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
        tcsh -c "setenv PARNODES $nodes;nohup chemsh RC_dlfind.chm >& RC_dlfind.log &"
        echo "$job $system $frame JOB SCF Error and Restarted" | mail -s "Job Restarted" simahjsr@gmail.com
else
        echo "RC Completed"
        echo "Job Completed in ${host} on $(date) for ${system} ${jobname} at ${job} " | mail -s "Job Completed ${system}" simahjsr@gmail.com
fi

elif [ "$step" = "1f" ]; then
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
cp myresidues.dat Frequency/.
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
source myresidues.dat
set sys_name_id rc.opt
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
source myresidues.dat
set sys_name_id rc.opt
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
source myresidues.dat
#source orca-chemsh.tcl
set sys_name_id scan
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

set stepnum 30
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
jobname="TS-Optimization"
if [[ ! -e ../3-TS_Opt ]]; then
    mkdir ../3-TS_Opt
elif [[ ! -d ../3-TS_Opt ]]; then
    echo "3-TS_Opt already exists but is not a directory" 1>&2
fi

cp control ../3-TS_Opt/.
cp scan_"${transition}".c ../3-TS_Opt/.
cp scan_"${transition}".pdb.gz ../3-TS_Opt/.
cp scan_"${transition}".pdb ../3-TS_Opt/.
cp scan.prmtop ../3-TS_Opt/.
cp alpha_"${transition}".gz ../3-TS_Opt/.
cp beta_"${transition}".gz ../3-TS_Opt/.
cp control ../3-TS_Opt/.
cp parse_amber.tcl ../3-TS_Opt/.
cp QM.dat ../3-TS_Opt/.
cp MM.dat ../3-TS_Opt/.
cp myresidues.dat ../3-TS_Opt/.
cp input.in ../3-TS_Opt/.

cd ../3-TS_Opt/ || exit
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
		optimiser=lbfgs tolerance=0.1 trustradius=const \\
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
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.\${qm_theory}.coords

exit

ENDOFFILE

#nohup chemsh TS_Opt.chm > TS_Opt.log &
#process=$!
#while ps -p ${process} > /dev/null;do sleep 1;done;
#if [ "$(grep -c "Terminated" TS_Opt.log)" -ge 1 ]; then
#		echo "TS Terminated by User"
#		exit
#	else
#		echo "TS Terminated normally"
#	fi
#efine <<EOF


#a coord
#
#no
#b all def2-SVP
#*
#eht
#y
#$charge
#n
#u $unp
#*
#n
#scf
#iter
#900

#dft
#on
#func b3-lyp

#*
#EOF

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
source myresidues.dat
set sys_name_id ts.opt
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
source myresidues.dat
set sys_name_id ts.opt
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
jobname="PD-Optimization"
if [[ ! -e ../4-PD_Opt ]]; then
    mkdir ../4-PD_Opt
elif [[ ! -d ../4-PD_Opt ]]; then
    echo "4-PD_Opt already exists but is not a directory" 1>&2
fi

echo "Starting PD Optimization"
cp scan_"${product}".c ../4-PD_Opt/.
cp scan_"${product}".pdb.gz ../4-PD_Opt/.
cp scan.prmtop ../4-PD_Opt/.
cp alpha_"${product}".gz ../4-PD_Opt/.
cp beta_"${product}".gz ../4-PD_Opt/.
cp control ../4-PD_Opt/.
cp parse_amber.tcl ../4-PD_Opt/.
cp QM.dat ../4-PD_Opt/.
cp MM.dat ../4-PD_Opt/.
cp myresidues.dat ../4-PD_Opt/.
cp input.in ../4-PD_Opt/.

cd ../4-PD_Opt/ || exit
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
source myresidues.dat
set sys_name_id pd
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

# optimize geometry with distance A-B fixed
dl-find coords=pd.c maxcycle=999 active_atoms= \$active residues= \$myresidues list_option=full result=\${sys_name_id}.opt.c \
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
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.\${qm_theory}.coords

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
source myresidues.dat
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
jobname="TS-Single Point Energy"
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
source myresidues.dat
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

fi
