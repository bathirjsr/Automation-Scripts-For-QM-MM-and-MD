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
mol selection resname FE1 OY1 HD1 HD2 AP1 AG1 SC1 Cl1 ${substrate}
mol representation CPK
mol addrep top
mol selection all
mol representation NewCartoon
mol addrep top
mol modstyle 2 0 0.5
EOF
vmd -e DCCA_Visual_${i}.dat