while getopts n:c:s:v: flag
do
    case "${flag}" in
        n) nt=${OPTARG};;
        c) ct=${OPTARG};;
        s) step=${OPTARG};;
        v) combo=${OPTARG};;
        *) echo "usage: $0 [-n] [-c] [-s]" >&2
       exit 1 ;;
esac
done
if [ "$step" = "scan" ]; then
ls -v *.pdb
read -p "Total number of structures{Remeber should have scan_0.pdb file in the current directory}" $count
for i in $(seq 0 $count); do

if [ "$combo" = "FE-O" ]; then
    mkdir EF_${combo}_${i}
    cp scan_${i}.pdb EF_${combo}_${i}/.
    cp scan.prmtop EF_${combo}_${i}/.
    cd EF_${combo}_${i} || exit
    x1=$(awk '$4 == "FE1" && $3 == "FE" {print $6}' scan_${i}.pdb)
    y1=$(awk '$4 == "FE1" && $3 == "FE" {print $7}' scan_${i}.pdb)
    z1=$(awk '$4 == "FE1" && $3 == "FE" {print $8}' scan_${i}.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' scan_${i}.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' scan_${i}.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' scan_${i}.pdb)
elif [ "$combo" = "Op-C1" ]; then
    mkdir EF_${combo}_${i}
    cp scan_${i}.pdb EF_${combo}_${i}/.
    cp scan.prmtop EF_${combo}_${i}/.
    cd EF_${combo}_${i} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' scan_${i}.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' scan_${i}.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' scan_${i}.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' scan_${i}.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' scan_${i}.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' scan_${i}.pdb)
elif [ "$combo" = "Od-C2" ]; then
    mkdir EF_${combo}_${i}
    cp scan_${i}.pdb EF_${combo}_${i}/.
    cp scan.prmtop EF_${combo}_${i}/.
    cd EF_${combo}_${i} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C2" {print $6}' scan_${i}.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C2" {print $7}' scan_${i}.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C2" {print $8}' scan_${i}.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O2" {print $6}' scan_${i}.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O2" {print $7}' scan_${i}.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O2" {print $8}' scan_${i}.pdb)
elif [ "$combo" = "C1-C2" ]; then
    mkdir EF_${combo}_${i}
    cp scan_${i}.pdb EF_${combo}_${i}/.
    cp scan.prmtop EF_${combo}_${i}/.
    cd EF_${combo}_${i} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' scan_${i}.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' scan_${i}.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' scan_${i}.pdb)

    x2=$(awk '$4 == "AG1" && $3 == "C2" {print $6}' scan_${i}.pdb)
    y2=$(awk '$4 == "AG1" && $3 == "C2" {print $7}' scan_${i}.pdb)
    z2=$(awk '$4 == "AG1" && $3 == "C2" {print $8}' scan_${i}.pdb)

fi
#cp scan_${i}.pdb scan_${i}.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm scan.prmtop
trajin scan_${i}.pdb
reference scan_${i}.pdb
strip !(:${nt}-${ct}) outprefix std_${i}
trajout std_${i}.pdb
run
exit
ENDOFFILE

nohup cpptraj -i cpptraj.in > cpptraj.out

#Changing non-standard residue names to standard amino acid names
awk '{ if ($4 == "AP1") {print gensub (/[^[:blank:]]+/, "ASP", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "HD1") {print gensub (/[^[:blank:]]+/, "HID", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "HD2") {print gensub (/[^[:blank:]]+/, "HID", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "CY1") {print gensub (/[^[:blank:]]+/, "CYM", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "CY2") {print gensub (/[^[:blank:]]+/, "CYM", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "HE1") {print gensub (/[^[:blank:]]+/, "HIE", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "GU1") {print gensub (/[^[:blank:]]+/, "GLU", 4)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb
awk '{ if ($4 == "CYM" && $3 == "HN") {print gensub (/[^[:blank:]]+/, "H\ ", 3)} else {print $0}}' std_${i}.pdb > tmp && mv tmp std_${i}.pdb



cat > TITAN_QUANTIFICATION_PDB.inp <<ENDOFFILE
# TYPE OF OPERATION (CPC/SL/QUANT)
TYPE = QUANT

# INPUT FILE TYPE: TXT FILE (TXT), PDB FILE (PDB), OR GAUSSIAN LOG FILE (LOG) AS STARTING POINT
FILE = PDB

# INPUT UNIT (BOHR OR ANS)
UNIT = ANS

# THE CHARGE DISTRIBUTION WILL BE READ FROM NAME.txt, NAME.pdb or NAME.log
# THE RESULT WILL BE WRITTEN IN NAME.ef

NAME = std_${i}

#  CHARGE_SELECT    |                     NOTE
#-----------------------------------------------------------------------
#      "ALL"        | ALL THE POINT CHARGES IN THE CHARGE DISTRIBUTION
#                   | ARE SELECTED FOR THE ELECTRIC FIELD CALCULATION.
#-----------------------------------------------------------------------
#      "PART"       | A PART OF CHARGES ARE SELECTED FROM THE CHARGE DISTRIBUTION.
#                   | (IN THIS CASE, THE "CHARGE_SEQ" KEYWORD NEEDS TO BE DEFINED)
#-----------------------------------------------------------------------

CHARGE_SELECT = ALL

# THE “CHARGE_SEQ" KEYWORD IS USED TO SELECT THE POINT CHARGES FOR CHARGE_SELECT = "PART"
# IT IS NOT NECESSARY TO SET THE "CHARGE_SEQ" KEYWORD WHEN CHARGE_SELECT = "ALL"
# FOR EXAMPLE, ”CHARGE_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)" MEANS:
# THE POINT CHARGES (PC) FROM NO. 3 TO NO. 10, THE PC NO. 20, THE PC NO. 3000, THE PC FROM
# NO. 400 TO NO. 403 AND PC NO. 50 ARE SELECTED FOR THE EF CALCULATIONS.

#CHARGE_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)

# THE DIRECTION VECTOR V CAN BE DEFINED IN TWO WAYS: EITHER BY SELECTING ATOMS IN A COORDINATE FILE (SELECT),
# OR BY INTRODUCING THE COORDINATES MANUALLY (MANUAL)

DIRECTION = MANUAL

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “MANUAL”

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE VALUE OF THE EF ALIGNED WITH THIS VECTOR IS CALCULATED.

V1X = $x1
V1Y = $y1
V1Z = $z1
V2X = $x2
V2Y = $y2
V2Z = $z2

# THE VALUE OF THE EF IS CALCULATED AT (XP,YP,ZP).

XP = $x1
YP = $y1
ZP = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


#DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (XP,YP,ZP).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG” OR FILE = "PDB"

# NAME OF THE CHARGE DISTRIBUTION GENERATED (NAME_CHARGE_DISTRIBUTION.txt BY DEFAULT).

NAME_CHARGE_DISTRIBUTION = std

#  ATOM_SELECT   |                     NOTE
#-----------------------------------------------------------------------
#      "ALL"        | ALL THE ATOMS IN THE PDB-FILE
#                   | ARE SELECTED FOR THE ELECTRIC FIELD CALCULATION.
#-----------------------------------------------------------------------
#      "PART"       | A PART OF THE ATOMS IN THE PDB-FILE ARE SELECTED.
#                   | (IN THIS CASE, THE “ATOM_SEQ" KEYWORD NEEDS TO BE DEFINED)
#-----------------------------------------------------------------------

ATOM_SELECT = ALL

# THE “ATOM_SEQ" KEYWORD IS USED TO SELECT THE ATOMS FOR ATOM_SELECT = "PART"
# IT IS NOT NECESSARY TO SET THE “ATOM_SEQ" KEYWORD WHEN ATOM_SELECT = "ALL"
# FOR EXAMPLE, ”ATOM_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)" MEANS:
# THE ATOMS FROM NO. 3 TO NO. 10, THE ATOM NO. 20, THE ATOM NO. 3000, THE ATOM FROM
# NO. 400 TO NO. 403 AND ATOM NO. 50 ARE SELECTED FOR THE EF CALCULATIONS.

#ATOM_SEQ = R(2,20)+P(35)

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE = AMBER

# THE RESIDUE NUMBER OF N TERMINAL AND C TERMINAL

# FOR EXAMPLE:
# IF NO. 4 RESIDUE IS THE N-TERMINAL OF THE PEPTIDE, PLEASE SET " N_TERMINAL = 4 "
# USE THE COMMAND: "  grep "HT1" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF N-TERMINAL.
# IF NO. 500 RESIDUE IS THE C-TERMINAL OF THE PEPTIDE, PLEASE SET " C_TERMINAL = 500 "
# USE THE COMMAND: "  grep "OT1" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF C-TERMINAL.

N_TERMINAL = $nt
C_TERMINAL = $ct

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB” & FORCE = “CHARMM”

# THE RESIDUE NUMBER OF ASPP, GLUP AND DISU

# IF THE RESIDUES OF THE PROTONATED ASP ARE E.G. NO. 235, 246 RESIDUES, PLEASE SET " ASPP = 235,246 "
# USE THE COMMAND: "  grep "HD2 ASP" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF PROTONATED ASP.
# IF THE RESIDUES OF THE PROTONATED GLU ARE E.G. NO. 250, 266 RESIDUES, PLEASE SET " GLUP = 250,266 "
# USE THE COMMAND: "  grep "HE2 GLU" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF PROTONATED GLU.
# IF NO. 300 CYS RESIDUE IS BONDED WITH NO. 340 CYS RESIDUE THROUGH A DISULFIDE BOND,
# THEN NO. 300 AND NO. 340 CYS ARE NOT PROTONATED. IN THIS CASE, PLEASE SET " DISU = 300,340 "
# USE THE COMMAND: "  grep "SG  CYS" PDB_FILE    " AND "  grep "HG1 CYS" PDB_FILE    "
# TO CONFIRM THE RESIDUE NUMBER OF UNPROTONATED CYS.

#ASPP =
#GLUP =
#DISU =
ENDOFFILE

titan.py TITAN_QUANTIFICATION_PDB.inp
cd ../
done
else
if [ "$combo" = "FE-O" ]; then
    mkdir EF_${combo}
    cp ${step,,}.opt.pdb EF_${combo}/.
    cp ${step,,}.prmtop EF_${combo}/.
    cd EF_${combo} || exit
    x1=$(awk '$4 == "FE1" && $3 == "FE" {print $6}' ${step,,}.opt.pdb)
    y1=$(awk '$4 == "FE1" && $3 == "FE" {print $7}' ${step,,}.opt.pdb)
    z1=$(awk '$4 == "FE1" && $3 == "FE" {print $8}' ${step,,}.opt.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' ${step,,}.opt.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' ${step,,}.opt.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' ${step,,}.opt.pdb)
elif [ "$combo" = "Op-C1" ]; then
    mkdir EF_${combo}
    cp ${step,,}.opt.pdb EF_${combo}/.
    cp ${step,,}.prmtop EF_${combo}/.
    cd EF_${combo} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' ${step,,}.opt.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' ${step,,}.opt.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' ${step,,}.opt.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' ${step,,}.opt.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' ${step,,}.opt.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' ${step,,}.opt.pdb)
elif [ "$combo" = "Od-C2" ]; then
    mkdir EF_${combo}
    cp ${step,,}.opt.pdb EF_${combo}/.
    cp ${step,,}.prmtop EF_${combo}/.
    cd EF_${combo} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C2" {print $6}' ${step,,}.opt.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C2" {print $7}' ${step,,}.opt.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C2" {print $8}' ${step,,}.opt.pdb)

    x2=$(awk '$4 == "OY1" && $3 == "O2" {print $6}' ${step,,}.opt.pdb)
    y2=$(awk '$4 == "OY1" && $3 == "O2" {print $7}' ${step,,}.opt.pdb)
    z2=$(awk '$4 == "OY1" && $3 == "O2" {print $8}' ${step,,}.opt.pdb)
elif [ "$combo" = "C1-C2" ]; then
    mkdir EF_${combo}
    cp ${step,,}.opt.pdb EF_${combo}/.
    cp ${step,,}.prmtop EF_${combo}/.
    cd EF_${combo} || exit
    x1=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' ${step,,}.opt.pdb)
    y1=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' ${step,,}.opt.pdb)
    z1=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' ${step,,}.opt.pdb)

    x2=$(awk '$4 == "AG1" && $3 == "C2" {print $6}' ${step,,}.opt.pdb)
    y2=$(awk '$4 == "AG1" && $3 == "C2" {print $7}' ${step,,}.opt.pdb)
    z2=$(awk '$4 == "AG1" && $3 == "C2" {print $8}' ${step,,}.opt.pdb)

fi
cp ${step,,}.opt.pdb ${step,,}.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm ${step,,}.prmtop
trajin ${step,,}.opt.pdb
reference ${step,,}.opt.pdb
strip !(:${nt}-${ct}) outprefix std
trajout std.pdb
run
exit
ENDOFFILE

nohup cpptraj -i cpptraj.in > cpptraj.out

#Changing non-standard residue names to standard amino acid names
awk '{ if ($4 == "AP1") {print gensub (/[^[:blank:]]+/, "ASP", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "HD1") {print gensub (/[^[:blank:]]+/, "HID", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "HD2") {print gensub (/[^[:blank:]]+/, "HID", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "CY1") {print gensub (/[^[:blank:]]+/, "CYM", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "CY2") {print gensub (/[^[:blank:]]+/, "CYM", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "HE1") {print gensub (/[^[:blank:]]+/, "HIE", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "GU1") {print gensub (/[^[:blank:]]+/, "GLU", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "CYM" && $3 == "HN") {print gensub (/[^[:blank:]]+/, "H\ ", 3)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb



cat > TITAN_QUANTIFICATION_PDB.inp <<ENDOFFILE
# TYPE OF OPERATION (CPC/SL/QUANT)
TYPE = QUANT

# INPUT FILE TYPE: TXT FILE (TXT), PDB FILE (PDB), OR GAUSSIAN LOG FILE (LOG) AS STARTING POINT
FILE = PDB

# INPUT UNIT (BOHR OR ANS)
UNIT = ANS

# THE CHARGE DISTRIBUTION WILL BE READ FROM NAME.txt, NAME.pdb or NAME.log
# THE RESULT WILL BE WRITTEN IN NAME.ef

NAME = std

#  CHARGE_SELECT    |                     NOTE
#-----------------------------------------------------------------------
#      "ALL"        | ALL THE POINT CHARGES IN THE CHARGE DISTRIBUTION
#                   | ARE SELECTED FOR THE ELECTRIC FIELD CALCULATION.
#-----------------------------------------------------------------------
#      "PART"       | A PART OF CHARGES ARE SELECTED FROM THE CHARGE DISTRIBUTION.
#                   | (IN THIS CASE, THE "CHARGE_SEQ" KEYWORD NEEDS TO BE DEFINED)
#-----------------------------------------------------------------------

CHARGE_SELECT = ALL

# THE “CHARGE_SEQ" KEYWORD IS USED TO SELECT THE POINT CHARGES FOR CHARGE_SELECT = "PART"
# IT IS NOT NECESSARY TO SET THE "CHARGE_SEQ" KEYWORD WHEN CHARGE_SELECT = "ALL"
# FOR EXAMPLE, ”CHARGE_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)" MEANS:
# THE POINT CHARGES (PC) FROM NO. 3 TO NO. 10, THE PC NO. 20, THE PC NO. 3000, THE PC FROM
# NO. 400 TO NO. 403 AND PC NO. 50 ARE SELECTED FOR THE EF CALCULATIONS.

#CHARGE_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)

# THE DIRECTION VECTOR V CAN BE DEFINED IN TWO WAYS: EITHER BY SELECTING ATOMS IN A COORDINATE FILE (SELECT),
# OR BY INTRODUCING THE COORDINATES MANUALLY (MANUAL)

DIRECTION = MANUAL

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “MANUAL”

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE VALUE OF THE EF ALIGNED WITH THIS VECTOR IS CALCULATED.

V1X = $x1
V1Y = $y1
V1Z = $z1
V2X = $x2
V2Y = $y2
V2Z = $z2

# THE VALUE OF THE EF IS CALCULATED AT (XP,YP,ZP).

XP = $x1
YP = $y1
ZP = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


#DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (XP,YP,ZP).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG” OR FILE = "PDB"

# NAME OF THE CHARGE DISTRIBUTION GENERATED (NAME_CHARGE_DISTRIBUTION.txt BY DEFAULT).

NAME_CHARGE_DISTRIBUTION = std

#  ATOM_SELECT   |                     NOTE
#-----------------------------------------------------------------------
#      "ALL"        | ALL THE ATOMS IN THE PDB-FILE
#                   | ARE SELECTED FOR THE ELECTRIC FIELD CALCULATION.
#-----------------------------------------------------------------------
#      "PART"       | A PART OF THE ATOMS IN THE PDB-FILE ARE SELECTED.
#                   | (IN THIS CASE, THE “ATOM_SEQ" KEYWORD NEEDS TO BE DEFINED)
#-----------------------------------------------------------------------

ATOM_SELECT = ALL

# THE “ATOM_SEQ" KEYWORD IS USED TO SELECT THE ATOMS FOR ATOM_SELECT = "PART"
# IT IS NOT NECESSARY TO SET THE “ATOM_SEQ" KEYWORD WHEN ATOM_SELECT = "ALL"
# FOR EXAMPLE, ”ATOM_SEQ = R(3,10)+P(20)+P(3000)+R(400,403)+P(50)" MEANS:
# THE ATOMS FROM NO. 3 TO NO. 10, THE ATOM NO. 20, THE ATOM NO. 3000, THE ATOM FROM
# NO. 400 TO NO. 403 AND ATOM NO. 50 ARE SELECTED FOR THE EF CALCULATIONS.

#ATOM_SEQ = R(2,20)+P(35)

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE = AMBER

# THE RESIDUE NUMBER OF N TERMINAL AND C TERMINAL

# FOR EXAMPLE:
# IF NO. 4 RESIDUE IS THE N-TERMINAL OF THE PEPTIDE, PLEASE SET " N_TERMINAL = 4 "
# USE THE COMMAND: "  grep "HT1" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF N-TERMINAL.
# IF NO. 500 RESIDUE IS THE C-TERMINAL OF THE PEPTIDE, PLEASE SET " C_TERMINAL = 500 "
# USE THE COMMAND: "  grep "OT1" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF C-TERMINAL.

N_TERMINAL = $nt
C_TERMINAL = $ct

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB” & FORCE = “CHARMM”

# THE RESIDUE NUMBER OF ASPP, GLUP AND DISU

# IF THE RESIDUES OF THE PROTONATED ASP ARE E.G. NO. 235, 246 RESIDUES, PLEASE SET " ASPP = 235,246 "
# USE THE COMMAND: "  grep "HD2 ASP" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF PROTONATED ASP.
# IF THE RESIDUES OF THE PROTONATED GLU ARE E.G. NO. 250, 266 RESIDUES, PLEASE SET " GLUP = 250,266 "
# USE THE COMMAND: "  grep "HE2 GLU" PDB_FILE    " TO CONFIRM THE RESIDUE NUMBER OF PROTONATED GLU.
# IF NO. 300 CYS RESIDUE IS BONDED WITH NO. 340 CYS RESIDUE THROUGH A DISULFIDE BOND,
# THEN NO. 300 AND NO. 340 CYS ARE NOT PROTONATED. IN THIS CASE, PLEASE SET " DISU = 300,340 "
# USE THE COMMAND: "  grep "SG  CYS" PDB_FILE    " AND "  grep "HG1 CYS" PDB_FILE    "
# TO CONFIRM THE RESIDUE NUMBER OF UNPROTONATED CYS.

#ASPP =
#GLUP =
#DISU =
ENDOFFILE

titan.py TITAN_QUANTIFICATION_PDB.inp
fi