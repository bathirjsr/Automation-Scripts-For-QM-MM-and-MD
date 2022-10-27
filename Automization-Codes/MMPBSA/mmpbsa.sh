#!/bin/bash
while getopts p:t:c:r:l:s:n: flag
do
  case "${flag}" in
  p) prmtop=${OPTARG};;
  t) traj=${OPTARG};;
	c) complex=${OPTARG};;
  r) receptor=${OPTARG};;
	l) ligand=${OPTARG};;
	s) system=${OPTARG};;
	n) nprocs=${OPTARG};;
  *) echo "usage: $0 [-p] [-t] [-c] [-r] [-l] [-s] [-n]" >&2
       exit 1 ;;
esac
done
mkdir MMPBSA
cp "${prmtop}" MMPBSA/"${system}".prmtop
cd MMPBSA || exit
cpptraj.cuda << ENDOFFILE
parm ../${prmtop}
parmstrip !(:${complex})
parmwrite out complex_${system}.prmtop
run
exit
ENDOFFILE
cpptraj << ENDOFFILE
parm ../${prmtop}
parmstrip !(:${ligand})
parmwrite out ligand_${system}.prmtop
run
exit
ENDOFFILE
cpptraj << ENDOFFILE
parm ../${prmtop}
parmstrip !(:${receptor})
parmwrite out receptor_${system}.prmtop
run
exit
ENDOFFILE

cat > mmpbsa_"${system}".in << EOF
Input file for running PB and GB
&general
   startframe=1, endframe=10000, keep_files=2, debug_printlevel=0, verbose=1, receptor_mask=:${receptor}, ligand_mask=:${ligand},
   interval=10,
/
&gb
  igb=5, saltcon=0.100,
/

EOF
sed -i "9s/1/0/" ./*"${system}".prmtop
nohup mpirun -np "${nprocs}" MMPBSA.py -O -i mmpbsa_"${system}".in -o MMPBSA_"${system}".dat -sp "${system}".prmtop -cp complex_"${system}".prmtop -rp receptor_"${system}".prmtop -lp ligand_"${system}".prmtop -y ../"${traj}" > mmpbsa.out 2>&1
