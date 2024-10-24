#!/bin/bash

# while getopts p:t:r:a:s:f: flag
# do
#     case "${flag}" in
# 	p) parm=${OPTARG};;
# 	t) traj=${OPTARG};;
# 	r) residues=${OPTARG};;
# 	a) active=${OPTARG};;
# 	s) substrate=${OPTARG};;
# 	f) reference=${OPTARG};;
#     *) echo "usage: $0 [-a acceptor filename] [-d donor filename] [-r residues(ID or name) ] [-s substrate residue range] " >&2
#        exit 1 ;;
# esac
# 
mkdir -p Analysis
cd Analysis || exit

echo "Analysis folder is created"

echo "Now in $(pwd)"

function Hbond {
mkdir Hbond
cd Hbond || exit
cat Hbond.log

parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Parameter File: " parm 
#echo "parm=""$parm" >> Hbond.log
traj=$(zenity --file-selection --file-filter=*auto.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Trajectory File: " traj 
#echo "traj=""$traj" >> Hbond.log
active=$(zenity --entry --title="Active Site Residues (Eg. HD1,OY1 or their resid)")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Active Site Residues (Eg. HD1,OY1 or their resid): " active 
#echo "active=""$active" >> Hbond.log
substrate=$(zenity --entry --title="Substrate Residues (Eg. 536-552)")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Substrate Residues (Eg. 536-552): " substrate 
#echo "substrate=""$substrate" >> Hbond.log

{ date
echo "parm=""$parm"
echo "traj=""$traj"
echo "active=""$active"
echo "substrate=""$substrate"
} >> Hbond.log
parmname=$(basename -- "$parm")
parmfile="${parmname%_*}"

trajname=$(basename -- "$traj")
trajfile="${trajname%.auto*}"

residinp=$(basename -- "${substrate}")
#residlast="${residinp##*-}"
#residfirst="${residinp%-*}"

cat > Hbond_"${parmfile}".in << EOF 
parm ${parm}
trajin ${traj}
hbond hbond_${parmfile} donormask :${active} out hbond_${parmfile}_donor.dat avgout hbond_avg_${parmfile}_donor.dat
hbond hbond_${parmfile}_sub donormask :${substrate} out hbond_${parmfile}_sub_donor.dat avgout hbond_avg_${parmfile}_sub_donor.dat
hbond hbond_${parmfile}1 acceptormask :${active} out hbond_${parmfile}_acceptor.dat avgout hbond_avg_${parmfile}_acceptor.dat
hbond hbond_${parmfile}1_sub acceptormask :${substrate} out hbond_${parmfile}_sub_acceptor.dat avgout hbond_avg_${parmfile}_sub_acceptor.dat
hbond All out All.hbvtime.dat solventdonor :WAT solventacceptor :WAT@O avgout All.UU.avg.dat solvout All.UV.avg.dat bridgeout All.bridge.avg.dat
run
EOF

omit=$(pidof cpptraj.MPI)
string="${omit//${IFS:0:1}/,}"

nohup mpirun -n 96 cpptraj.MPI -i Hbond_"${parmfile}".in > Hbond_"${parmfile}".out &
sleep 5
if [ -z "$string" ]
then
calc=$(pidof cpptraj.MPI | awk '{print $1}')
else
calc=$(pidof -o "${string}" cpptraj.MPI | awk '{print $1}')    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do tail --pid="${calc}" -f -n 1 Hbond_"${parmfile}".out ;done;
cd ../
}

function RMS {
mkdir RMS
cd RMS || exit
cat RMS.log

# read -re -p "Parameter File: " parm
# read -re -p "Trajectory File: " traj
# read -re -p "Reference File: " reference
# read -re -p "Protein Residues (Eg. 1-552): " residues

parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Parameter File: " parm 
#echo "parm=""$parm" >> Hbond.log
traj=$(zenity --file-selection --file-filter=*auto.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Trajectory File: " traj 
#echo "traj=""$traj" >> Hbond.log
reference=$(zenity --file-selection --file-filter=*.rst --title="Reference File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Active Site Residues (Eg. HD1,OY1 or their resid): " active 
#echo "active=""$active" >> Hbond.log
residues=$(zenity --entry --title="Protein Residues (Eg. 1-552@CA,ZN,FE,O,O1)")
[[ "$?" != "0" ]] && exit 1

{ date
	echo "parm=""$parm"
	echo "traj=""$traj"
	echo "reference=""$reference"
	echo "residues=""$residues"
} >> RMS.log
parmname=$(basename -- "$parm")
parmfile="${parmname%_*}"

trajname=$(basename -- "$traj")
trajfile="${trajname%_auto.*}"

residinp=$(basename -- "$residues")
residext="${residues#*-}"
residlast="${residext%%@*}"
#residfirst="${residinp%-*}"

cat > RMS_"${parmfile}".in << EOF
parm ${parm}
trajin ${traj}
reference ${reference}
rms reference out RMSD_${parmfile}.dat :${residues} time 0.1
atomicfluct reference out RMSF_${parmfile}.dat :${residues} byres
radgyr :${residues} out ROG_${parmfile}.dat time 0.1
surf :${residues} out SURF_${parmfile}.dat time 0.1
run
EOF
omit=$(pidof cpptraj.MPI)
string="${omit//${IFS:0:1}/,}"
nohup mpirun -n 32 cpptraj.MPI -i RMS_"${parmfile}".in > RMS_"${parmfile}".out &
sleep 5
if [ -z "$string" ]
then
calc=$(pidof cpptraj.MPI | awk '{print $1}')
else
calc=$(pidof -o "${string}" cpptraj.MPI | awk '{print $1}')    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do tail --pid="${calc}" -f -n 1 RMS_"${parmfile}".out ;done;

rmsd=RMSD_${parmfile}.dat
rmsf=RMSF_${parmfile}.dat
radgyr=ROG_${parmfile}.dat
surf=SURF_${parmfile}.dat

cat > RMS_"${parmfile}".gnu << EOF

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "RMSD_${parmfile}.eps";
p "${rmsd}" w l lc rgb "red" lw 1.0 notitle, \

reset

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Residues"
set ylabel "RMSF ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:${residlast}]

set output "RMSF_${parmfile}.eps";
p "${rmsf}" w l lc rgb "red" lw 1.0 notitle, \

reset

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "ROG ({\305})"
set key right top Left reverse
#set yrange [0:10]
#set xrange [0:${residlast}]

set output "ROG_${parmfile}.eps";
p "${radgyr}" u (\$1):(\$2) w l lc rgb "red" lw 1.0 notitle, \

reset

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "SAS ({\305})^2"
set key right bottom Left reverse
#set yrange [0:10]
#set xrange [0:1000]

set output "SURF_${parmfile}.eps";
p "${surf}" w l lc rgb "red" lw 1.0 notitle, \

EOF

gnuplot RMS_"${parmfile}".gnu

cd ../
}
function Autoimage() {
parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1

traj=$(zenity --file-selection --file-filter=*.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1

parmname=$(basename -- "$parm")
parmfile="${parmname%_*}"

trajname=$(basename -- "$traj")
trajfile="${trajname%.*}"

cat > Autoimage_"${parmfile}".in << EOF
parm ${parm}
trajin ${traj} 1 last 5
autoimage
trajout ${trajfile}_auto.nc
run
exit
EOF
nohup mpirun -n 32 cpptraj.MPI -i Autoimage_"${parmfile}".in -o Autoimage_"${parmfile}".out &
sleep 5
if [ -z "$string" ]
then
calc=$(pidof cpptraj.MPI | awk '{print $1}')
else
calc=$(pidof -o "${string}" cpptraj.MPI | awk '{print $1}')    
fi
sleep 5
while ps -p "${calc}" > /dev/null;do tail --pid="${calc}" -f -n 1 Autoimage_"${parmfile}".out ;done;

}
function DCCA() {
	mkdir DCCA
cd DCCA || exit
parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Parameter File: " parm 
#echo "parm=""$parm" >> Hbond.log
traj=$(zenity --file-selection --file-filter=*auto.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
residues=$(zenity --entry --title="Residues (Eg. 1-552)")
[[ "$?" != "0" ]] && exit 1
mask=$(zenity --entry --title="Mask (Eg. CA,ZN,FE,O,O1)")
[[ "$?" != "0" ]] && exit 1
cat > DCCA-firstframe.in << ENDOFFILE
parm $parm
trajin $traj 1 1
strip !(:$residues@$mask)
trajout firstframe_dcca.pdb
run
exit
ENDOFFILE

cat > DCCA-traj.in <<ENDOFFILE
parm $parm
trajin $traj 5000 10000
strip !(:$residues@$mask) outprefix stripdcca
trajout traj_dcca.dcd
trajout traj_dcca.nc
run
exit
ENDOFFILE


nohup cpptraj -i DCCA-firstframe.in > DCCA-firstframe.out &

nohup  cpptraj -i DCCA-traj.in > DCCA-traj.out &
process=$!
while ps -p $process > /dev/null;do sleep 1;done;

cat > DCCA.r <<ENDOFFILE
library(bio3d)
pdb = 'firstframe_dcca.pdb'
pdb = read.pdb(pdb)
dcd = "traj_dcca.dcd"
dcd = read.dcd(dcd)
ca.inds <- atom.select(pdb)
xyz <- fit.xyz(fixed=pdb\$xyz, mobile=dcd,
fixed.inds=ca.inds\$xyz,
mobile.inds=ca.inds\$xyz)
cij<-dccm(xyz[,ca.inds\$xyz])
plot(cij)
write.table(cij, file="DCCA.dat", quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
pdf(file = "DCCA.pdf", width = 12, height = 17, family = "Helvetica")
plot.dccm(cij, scales=list(cex=3), colorkey=list(labels=list(cex=3)),
  xlab=list(cex=3, label='Residue No.'), ylab=list(cex=3, label='Residue No.'),
  main=list(cex=3))
dev.off()
q()
ENDOFFILE
Rscript DCCA.r
cd ../
}
function PCA() {
	mkdir PCA
cd PCA || exit
parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Parameter File: " parm 
#echo "parm=""$parm" >> Hbond.log
traj=$(zenity --file-selection --file-filter=*auto.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
residues=$(zenity --entry --title="Residues (Eg. 1-552)")
[[ "$?" != "0" ]] && exit 1

cat > PCA-traj.in <<ENDOFFILE
parm $parm
trajin $traj 5001 10000
strip !(:$residues@CA) outprefix strippca
trajout traj_pca.dcd
run
exit
ENDOFFILE

cat > PCA-firstframe.in << ENDOFFILE
parm $parm
trajin $traj 5001 5001
strip !(:$residues@CA)
trajout firstframe_pca.pdb
run
exit
ENDOFFILE

nohup cpptraj -i PCA-firstframe.in > PCA-firstframe.out &
nohup cpptraj -i PCA-traj.in > PCA-traj.out &
process=$!
while ps -p $process > /dev/null;do sleep 1;done;


cat > PCA.r <<ENDOFFILE
library(bio3d)
pdb = 'firstframe_pca.pdb'
pdb = read.pdb(pdb)
dcd = "traj_pca.dcd"
dcd = read.dcd(dcd)
ca.inds <- atom.select(pdb)
xyz <- fit.xyz(fixed=pdb\$xyz, mobile=dcd,
fixed.inds=ca.inds\$xyz,
mobile.inds=ca.inds\$xyz)
pc <- pca.xyz(xyz[,ca.inds\$xyz])
pymol(pc, mode=1, file=NULL, scale=5, dual=FALSE, type="script", exefile=NULL)
plot(pc, col=bwr.colors(nrow(xyz)) )
jpeg('pca.jpg')
plot(pc, col=bwr.colors(nrow(xyz)) )
dev.off()
hc <- hclust(dist(pc\$z[,1:2]))
grps <- cutree(hc, k=2)
plot(pc, col=grps)
jpeg('pca1.jpg')
plot(pc, col=grps)
dev.off()
jpeg('pca2.jpg')
plot.bio3d(pc\$au[,1], ylab="PC1 (A)", xlab="Residue Position", typ="l")
points(pc\$au[,2], typ="l", col="blue")
dev.off()
p1 <- mktrj.pca(pc, pc=1, b=pc\$au[,1], file="pc1.pdb")
p2 <- mktrj.pca(pc, pc=2,b=pc\$au[,2], file="pc2.pdb")
q()
ENDOFFILE

Rscript PCA.r
cd ../
}
function Diff_DCCA() {
mkdir Diff_DCCA
cd Diff_DCCA || exit

wt=$(zenity --file-selection --file-filter=*.pdb --title="Select WT First Frame")
[[ "$?" != "0" ]] && exit 1
mut=$(zenity --file-selection --file-filter=*.pdb --title="Select Mutant First Frame")
[[ "$?" != "0" ]] && exit 1
wt_dcd=$(zenity --file-selection --file-filter=*.dcd --title="Select WT DCD file")
[[ "$?" != "0" ]] && exit 1
mut_dcd=$(zenity --file-selection --file-filter=*.dcd --title="Select Mutant DCD File")
[[ "$?" != "0" ]] && exit 1

cat > DCCA_Diff.r <<ENDOFFILE
library(bio3d)
pdb_wt = '$wt'
pdb_mut = '$mut'
pdb_wt = read.pdb(pdb_wt)
pdb_mut = read.pdb(pdb_mut)
dcd_wt = "$wt_dcd"
dcd_mut = "$mut_dcd"
dcd_wt = read.dcd(dcd_wt)
dcd_mut = read.dcd(dcd_mut)
ca_wt.inds <- atom.select(pdb_wt)
ca_mut.inds <- atom.select(pdb_mut)
xyz_wt <- fit.xyz(fixed=pdb_wt\$xyz, mobile=dcd_wt,
fixed.inds=ca_wt.inds\$xyz,
mobile.inds=ca_wt.inds\$xyz)
xyz_mut <- fit.xyz(fixed=pdb_mut\$xyz, mobile=dcd_mut,
fixed.inds=ca_mut.inds\$xyz,
mobile.inds=ca_mut.inds\$xyz)
cij_wt<-dccm(xyz_wt[,ca_wt.inds\$xyz])
cij_mut<-dccm(xyz_mut[,ca_mut.inds\$xyz])
plot(cij_wt)
plot(cij_mut)
cij_mut_wt = cij_mut - cij_wt
plot(cij_mut_wt)
write.table(cij_mut_wt, file="DCCA_Diff.dat", quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
pdf(file = "DCCA_Diff.pdf", width = 12, height = 17, family = "Helvetica")
plot.dccm(cij_mut_wt, scales=list(cex=3), colorkey=list(labels=list(cex=3)),
  xlab=list(cex=3, label='Residue No.'), ylab=list(cex=3, label='Residue No.'),
  main=list(cex=3))
dev.off()
q()

ENDOFFILE

Rscript DCCA_Diff.r

cd ../
}



function Exit() {
	exit 0
}
##


green='\e[32m'
blue='\e[34m'
red='\e[41m'
clear='\e[0m'

ColorGreen(){
	echo -ne "$green""$1""$clear"
}
ColorBlue(){
	echo -ne "$blue""$1""$clear"
}

menu(){
echo -ne "
Scan Menu
$(ColorGreen '1)') Autoimage 
$(ColorGreen '2)') RMSD,RMSF,ROG,SAS
$(ColorGreen '3)') Hydrogen Bond
$(ColorGreen '4)') DCCA
$(ColorGreen '5)') PCA
$(ColorGreen '6)') DCCA_Diff
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read -r a
        case $a in
	        1) Autoimage ; menu ;;
	        2) RMS ; menu ;;
			3) Hbond ; menu ;;
			4) DCCA ; menu ;;
			5) PCA ; menu ;;
			6) Diff_DCCA ; menu ;;
			0) Exit ;;
			*) echo -e "$red""Wrong option.""$clear";;
        esac
}
# Call the menu function
menu
