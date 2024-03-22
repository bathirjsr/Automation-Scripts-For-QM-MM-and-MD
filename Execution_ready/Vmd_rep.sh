while getopts c:p:r: flag
do
    case "${flag}" in
	c) pdb=${OPTARG};;
	p) prmtop=${OPTARG};;
    r) representation=${OPTARG};;
esac
done

cat > DCCA_Visual_${i}.dat << EOF
mol new ${prmtop}
mol addfile ${pdb}
mol delrep 0 top
mol selection ${representation}
mol representation CPK
mol addrep top
mol representation NewCartoon 0.1 20
mol addrep top
mol modstyle 2 0 0.5
EOF
vmd -e DCCA_Visual_${i}.dat