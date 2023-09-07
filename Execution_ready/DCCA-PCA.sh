#! /bin/bash
#strip !(:1-466@CA,ZN,FE,O1,C5) outprefix strippedCAF (Oxo & mutants)
#RMSD, RMSF, Radius of Gyration, SASA

while getopts p:t:r:s:m: flag
do
    case "${flag}" in
        p) prmtop=${OPTARG};;
        t) traj=${OPTARG};;
	      r) residues=${OPTARG};;
        s) step=${OPTARG};;
        m) mask=${OPTARG};;
        *) echo "usage: $0 [-p] [-t] [-r] [-s] [-m]" >&2
         exit 1 ;;
esac
done
parm=$(zenity --file-selection --file-filter=*.prmtop --title="Select Parameter File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Parameter File: " parm 
#echo "parm=""$parm" >> Hbond.log
traj=$(zenity --file-selection --file-filter=*auto.nc --title="Select Trajectory File")
[[ "$?" != "0" ]] && exit 1
#read -re -p "Trajectory File: " traj 
#echo "traj=""$traj" >> Hbond.log
residues=$(zenity --entry --title="Protein Residues (Eg. 1-552)")
[[ "$?" != "0" ]] && exit 1
mask=$(zenity --entry --title="Mask (Eg. CA,ZN,FE,O,O1)")
[[ "$?" != "0" ]] && exit 1
if [ "$step" = "DCCA" ]; then

mkdir DCCA
cd DCCA || exit

cat > DCCA-firstframe.in << ENDOFFILE
parm $prmtop
trajin $traj 1 1
strip !(:$residues@$mask)
trajout firstframe_dcca.pdb
run
exit
ENDOFFILE

cat > DCCA-traj.in <<ENDOFFILE
parm $prmtop
trajin $traj 25000 50000
strip !(:$residues@$mask) outprefix stripdcca
trajout traj_dcca.dcd
run
exit
ENDOFFILE

nohup cpptraj.cuda -i DCCA-firstframe.in > DCCA-firstframe.out &
nohup cpptraj.cuda -i DCCA-traj.in > DCCA-traj.out &
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

elif [ "$step" = "PCA" ]; then

mkdir PCA
cd PCA || exit

cat > PCA-firstframe.in << ENDOFFILE
parm $prmtop
trajin $traj 1 1
strip !(:$residues@CA)
trajout firstframe_pca.pdb
run
exit
ENDOFFILE

cat > PCA-traj.in <<ENDOFFILE
parm $prmtop
trajin $traj 5000 10000
strip !(:$residues@CA) outprefix strippca
trajout traj_pca.dcd
run
exit
ENDOFFILE

nohup cpptraj.cuda -i PCA-firstframe.in > PCA-firstframe.out &
nohup cpptraj.cuda -i PCA-traj.in > PCA-traj.out &
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

fi
