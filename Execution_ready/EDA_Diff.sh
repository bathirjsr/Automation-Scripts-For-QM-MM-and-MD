while getopts r:s: flag
do
    case "${flag}" in
          r) residues=${OPTARG};;
          s) sysname==${OPTARG};;
        *) echo "usage: $0 [-r]" >&2
       exit 1 ;;
esac
done
ls

read -p "TS Folder name" ts
ts_folder="${ts%-*}${ts#*-}"
ts_folder="${ts_folder%_*}"
read -p "RC Folder name" rc
rc_folder="${rc%-*}${rc#*-}"
rc_folder="${rc_folder%_*}"
if [[ $rc_folder == *"IM"* ]] || [[ $rc_folder == *"PD"* ]]; then
rc_final=PD
else
rc_final=RC
fi
mkdir EDA-$ts_folder-$rc_folder
cd EDA-$ts_folder-$rc_folder || exit
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
infileACV <- Sys.glob("${PWD}/../${ts}/EDA/TS_${k}_tot_avg.dat")
##Set B (system 2)
infileBCV <- Sys.glob("${PWD}/../${rc}/EDA/${rc_final}_${k}_tot_avg.dat")
#-----------------------------#
#--Define your outfile names--#
#-----------------------------#
## A - B
TOTAB <- "${PWD}/TS-RC_${k}_tot_avg.dat"
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
IFS=' ' read -ra residue_array <<< "$residues"
cat > Cumulative-EDA.r <<EOF
## Run this with "Rscript rmagic-EDA-avg-diffs.r"
## (Assuming you've already installed R...)

#--------------------------------------------------------------#
#-----Specify the paths to the Files from rmagic-EDA-avg.r-----#
#--------------------------------------------------------------#

## This script has been pre-built for 2 systems that have gone through
## rmagic-EDA-avg.r (meaning there were replicates originally)

## Paths to the -tot- files
## Set A (system 1)
infile1ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[0]}_tot_avg.dat")
infile2ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[1]}_tot_avg.dat")
infile3ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[2]}_tot_avg.dat")
infile4ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[3]}_tot_avg.dat")
infile5ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[4]}_tot_avg.dat")
infile6ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[5]}_tot_avg.dat")
infile7ACV <- Sys.glob("${PWD}/TS-RC_${residue_array[6]}_tot_avg.dat")



#-----------------------------#
#--Define your outfile names--#
#-----------------------------#

## A - B
TOTAB <- "${PWD}/TS-RC_tot_avg.dat"

## This is X in coul-X
## Y and Z are X+1 and X-1
## Other scripts call this the ROI
## X_val <- "247"

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
combineA1CV <- fread(infile1ACV, header=TRUE)
colnames(combineA1CV) <- c("R1", "TotAvg")
combineA2CV <- fread(infile2ACV, header=TRUE)
colnames(combineA2CV) <- c("R1", "TotAvg")
combineA3CV <- fread(infile3ACV, header=TRUE)
colnames(combineA3CV) <- c("R1", "TotAvg")
combineA4CV <- fread(infile4ACV, header=TRUE)
colnames(combineA4CV) <- c("R1", "TotAvg")
combineA5CV <- fread(infile5ACV, header=TRUE)
colnames(combineA5CV) <- c("R1", "TotAvg")
combineA6CV <- fread(infile6ACV, header=TRUE)
colnames(combineA6CV) <- c("R1", "TotAvg")
combineA7CV <- fread(infile7ACV, header=TRUE)
colnames(combineA7CV) <- c("R1", "TotAvg")


## Redefine as a data frame
combineA1CV <- as.data.frame(combineA1CV)
combineA2CV <- as.data.frame(combineA2CV)
combineA3CV <- as.data.frame(combineA3CV)
combineA4CV <- as.data.frame(combineA4CV)
combineA5CV <- as.data.frame(combineA5CV)
combineA6CV <- as.data.frame(combineA6CV)
combineA7CV <- as.data.frame(combineA7CV)

## They're not numbers, so make them numbers
combineA1CV\$TotAvg <- as.numeric(as.character(combineA1CV\$TotAvg))
combineA2CV\$TotAvg <- as.numeric(as.character(combineA2CV\$TotAvg))
combineA3CV\$TotAvg <- as.numeric(as.character(combineA3CV\$TotAvg))
combineA4CV\$TotAvg <- as.numeric(as.character(combineA4CV\$TotAvg))
combineA5CV\$TotAvg <- as.numeric(as.character(combineA5CV\$TotAvg))
combineA6CV\$TotAvg <- as.numeric(as.character(combineA6CV\$TotAvg))
combineA7CV\$TotAvg <- as.numeric(as.character(combineA7CV\$TotAvg))


## Combine A res numbers, tot average, tot average
combineTotCV <- abind(combineA1CV[,1:2], combineA2CV[,2],  combineA3CV[,2], combineA4CV[,2], combineA5CV[,2], combineA6CV[,2], combineA7CV[,2])

## Rename the columns
colnames(combineTotCV) <- c("R1", "1TotalE", "2TotalE", "3TotalE", "4TotalE", "5TotalE", "6TotalE", "7TotalE")

## Redefine as a data frame
combineTotCV <- as.data.frame(combineTotCV)

## If the R1 column doesn't equal X_val, use R1. Else, use R2.
combineTotCV\$Residue <- as.numeric(as.character(combineTotCV\$R1))

## They're not numbers, so make them numbers
## combineTotCV\$1TotalE <- as.numeric(as.character(combineTotCV\$1TotalE))
## combineTotCV\$2TotalE <- as.numeric(as.character(combineTotCV\$2TotalE))
## combineTotCV\$3TotalE <- as.numeric(as.character(combineTotCV\$3TotalE))
## combineTotCV\$4TotalE <- as.numeric(as.character(combineTotCV\$4TotalE))
## combineTotCV\$5TotalE <- as.numeric(as.character(combineTotCV\$5TotalE))
## combineTotCV\$6TotalE <- as.numeric(as.character(combineTotCV\$6TotalE))
## combineTotCV\$7TotalE <- as.numeric(as.character(combineTotCV\$7TotalE))


## Multiply B * -1
## THIS WILL DO A - B!!
## combineTotCV\$BTotalE <- (combineTotCV\$BTotalE*(-1.0000000000))
combineTotCV\$TotalDiffE <- rowSums(combineTotCV[, c("1TotalE", "2TotalE", "3TotalE", "4TotalE", "5TotalE", "6TotalE", "7TotalE")])


## Create a new variable with just Residue, DiffE, and AvgSTDEV
save_cols_total_CV <- combineTotCV[,c("Residue", "TotalDiffE")]

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
EOF

Rscript Cumulative-EDA.r

cp TS-RC_tot_avg.dat gnu.dat
sed "s/^[ \t]*//" -i gnu.dat

cat > plot.gnu <<ENDOFFILE
set encoding iso_8859_1
#set palette defined ( 0 "red", 1 "yellow", 2 "cyan", 3 "blue", 4 "magenta")
set terminal postscript eps enhanced color size 3in,3in 
set xlabel "Residue Number"
set ylabel "Energy (kcal/mol)"
set key right top
#set yrange [-2:2]
#set xrange [0:552]
#set title "EDA"
set output "EDA.eps";
plot "gnu.dat" u (\$1):(\$2) with impulses t "$sysname"
ENDOFFILE
for j in ${residues}

do

awk -v x=$j '$1!=x{print}' gnu.dat > tmp && mv tmp gnu.dat

done

gnuplot plot.gnu
convert -density 300 EDA.eps EDA.png

sort -n -k2 gnu.dat | head -n 5 > EDA_Res.txt && sort -n -k2 gnu.dat | tail -n 5 >> EDA_Res.txt
done
cd ../