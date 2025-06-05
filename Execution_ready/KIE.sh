
cd 1-RC_Opt || exit

source "${inp}"
jobname="RC-Frequency"
echo "Starting Frequency calculation"
mkdir Frequency_KIE
cp QM.dat Frequency_KIE/.
cp MM.dat Frequency_KIE/.
cp rc.opt.pdb Frequency_KIE/.
cp rc.opt.c Frequency_KIE/.
cp alpha Frequency_KIE/.
cp beta Frequency_KIE/.
cp control Frequency_KIE/.
cp parse_amber.tcl Frequency_KIE/.
cp rc.prmtop Frequency_KIE/.
cp input.in Frequency_KIE/.

cd Frequency_KIE/ || exit
sed -i "1s/rc.pdb/rc.opt.pdb/" myresidues.dat
job=$(pwd)
cat > RC_Freq.chm <<ENDOFFILE
global sys_name_id
source parse_amber.tcl
source QM.dat
source MM.dat
set sys_name_id rc.opt
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
set res [ pdb_to_res "\${sys_name_id}.pdb"]
set myresidues  [ inlist function=combine residues= \$res sets= {${myresidues}} target=QM ]
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
