#!/bin/bash
## Execution example: ./EDA_whole -r 552 -s "276 278 356 533 534 535 546"
## Folder should include 3 files: rc/ts.opt.pdb rc/ts.prmtop Residue_E_Decomp_07_15.x
while getopts r:s: flag
do
    case "${flag}" in
        r) resid=${OPTARG};;
        s) residues=${OPTARG};;
        *) echo "usage: $0 [-r]" >&2
       exit 1 ;;
esac
done
function eda {
  cd "${dir}" || exit
  mkdir EDA
  cd EDA || exit
  cp ../"${1}".opt.pdb .
  cp ../"${1}".prmtop .
  total=$(sed -n 7p "${1}".prmtop | awk '{print $1}')
  totres=$(sed -n 8p "${1}".prmtop | awk '{print $2}')
  totprot=$(awk -v x="${resid}" '$5 == x { print $2 }' "${1}".opt.pdb | awk 'END { print $1 }')
  cpptraj << EOF
parm ${1}.prmtop
trajin ${1}.opt.pdb
trajout ${1}.opt.mdcrd crd
run
exit
EOF
cat > EDA.inp << EOF
${resid} !number of protein  residues
1 !number of files
${total} !total number of atoms
${totprot} !number of protein atoms
${totres} !number of total residues
2000 !max number of types
${1}.opt.mdcrd
EOF
cp ../../../Residue_E_Decomp_07_15.x .
./Residue_E_Decomp_07_15.x << EOF
EDA.inp
${1}.prmtop
EOF

for j in ${residues}
do

cat > rmagic-EDA-single-run_"${j}".r << ENDOFFILE
## Run this with "Rscript rmagic-EDA-avg.r"
## (Assuming you've already installed R...)

#-------------------------------------------#
#--Specify the paths to the Files from EDA--#
#-------------------------------------------#

## This script has been pre-built for a system with 3 replicates
## More or less than 3 reps (up to 5) can be achieved through
## Commenting or uncommenting

## Paths to the fort.803 (Coul) files
## Set A (system 1)
infile1Ac <- Sys.glob("${PWD}/fort.803")

## Paths to the fort.806 (VdW) files
## Set A (system A)
infile1Av <- Sys.glob("${PWD}/fort.806")

#-----------------------------#
#--Define your outfile names--#
#-----------------------------#

## A is for infiles labeled A
## Each system gets an averaged file
## Have one for Coulomb, one for vdW, and one for Coul+vdW (total)

A_coul <- "${PWD}/${1^^}_${j}_coul_avg.dat"
A_vdw <- "${PWD}/${1^^}_${j}_vdw_avg.dat"
A_tot <- "${PWD}/${1^^}_${j}_tot_avg.dat"

## Residue of interest (A matched with B, which matches do you care about?) (use 4 after decimal)
## Ex. If mutant is residue 100, this would be 100
## This script will remove the matches directly surrounding ROI for you
## Which is good because by not being just Coul and vdW, they're too dominant
ROI <- ${j}

#----------------------------------------------------------------------#
#---------Behind the Curtain: No Need to Modify Past This Line---------#
#----------------------------------------------------------------------#

## Use the data tables package to read in data frames
## Remove comment to install locally
#install.packages("data.table")
library(data.table)

## Use the tidyverse package to perform string replacement
## Remove comment to install locally
#install.packages("tidyverse")
library(tidyverse)

## Turn off scientific notation
options(scipen = 999)

#----------------------------#
#--Read in Coul EDA Scripts--#
#----------------------------#

## First line of file is number of frames used for EDA
## This is skipped by R's fread by default to avoid
## Irregular header information

## Reading each file as a data.table.
## Bonus - fread is much faster than read.csv
read1Ac <- fread(infile1Ac, header=FALSE)

colnames(read1Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")

## Combine all the datasets into 1
bound <- read1Ac

## Add in a blank row of the match for future plotting needs
extra <- data.frame(0, ROI, ROI, 0, 0)
bound <- rbind(bound, setNames(extra, names(read1Ac)))

#bound\$Index <- as.numeric(bound\$Index)
bound\$Index <- as.numeric(bound\$Index)
bound\$ResidueA <- as.numeric(bound\$ResidueA)
bound\$ResidueB <- as.numeric(bound\$ResidueB)
bound\$Coulomb <- as.numeric(bound\$Coulomb)
bound\$StdErr <- as.numeric(bound\$StdErr)

## Sort with that new zero row
bound <- bound[order(ResidueB),]

save_cols_Ac <- bound[,c("ResidueA", "ResidueB", "Coulomb")]

only_ROI_rows_Ac <- filter(save_cols_Ac, ResidueA == ROI | ResidueB == ROI)

## Change the NA from standard deviation to 0
only_ROI_rows_Ac[(ROI),4] <- 0

## Create a copy of the parsed data to format
clean_rows_Ac <- data.frame(only_ROI_rows_Ac)

## Pattern searching converted it to a character string, so back to numeric
clean_rows_Ac\$Coulomb <- as.numeric(clean_rows_Ac\$Coulomb)

## Limit to 4 sig figs after decimal
clean_rows_Ac\$Coulomb <- formatC(clean_rows_Ac\$Coulomb, digits=4, format="f")

## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {clean_rows_Ac[(ROI-1),3] <- 0
}
clean_rows_Ac[(ROI+1),3] <- 0

#------------------------------------------------------------------------#
#-----------------------------COUL OUTFILE-------------------------------#
#------------------------------------------------------------------------#

## Now write a tab-delimited outfile!
## Don't care about the index rownames
#write.table(clean_rows_Ac, file = A_coul, sep="\t", row.names=FALSE, quote=FALSE)

## Write a whitespace-delimited outfile!
sink(A_coul, type=c("output"))
print(clean_rows_Ac, row.names=FALSE)
sink()

#---------------------------#
#--Read in VDW EDA Scripts--#
#---------------------------#

## First line of file is number of frames used for EDA
## This is skipped by R's fread by default to avoid
## Irregular header information

## Reading each file as a data.table.
## Bonus - fread is much faster than read.csv
read1Av <- fread(infile1Av, header=FALSE)

colnames(read1Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")

## Combine all the datasets into 1
bound <- read1Av

## Add in a blank row of the match for future plotting needs
extra <- data.frame(0, ROI, ROI, 0, 0)
bound <- rbind(bound, setNames(extra, names(read1Av)))

## Sort with that new zero row
bound <- bound[order(ResidueB),]

#bound\$Index <- as.numeric(bound\$Index)
bound\$Index <- as.numeric(bound\$Index)
bound\$ResidueA <- as.numeric(bound\$ResidueA)
bound\$ResidueB <- as.numeric(bound\$ResidueB)
bound\$VdW <- as.numeric(bound\$VdW)
bound\$StdErr <- as.numeric(bound\$StdErr)


save_cols_Av <- bound[,c("ResidueA", "ResidueB", "VdW")]

only_ROI_rows_Av <- filter(save_cols_Av, ResidueA == ROI | ResidueB == ROI)

## Change the NA from standard deviation to 0
only_ROI_rows_Av[(ROI),4] <- 0

## Create a copy of the parsed data to format
clean_rows_Av <- data.frame(only_ROI_rows_Av)

## Pattern searching converted it to a character string, so back to numeric
clean_rows_Av\$VdW <- as.numeric(clean_rows_Av\$VdW)

## Limit to 4 sig figs after decimal
clean_rows_Av\$VdW <- formatC(clean_rows_Av\$VdW, digits=4, format="f")

## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {clean_rows_Av[(ROI-1),3] <- 0
}
clean_rows_Av[(ROI+1),3] <- 0

#------------------------------------------------------------------------#
#-----------------------------VDW OUTFILES-------------------------------#
#------------------------------------------------------------------------#

## Now write a tab-delimited outfile!
## Don't care about the index rownames
#write.table(clean_rows_Av, file = A_vdw, sep="\t", row.names=FALSE, quote=FALSE)

## Write a whitespace-delimited outfile!
sink(A_vdw, type=c("output"))
print(clean_rows_Av, row.names=FALSE)
sink()

#---------------------------------------#
#--Create the TOTAL (Coul + vdW) files--#
#---------------------------------------#

## Combine into one dataset
## Use all columns from _Ac and the VdW and VdWSD columns from _Av
## Note: this makes it a matrix
combine_Acv = cbind(clean_rows_Ac, clean_rows_Av[,3:4])

## Formatting the rows converted it to a character string, so back to numeric again!
combine_Acv\$Coulomb <- as.numeric(combine_Acv\$Coulomb)
combine_Acv\$VdW <- as.numeric(combine_Acv\$VdW)

## Your data are now ResidueA ResidueB AvgCoul AvgCoulSD AvgVdW AvgVdWSD
## Append a column called AvgIntTot thats the sum of AvgCoul and AvgVdW
combine_Acv\$IntTot <- (combine_Acv\$Coulomb + combine_Acv\$VdW)

## Create a new variable that's just ResidueA ResidueB AvgIntTot AvgStdDev
save_cols_tot <- combine_Acv[,c("ResidueA", "ResidueB", "IntTot")]

## Sanity Check!
## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {save_cols_tot[(ROI-1),3] <- 0
}
save_cols_tot[(ROI+1),3] <- 0

#------------------------------------------------------------------------#
#----------------------TOTAL INTERACTION OUTFILES------------------------#
#------------------------------------------------------------------------#

## Now write a tab-delimited outfile!
## Don't care about the index rownames
#write.table(save_cols_tot, file = A_tot, sep="\t", row.names=FALSE, quote=FALSE)

## Write a whitespace-delimited outfile!
sink(A_tot, type=c("output"))
print(save_cols_tot, row.names=FALSE)
sink()
ENDOFFILE

Rscript rmagic-EDA-single-run_"${j}".r

done
cd ../../../
}
function eda-diff {
   cd EDA || exit
   mkdir EDA-TS-RC
cd EDA-TS-RC || exit
if [ "$1" = "TS-RC" ]; then
  dir=3-TS
  state=TS
elif [ "$1" = "PD-RC" ]; then
 dir=4-PD
 state=PD
 fi
for k in ${residues}
do

cat > rmagic-EDA-single-diffs-nostd_"${k}".r << ENDOFFILE
## Run this with "Rscript rmagic-EDA-avg-diffs.r"
## (Assuming you've already installed R...)
#--------------------------------------------------------------#
#-----Specify the paths to the Files from rmagic-EDA-avg.r-----#
#--------------------------------------------------------------#
## This script has been pre-built for 2 systems that have gone through
## \`rmagic-EDA-avg.r\` (meaning there were replicates originally)
## Paths to the -tot- files
## Set A (system 1)
infileACV <- Sys.glob("${PWD}/../../../${dir}_Opt/EDA/${state}_${k}_tot_avg.dat")
##Set B (system 2)
infileBCV <- Sys.glob("${PWD}/../RC_${k}_tot_avg.dat")
#-----------------------------#
#--Define your outfile names--#
#-----------------------------#
## A - B
TOTAB <- "${PWD}/$1_${k}_tot_avg.dat"
## This is X in coul-X
## Y and Z are X+1 and X-1
## Other scripts call this the ROI
X_val <- "${k}"
#----------------------------------------------------------------------#
#---------Behind the Curtain: No Need to Modify Past This Line---------#
#----------------------------------------------------------------------#
## Use the data tables package to read in data frames
## Remove comment to install locally
#install.packages("data.table")
library(data.table)
## Use the abind package to combine data frames
## Remove comment to install locally
#install.packages("abind")
library(abind)
## Turn off scientific notation
options(scipen = 999)
#-------------------#
#--Begin with COUL--#
#-------------------#
## Reading each file as a data.table.
## Bonus - fread is much faster than read.csv
combineACV <- fread(infileACV, header=TRUE)
colnames(combineACV) <- c("R1", "R2", "TotAvg")
combineBCV <- fread(infileBCV, header=TRUE)
colnames(combineBCV) <- c("R1", "R2", "TotAvg")
## Redefine as a data frame
combineACV <- as.data.frame(combineACV)
combineBCV <- as.data.frame(combineBCV)
## They're not numbers, so make them numbers
combineACV\$TotAvg <- as.numeric(as.character(combineACV\$TotAvg))
combineBCV\$TotAvg <- as.numeric(as.character(combineBCV\$TotAvg))
## Combine A res numbers, tot average, tot average, tot stdev, tot stev
combineTotCV <- abind(combineACV[,1:3], combineBCV[,3], along=2)
## Rename the columns
colnames(combineTotCV) <- c("R1", "R2", "ATotalE", "BTotalE")
## Redefine as a data frame
combineTotCV <- as.data.frame(combineTotCV)
## If the R1 column doesn't equal X_val, use R1. Else, use R2.
combineTotCV\$Residue <- ifelse((combineTotCV\$R1 != X_val), as.numeric(as.character(combineTotCV\$R1)), as.numeric(as.character(combineTotCV\$R2)))
## They're not numbers, so make them numbers
combineTotCV\$ATotalE <- as.numeric(as.character(combineTotCV\$ATotalE))
combineTotCV\$BTotalE <- as.numeric(as.character(combineTotCV\$BTotalE))
## Multiply B * -1
## THIS WILL DO A - B!!
combineTotCV\$BTotalE <- (combineTotCV\$BTotalE*(-1.0000000000))
combineTotCV\$DiffE <- rowSums(combineTotCV[, c("ATotalE", "BTotalE")])
## Create a new variable with just Residue, DiffE, and AvgSTDEV
save_cols_total_CV <- combineTotCV[,c("Residue", "DiffE")]
## Limit to 8 sig figs after decimal
save_cols_clean_total_CV <- format(save_cols_total_CV, digits=8)
## Explicitly remove the two residues matched next to the residue of interest
## This is because it's more than interaction energy (stuff like bond E too)
## (Note: | is the or operator)
#save_cols_clean_total_CV <- save_cols_clean_total_CV[!(save_cols_clean_total_CV\$Residue == as.numeric(X_val)+1 | #save_cols_clean_total_CV\$Residue == as.numeric(X_val)-1),]
#---------------------------------------------------------------------#
#--------------------------TOT OUTFILES-------------------------------#
#---------------------------------------------------------------------#
## Now write a tab-delimited outfile!
## Don't care about the index rownames because that's the frame
#write.table(save_cols_clean_total_CV, file = TOTAB, sep="\t", row.names=FALSE, quote=FALSE)
## Write a whitespace-delimited outfile!
sink(TOTAB, type=c("output"))
print(save_cols_clean_total_CV, row.names=FALSE)
sink()
ENDOFFILE

Rscript rmagic-EDA-single-diffs-nostd_"${k}".r

done
cd ../../../../
}
#!/bin/bash

# Loop through directories with '_Opt' in their name
for dir in *_Opt; do
    if [ -d "$dir" ]; then
        echo "Found directory: $dir"
        if  [[ $dir == *"RC"* ]] ; then
          eda rc
        elif  [[ $dir == *"TS"* ]] ; then
          eda ts
        elif [[ $dir == *"IM"* ]] || [[ $dir == *"PD"* ]]; then
          eda pd
        fi
    fi
done
