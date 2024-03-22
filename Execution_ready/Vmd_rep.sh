while getopts c:p:s: flag
do
    case "${flag}" in
	c) pdb=${OPTARG};;
	p) prmtop=${OPTARG};;
    s) substrate=${OPTARG};;
esac
done

cat > DCCA_Visual_${i}.dat << EOF
mol new ${prmtop}
mol addfile ${pdb}
mol delrep 0 top
mol selection resname FE1 OY1 O11 HD1 HD2 AP1 GU1 AG1 SC1 Cl1 ${substrate}
mol representation CPK
mol addrep top
animate center
EOF
vmd -e DCCA_Visual_${i}.dat