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
resname=$(zenity --entry --title="Active Site except Substrate (Eg. HD1,OY1 )")
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
echo "parsefile=""${parsefile}"
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
parmext="${parmname##*.}"
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
atomselect top "(resname $resname and not backbone and not type HA H) or (resname $substrate)"
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

#increase
set C $C
set D $D

set stepnum 40
set incr -0.1

set r1 [interatomic_distance coords=scan_0.c i=\$A j=\$B]
set r2 [interatomic_distance coords=scan_0.c i=\$C j=\$D]
set initdist [expr \$r1 - \$r2 ]
set bincr [expr \$incr * 1.8897261329]

for {set i 0} { \$i < \$stepnum} {incr i} {

set ReactionCoordinate [expr (\$initdist + \$bincr * \$i) ]

#-------------------------------------------------------------
# optimize geometry with distance A-B fixed
dl-find maxcycle=900 coords= scan_\${i}.c  \\
result= scan_[expr (\$i+1)].c \\
tolerance= 0.0012 \\
restraints= [ list [ list bonddiff2 \$A \$B \$C \$D \$ReactionCoordinate 3.0 ] ] \\
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
set r2 [interatomic_distance coords=scan_[expr (\$i+1)].c i=\$C j=\$D unit=angstrom ]
puts \$control_input_settings [format "Distance R1(A-B) R2(C-D) :%4.3f %4.3f" \$r1 \$r2]

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

elif [ "$step" = "3" ]; then
source "${inp}"
jobname="TS-Optimization"
if [[ ! -e ../3-TS_Opt ]]; then
    mkdir ../3-TS_Opt
elif [[ ! -d ../3-TS_Opt ]]; then
    echo "3-TS_Opt already exists but is not a directory" 1>&2
fi

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
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.\${qm_theory}.coords

exit

ENDOFFILE

elif [ "$step" = "4" ]; then
source "${inp}"
jobname="PD-Optimization"
if [[ ! -e ../4-PD_Opt ]]; then
    mkdir ../4-PD_Opt
elif [[ ! -d ../4-PD_Opt ]]; then
    echo "4-PD_Opt already exists but is not a directory" 1>&2
fi

echo "Starting PD Optimization"
cp scan_"${product}".c ../4-PD_Opt/.
cp scan_"${product}".pdb.gz ../4-PD_Opt/.
cp scan_"${product}".pdb ../4-PD_Opt/.
cp scan.prmtop ../4-PD_Opt/.
cp alpha_"${product}".gz ../4-PD_Opt/.
cp alpha_"${product}" ../4-PD_Opt/.
cp beta_"${product}".gz ../4-PD_Opt/.
cp beta_"${product}" ../4-PD_Opt/.
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
write_xyz file= \${sys_name_id}.QMregion.opt.xyz coords=hybrid.\${qm_theory}.coords

exit

ENDOFFILE

elif [ "$step" = "5" ]; then
source "${inp}"
jobname="Scan Calculation"
if [[ ! -e ../5-Scan ]]; then
    mkdir ../5-Scan
elif [[ ! -d ../5-Scan ]]; then
    echo "5-Scan already exists but is not a directory" 1>&2
fi

cp pd.opt.c ../5-Scan/.
cp pd.opt.pdb ../5-Scan/.
cp pd.prmtop ../5-Scan/.
cp alpha ../5-Scan/.
cp beta ../5-Scan/.
cp control ../5-Scan/.
cp parse_amber.tcl ../5-Scan/.
cp QM.dat ../5-Scan/.
cp MM.dat ../5-Scan/.
cp myresidues.dat ../5-Scan/.
cp input.in ../5-Scan/.

cd ../5-Scan/ || exit
sed -i "1s/pd.pdb/scan_0.pdb/" myresidues.dat
sed -i "2s/target=QM/target=fatone/" myresidues.dat
cp pd.opt.c scan_0.c
cp pd.opt.pdb scan_0.pdb
cp pd.prmtop scan.prmtop
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

#increase
set C $C
set D $D

set stepnum 40
set incr -0.1

set r1 [interatomic_distance coords=scan_0.c i=\$A j=\$B]
set r2 [interatomic_distance coords=scan_0.c i=\$C j=\$D]
set initdist [expr \$r1 - \$r2 ]
set bincr [expr \$incr * 1.8897261329]

for {set i 0} { \$i < \$stepnum} {incr i} {

set ReactionCoordinate [expr (\$initdist + \$bincr * \$i) ]

#-------------------------------------------------------------
# optimize geometry with distance A-B fixed
dl-find maxcycle=900 coords= scan_\${i}.c  \\
result= scan_[expr (\$i+1)].c \\
tolerance= 0.0012 \\
restraints= [ list [ list bonddiff2 \$A \$B \$C \$D \$ReactionCoordinate 3.0 ] ] \\
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
set r2 [interatomic_distance coords=scan_[expr (\$i+1)].c i=\$C j=\$D unit=angstrom ]
puts \$control_input_settings [format "Distance R1(A-B) R2(C-D) :%4.3f %4.3f" \$r1 \$r2]

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
fi