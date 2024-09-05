#! /bin/bash
##To run the code type in the terminal:
## ./EF.sh -n 1 -c 447 -s RC or ./EF.sh -n 1 -c 447 -s TS or ./EF.sh -n 1 -c 447 -s IM
## -n is the residue number for N-Terminal residue,
## -c is the residue number for C-Terminal residue,
## -s is the step; possible choices are RC or TS or IM

## Changes required based on system:
## Residue names to get correct coordinate values (x1,y1,z1; x2,y2,z2)
## Residue number in cpptraj stripping command
## Names of non-standard amino acid names and their correct standard amino acid names

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

if [ "$step" = "RC" ]; then
if [ "$combo" = "FE-O" ]; then
mkdir EF_FE-O
cp rc.opt.pdb EF_FE-O/.
cp rc.prmtop EF_FE-O/.
cd EF_FE-O || exit

x1=$(awk '$4 == "FE1" && $3 == "FE" {print $6}' rc.opt.pdb)
y1=$(awk '$4 == "FE1" && $3 == "FE" {print $7}' rc.opt.pdb)
z1=$(awk '$4 == "FE1" && $3 == "FE" {print $8}' rc.opt.pdb)

#x2=$(awk '$4 == "O11" && $3 == "O1" {print $6}' rc.opt.pdb)
#y2=$(awk '$4 == "O11" && $3 == "O1" {print $7}' rc.opt.pdb)
#z2=$(awk '$4 == "O11" && $3 == "O1" {print $8}' rc.opt.pdb)

x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' rc.opt.pdb)
y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' rc.opt.pdb)
z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' rc.opt.pdb)

cp rc.opt.pdb rc.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm rc.prmtop
trajin rc.opt.pdb
reference rc.opt.pdb
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
FILE_TYPE = PDB

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

#CHARGE_SEQ = R(2,20)+P(35)

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

POINT_X = $x1
POINT_Y = $y1
POINT_Z = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (POINT_X,POINT_Y,POINT_Z).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE_FIELD = AMBER

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
elif [ "$combo" = "C1-C2" ]; then
mkdir EF_C1-C2
cp rc.opt.pdb EF_C1-C2/.
cp rc.prmtop EF_C1-C2/.
cd EF_C1-C2 || exit

x1=$(awk '$4 == "AG1" && $3 == "C2" {print $6}' rc.opt.pdb)
y1=$(awk '$4 == "AG1" && $3 == "C2" {print $7}' rc.opt.pdb)
z1=$(awk '$4 == "AG1" && $3 == "C2" {print $8}' rc.opt.pdb)

#x2=$(awk '$4 == "O11" && $3 == "O1" {print $6}' rc.opt.pdb)
#y2=$(awk '$4 == "O11" && $3 == "O1" {print $7}' rc.opt.pdb)
#z2=$(awk '$4 == "O11" && $3 == "O1" {print $8}' rc.opt.pdb)

x2=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' rc.opt.pdb)
y2=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' rc.opt.pdb)
z2=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' rc.opt.pdb)

cp rc.opt.pdb rc.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm rc.prmtop
trajin rc.opt.pdb
reference rc.opt.pdb
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
awk '{ if ($4 == "ADG") {print gensub (/[^[:blank:]]+/, "ARG", 4)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb
awk '{ if ($4 == "CYM" && $3 == "HN") {print gensub (/[^[:blank:]]+/, "H\ ", 3)} else {print $0}}' std.pdb > tmp && mv tmp std.pdb



cat > TITAN_QUANTIFICATION_PDB.inp <<ENDOFFILE
# TYPE OF OPERATION (CPC/SL/QUANT)
TYPE = QUANT

# INPUT FILE TYPE: TXT FILE (TXT), PDB FILE (PDB), OR GAUSSIAN LOG FILE (LOG) AS STARTING POINT
FILE_TYPE = PDB

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

#CHARGE_SEQ = R(2,20)+P(35)

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

POINT_X = $x1
POINT_Y = $y1
POINT_Z = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (POINT_X,POINT_Y,POINT_Z).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE_FIELD = AMBER

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
elif [ "$combo" = "Op-C1" ]; then
mkdir EF_Op-C1
cp rc.opt.pdb EF_Op-C1/.
cp rc.prmtop EF_Op-C1/.
cd EF_Op-C1 || exit

x1=$(awk '$4 == "AG1" && $3 == "C1" {print $6}' rc.opt.pdb)
y1=$(awk '$4 == "AG1" && $3 == "C1" {print $7}' rc.opt.pdb)
z1=$(awk '$4 == "AG1" && $3 == "C1" {print $8}' rc.opt.pdb)

#x2=$(awk '$4 == "O11" && $3 == "O1" {print $6}' rc.opt.pdb)
#y2=$(awk '$4 == "O11" && $3 == "O1" {print $7}' rc.opt.pdb)
#z2=$(awk '$4 == "O11" && $3 == "O1" {print $8}' rc.opt.pdb)

x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' rc.opt.pdb)
y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' rc.opt.pdb)
z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' rc.opt.pdb)

cp rc.opt.pdb rc.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm rc.prmtop
trajin rc.opt.pdb
reference rc.opt.pdb
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
FILE_TYPE = PDB

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

#CHARGE_SEQ = R(2,20)+P(35)

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

POINT_X = $x1
POINT_Y = $y1
POINT_Z = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (POINT_X,POINT_Y,POINT_Z).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE_FIELD = AMBER

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
elif [ "$step" = "TS" ]; then

mkdir EF
cp ts.opt.pdb EF/.
cp ts.prmtop EF/.
cd EF || exit

x1=$(awk '$4 == "FE1" && $3 == "FE" {print $6}' ts.opt.pdb)
y1=$(awk '$4 == "FE1" && $3 == "FE" {print $7}' ts.opt.pdb)
z1=$(awk '$4 == "FE1" && $3 == "FE" {print $8}' ts.opt.pdb)

#x2=$(awk '$4 == "O11" && $3 == "O1" {print $6}' ts.opt.pdb)
#y2=$(awk '$4 == "O11" && $3 == "O1" {print $7}' ts.opt.pdb)
#z2=$(awk '$4 == "O11" && $3 == "O1" {print $8}' ts.opt.pdb)

x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' ts.opt.pdb)
y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' ts.opt.pdb)
z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' ts.opt.pdb)


cp ts.opt.pdb ts.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm ts.prmtop
trajin ts.opt.pdb
reference ts.opt.pdb
strip !(:${nt}-${ct}) outprefix std
trajout std.pdb
run
exit
ENDOFFILE

nohup cpptraj -i cpptraj.in > cpptraj.out

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
FILE_TYPE = PDB

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

#CHARGE_SEQ = R(2,20)+P(35)

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

POINT_X = $x1
POINT_Y = $y1
POINT_Z = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (POINT_X,POINT_Y,POINT_Z).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE_FIELD = AMBER

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

elif [ "$step" = "IM" ]; then

mkdir EF
cp pd.opt.pdb EF/.
cp pd.prmtop EF/.
cd EF || exit

x1=$(awk '$4 == "FE1" && $3 == "FE" {print $6}' pd.opt.pdb)
y1=$(awk '$4 == "FE1" && $3 == "FE" {print $7}' pd.opt.pdb)
z1=$(awk '$4 == "FE1" && $3 == "FE" {print $8}' pd.opt.pdb)

#x2=$(awk '$4 == "O11" && $3 == "O1" {print $6}' pd.opt.pdb)
#y2=$(awk '$4 == "O11" && $3 == "O1" {print $7}' pd.opt.pdb)
#z2=$(awk '$4 == "O11" && $3 == "O1" {print $8}' pd.opt.pdb)

x2=$(awk '$4 == "OY1" && $3 == "O1" {print $6}' pd.opt.pdb)
y2=$(awk '$4 == "OY1" && $3 == "O1" {print $7}' pd.opt.pdb)
z2=$(awk '$4 == "OY1" && $3 == "O1" {print $8}' pd.opt.pdb)


cp pd.opt.pdb pd.opt.pdb.bk


cat > cpptraj.in <<ENDOFFILE
parm pd.prmtop
trajin pd.opt.pdb
reference pd.opt.pdb
strip !(:${nt}-${ct}) outprefix std
trajout std.pdb
run
exit
ENDOFFILE

nohup cpptraj -i cpptraj.in > cpptraj.out

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
FILE_TYPE = PDB

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

#CHARGE_SEQ = R(2,20)+P(35)

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

POINT_X = $x1
POINT_Y = $y1
POINT_Z = $z1

#______________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE DIRECTION = “SELECT”


DIRECTION_FILE = coords_ans

# DIRECTION VECTOR V
# V = (V2X-V1X, V2Y-V1Y, V2Z-V1Z)
# THE NUMBER OF THE ATOMS DETERMINING V: ATOM1(V1X, V1Y, V1Z) AND ATOM2(V2X, V2Y, V2Z)
# SELECTED FROM DIRECTION_FILE
#ATOM1 = 26
#ATOM2 = 25

# THE VALUE OF THE EF IS CALCULATED AT (POINT_X,POINT_Y,POINT_Z).
# THE NUMBER OF THE ATOM DETERMINING THIS POINT SELECTED FROM DIRECTION_FILE (ATOM_CENTER)

#ATOM_CENTER = 26

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “LOG”

# TYPE OF CHARGES TO BE READ FROM THE LOG FILE (NBO)
#TYPE_OF_CHARGES = NBO

___________________________________________________________________________________
# THE FOLLOWING PARAMETERS ARE ONLY RELEVANT IN CASE FILE = “PDB”

# FORCE FIELD OF CHOICE (AMBER/CHARMM)
FORCE_FIELD = AMBER

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
