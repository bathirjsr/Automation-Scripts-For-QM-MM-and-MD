library(bio3d)
pdb_wt = 'firstframe_dcca_wt.pdb'
pdb_mut = 'firstframe_dcca.pdb'
pdb_wt = read.pdb(pdb_wt)
pdb_mut = read.pdb(pdb_mut)
dcd_wt = "traj_dcca_wt.dcd"
dcd_mut = "traj_dcca.dcd"
dcd_wt = read.dcd(dcd_wt)
dcd_mut = read.dcd(dcd_mut)
ca_wt.inds <- atom.select(pdb_wt)
ca_mut.inds <- atom.select(pdb_mut)
xyz_wt <- fit.xyz(fixed=pdb_wt$xyz, mobile=dcd_wt,
fixed.inds=ca_wt.inds$xyz,
mobile.inds=ca_wt.inds$xyz)
xyz_mut <- fit.xyz(fixed=pdb_mut$xyz, mobile=dcd_mut,
fixed.inds=ca_mut.inds$xyz,
mobile.inds=ca_mut.inds$xyz)
cij_wt<-dccm(xyz_wt[,ca_wt.inds$xyz])
cij_mut<-dccm(xyz_mut[,ca_mut.inds$xyz])
plot(cij_wt)
plot(cij_mut)
cij_mut_wt = cij_mut - cij_wt
plot(cij_mut_wt)
write.table(cij_mut_wt, file="DCCA_Mut_WT.dat", quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
pdf(file = "DCCA_Mut_WT.pdf", width = 12, height = 17, family = "Helvetica")
plot.dccm(cij_mut_wt, scales=list(cex=3), colorkey=list(labels=list(cex=3)),
  xlab=list(cex=3, label='Residue No.'), ylab=list(cex=3, label='Residue No.'),
  main=list(cex=3))
dev.off()
q()
