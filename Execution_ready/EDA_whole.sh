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
cp ../../Residue_E_Decomp_07_15.x .
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
## How many data sets to add (use 4 after decimal)
sets <- 1.0000
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
#read2Ac <- fread(infile2Ac, header=FALSE)
#read3Ac <- fread(infile3Ac, header=FALSE)
#read4Ac <- fread(infile4Ac, header=FALSE)
#read5Ac <- fread(infile5Ac, header=FALSE)

colnames(read1Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")
#colnames(read2Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")
#colnames(read3Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")
#colnames(read4Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")
#colnames(read5Ac) <- c("Index", "ResidueA", "ResidueB", "Coulomb", "StdErr")

## Combine all the datasets into 1
bound <- rbind(read1Ac)
#bound <- rbind(read1Ac, read2Ac, read3Ac, read4Ac, read5Ac)

## Add in a blank row of the match for future plotting needs
extra <- data.frame(0, ROI, ROI, 0, 0)
bound <- rbind(bound, setNames(extra, names(read1Ac)))

#bound\$Index <- as.numeric(bound\$Index)
bound\$Index <- as.numeric(bound\$Index)
bound\$ResidueA <- as.numeric(bound\$ResidueA)
bound\$ResidueB <- as.numeric(bound\$ResidueB)
bound\$Coulomb <- as.numeric(bound\$Coulomb)
bound\$StdErr <- as.numeric(bound\$StdErr)

## Collapse repeat lines into themselves (i.e. add numbers together)
superbound_avg <- aggregate(data=bound, cbind(Coulomb,StdErr)~ResidueA+ResidueB, FUN=sum)
##superbound_sd <- aggregate(data=bound, cbind(Coulomb,StdErr)~ResidueA+ResidueB, FUN=sd)

## Get average based on number of sets combined [This if for 3]
superbound_avg\$AvgCoulomb <- format(superbound_avg\$Coulomb / sets, digits=4, format="f")
##superbound_avg\$AvgCoulombSD <- format(superbound_sd\$Coulomb / sets, digits=4, format="f")

## If you for some reason care about StdErr, then you'd uncomment this
## Yes, it's weird that StdErr has a SD, but that's just a sanity thing
#superbound_avg\$AvgStdErr <- format(superbound_avg\$StdErr / sets, digits=4, format="f")
#superbound_avg\$AvgStdErrSD <- format(superbound_sd\$StdErr / sets, digits=4, format="f")

save_cols_Ac <- superbound_avg[,c("ResidueA", "ResidueB", "AvgCoulomb")]
##save_cols_Ac <- superbound_avg[,c("ResidueA", "ResidueB", "AvgCoulomb", "AvgCoulombSD", "AvgStdErr", "AvgStdErrSD")]

only_ROI_rows_Ac <- filter(save_cols_Ac, ResidueA == ROI | ResidueB == ROI)

## Change the NA from standard deviation to 0
only_ROI_rows_Ac[(ROI),4] <- 0

## Create a copy of the parsed data to format
clean_rows_Ac <- data.frame(only_ROI_rows_Ac)

## Pattern searching converted it to a character string, so back to numeric
clean_rows_Ac\$AvgCoulomb <- as.numeric(clean_rows_Ac\$AvgCoulomb)
##clean_rows_Ac\$AvgCoulombSD <- as.numeric(clean_rows_Ac\$AvgCoulombSD)

## Limit to 4 sig figs after decimal
clean_rows_Ac\$AvgCoulomb <- formatC(clean_rows_Ac\$AvgCoulomb, digits=4, format="f")
##clean_rows_Ac\$AvgCoulombSD <- formatC(clean_rows_Ac\$AvgCoulombSD, digits=4, format="f")

## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {clean_rows_Ac[(ROI-1),3] <- 0
clean_rows_Ac[(ROI-1),3] <- 0
}
clean_rows_Ac[(ROI+1),3] <- 0
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
#read2Av <- fread(infile2Av, header=FALSE)
#read3Av <- fread(infile3Av, header=FALSE)
#read4Av <- fread(infile4Av, header=FALSE)
#read5Av <- fread(infile5Av, header=FALSE)

colnames(read1Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")
#colnames(read2Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")
#colnames(read3Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")
#colnames(read4Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")
#colnames(read5Av) <- c("Index", "ResidueA", "ResidueB", "VdW", "StdErr")

## Combine all the datasets into 1
bound <- rbind(read1Av)
#bound <- rbind(read1Av, read2Av, read3Av, read4Av, read5Av)

## Add in a blank row of the match for future plotting needs
extra <- data.frame(0, ROI, ROI, 0, 0)
bound <- rbind(bound, setNames(extra, names(read1Av)))

#bound\$Index <- as.numeric(bound\$Index)
bound\$Index <- as.numeric(bound\$Index)
bound\$ResidueA <- as.numeric(bound\$ResidueA)
bound\$ResidueB <- as.numeric(bound\$ResidueB)
bound\$VdW <- as.numeric(bound\$VdW)
bound\$StdErr <- as.numeric(bound\$StdErr)

## Collapse repeat lines into themselves (i.e. add numbers together)
superbound_avg <- aggregate(data=bound, cbind(VdW,StdErr)~ResidueA+ResidueB, FUN=sum)
##superbound_sd <- aggregate(data=bound, cbind(VdW,StdErr)~ResidueA+ResidueB, FUN=sd)

## Get average based on number of sets combined [This if for 3]
superbound_avg\$AvgVdW <- format(superbound_avg\$VdW / sets, digits=4, format="f")
##superbound_avg\$AvgVdWSD <- format(superbound_sd\$VdW / sets, digits=4, format="f")

## If you for some reason care about StdErr, then you'd uncomment this
## Yes, it's weird that StdErr has a SD, but that's just a sanity thing
#superbound_avg\$AvgStdErr <- format(superbound_avg\$StdErr / sets, digits=4, format="f")
##superbound_avg\$AvgStdErrSD <- format(superbound_sd\$StdErr / sets, digits=4, format="f")

save_cols_Av <- superbound_avg[,c("ResidueA", "ResidueB", "AvgVdW")]
##save_cols_Av <- superbound_avg[,c("ResidueA", "ResidueB", "AvgVdW", "AvgStdErr", "AvgStdErrSD")]

only_ROI_rows_Av <- filter(save_cols_Av, ResidueA == ROI | ResidueB == ROI)

## Change the NA from standard deviation to 0
only_ROI_rows_Av[(ROI),4] <- 0

## Create a copy of the parsed data to format
clean_rows_Av <- data.frame(only_ROI_rows_Av)

## Pattern searching converted it to a character string, so back to numeric
clean_rows_Av\$AvgVdW <- as.numeric(clean_rows_Av\$AvgVdW)
##clean_rows_Av\$AvgVdWSD <- as.numeric(clean_rows_Av\$AvgVdWSD)

## Limit to 4 sig figs after decimal
clean_rows_Av\$AvgVdW <- formatC(clean_rows_Av\$AvgVdW, digits=4, format="f")
##clean_rows_Av\$AvgVdWSD <- formatC(clean_rows_Av\$AvgVdWSD, digits=4, format="f")

## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {clean_rows_Av[(ROI-1),3] <- 0
clean_rows_Av[(ROI-1),3] <- 0
}
clean_rows_Av[(ROI+1),3] <- 0
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
combine_Acv\$AvgCoulomb <- as.numeric(combine_Acv\$AvgCoulomb)
##combine_Acv\$AvgCoulombSD <- as.numeric(combine_Acv\$AvgCoulombSD)
combine_Acv\$AvgVdW <- as.numeric(combine_Acv\$AvgVdW)
##combine_Acv\$AvgVdWSD <- as.numeric(combine_Acv\$AvgVdWSD)

## Your data are now ResidueA ResidueB AvgCoul AvgCoulSD AvgVdW AvgVdWSD
## Append a column called AvgIntTot thats the sum of AvgCoul and AvgVdW
combine_Acv\$AvgIntTot <- (combine_Acv\$AvgCoulomb + combine_Acv\$AvgVdW)

## Now append a column that's the avg standard deviation
##combine_Acv\$AvgStdDev <- (combine_Acv\$AvgCoulombSD + combine_Acv\$AvgVdWSD) / 2

## Create a new variable that's just ResidueA ResidueB AvgIntTot AvgStdDev
save_cols_tot <- combine_Acv[,c("ResidueA", "ResidueB", "AvgIntTot")]

## Sanity Check!
## Set the two residues surrounding the ROI to zero
## This is because energy is overpowering due to other energy terms
## So if ROI=100, you remove matches between 99 & 100 as well as 100 & 101
if (ROI != 1) {save_cols_tot[(ROI-1),3] <- 0
save_cols_tot[(ROI-1),3] <- 0
}
save_cols_tot[(ROI+1),3] <- 0
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
cd ../../
}
function eda-diff {

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
