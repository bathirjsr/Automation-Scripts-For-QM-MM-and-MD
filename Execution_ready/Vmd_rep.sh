while getopts c:p:s: flag
do
    case "${flag}" in
	c) coordinate=${OPTARG};;
	p) prmtop=${OPTARG};;
    s) substrate=${OPTARG};;
esac
done
filename="${coordinate##*/}"
filext="${filename##*.}"
file="${filename%.*}"
vmd -dispdev win -e << EOF 
set file $file
set ext  $filext
if { \$ext == "pdb"} {
    mol new ${prmtop}
    mol load pdb ${coordinate}
    mol delrep 0 top
    mol selection resname FE1 OY1 O11 HD1 HD2 AP1 GU1 AG1 SC1 Cl1 ${substrate}
    mol representation CPK
    mol addrep top
} elseif { \$ext == "nc"} {
    mol new ${prmtop}
    mol addfile ${coordinate} first 0 last -1 step 1 waitfor all
    mol selection resname FE1 OY1 O11 HD1 HD2 AP1 GU1 AG1 SC1 Cl1 ${substrate}
    mol representation CPK
    mol addrep top
} else {
    # Handle other file types or show an error/message
    puts "Unsupported file type: $ext"
}
EOF