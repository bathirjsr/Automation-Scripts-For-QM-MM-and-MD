#! /bin/bash
while getopts s:r: flag
do
    case "${flag}" in
	s) step=${OPTARG};;
	r) rebound=${OPTARG};;
	*) echo "usage: $0 [-s] [-r]" >&2
       exit 1 ;;
esac
done

if [[ ! -e ../Analysis ]]; then
    mkdir ../Analysis
elif [[ ! -d ../Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi
cd ../MD/6-md/ || exit
cat > QM.tcl <<ENDOFFILE
mol load pdb rc.pdb
atomselect top "(resname FE1 OY1 SC1 GU1 HD1 HD2 and not backbone and not type HA H) or (resname M2L and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)"
atomselect0 num
atomselect0 writepdb QM.pdb
exit
ENDOFFILE
vmd -dispdev text -e QM.tcl
cp QM.pdb ../../Analysis/.
cd ../../QMMM || exit
declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"

if [ "${step}" = "Energy" ]; then

for((i=1;i<=${#dirs[@]};i++))
do
  dirname=$(basename -- "${dirs[i]}")
  dirnumber="${dirname##*Frame}"
  echo "${dirnumber}"
  echo "$i" "${dirs[i]}"
######RC##########
  RC=$(grep 'Final converged energy' "${dirs[i]}"/1-RC_Opt/RC_dlfind.log|awk '{printf "%5.12f", $NF}') 
  RC_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/1-RC_Opt/SP/RC_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  RC_ZPE=$(grep 'total ZPE' "${dirs[i]}"/1-RC_Opt/Frequency/RC_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  RC_B2_ZPE=$(awk -v t="$RC_SP" -v r="$RC_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
#######TS###########
  TS=$(grep 'Final converged energy' "${dirs[i]}"/3-TS_Opt/TS_Opt.log|awk '{printf "%5.12f", $NF}')
  TS_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/3-TS_Opt/SP/TS_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  TS_ZPE=$(grep 'total ZPE' "${dirs[i]}"/3-TS_Opt/Frequency/TS_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  TS_B2_ZPE=$(awk -v t="$TS_SP" -v r="$TS_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
#######PD###########
  PD=$(grep 'Final converged energy' "${dirs[i]}"/4-PD_Opt/PD_Opt.log|awk '{printf "%5.12f", $NF}')
  PD_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/4-PD_Opt/SP/PD_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  PD_ZPE=$(grep 'total ZPE' "${dirs[i]}"/4-PD_Opt/Frequency/PD_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  PD_B2_ZPE=$(awk -v p="$PD_SP" -v r="$PD_ZPE" 'BEGIN{printf "%5.12f", (p + r)}')
  TSHAT=$(awk -v t="$TS" -v r="$RC" 'BEGIN{printf "%5.12f", (t - r)*627.5095}')
  TSHAT_ZPE=$(awk -v t="$TS_B2_ZPE" -v r="$RC_B2_ZPE" 'BEGIN{printf "%5.12f", (t - r)*627.5095}')
  PDHAT=$(awk -v p="$PD" -v r="$RC" 'BEGIN{printf "%5.12f", (p - r)*627.5095}')
  PDHAT_ZPE=$(awk -v p="$PD_B2_ZPE" -v r="$RC_B2_ZPE" 'BEGIN{printf "%5.12f", (p - r)*627.5095}')
########REBOUND#######
  if [ "${dirs[i]}" = "Frame${rebound}" ]; then
  RB_TS=$(grep 'Final converged energy' "${dirs[i]}"/Rebound/RB_TS/RB_TS_Opt.log|awk '{printf "%5.12f", $NF}')
  RB_TS_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/Rebound/RB_TS/SP/RB_TS_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  RB_TS_ZPE=$(grep 'total ZPE' "${dirs[i]}"/Rebound/RB_TS/Frequency/RB_TS_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  RB_TS_B2_ZPE=$(awk -v t="$RB_TS_SP" -v r="$RB_TS_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
  RB_PD=$(grep 'Final converged energy' "${dirs[i]}"/Rebound/RB_PD/RB_PD_Opt.log|awk '{printf "%5.12f", $NF}')
  RB_PD_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/Rebound/RB_PD/SP/RB_PD_SP.log|awk '{printf "%5.12f", $(NF-1)}')
  RB_PD_ZPE=$(grep 'total ZPE' "${dirs[i]}"/Rebound/RB_PD/Frequency/RB_PD_Freq.log|awk '{printf "%7.5f", $(NF-1)}'| awk '{printf "%5.12f", $1/(1000*4.184*627.5095)}')
  RB_PD_B2_ZPE=$(awk -v t="$RB_PD_SP" -v r="$RB_PD_ZPE" 'BEGIN{printf "%5.12f", (t + r)}')
  RBHAT_ZPE=$(awk -v p="$RB_TS_B2_ZPE" -v r="$PD_B2_ZPE" 'BEGIN{printf "%5.12f", (p - r)*627.5095}') 
  RB_PD_HAT_ZPE=$(awk -v p="$RB_PD_B2_ZPE" -v r="$RC_B2_ZPE" 'BEGIN{printf "%5.12f", (p - r)*627.5095}')
 cat > ../Analysis/Rebound_"${dirnumber}".txt << EOF
RB_TS		${RB_TS}
RB_TS_SP	${RB_TS_SP}
RB_TS_ZPE	${RB_TS_ZPE}
RB_TS_B2_ZPE	${RB_TS_B2_ZPE}		
RB_PD		${RB_PD}
RB_PD_SP	${RB_PD_SP}
RB_PD_ZPE	${RB_PD_ZPE}
RB_PD_B2_ZPE	${RB_PD_B2_ZPE}
RB_TS_HAT_ZPE	${RBHAT_ZPE}
RB_PD_HAT_ZPE	${RB_PD_HAT_ZPE}			
EOF
  fi 
  cd ../Analysis || exit
cat > Whole_Energy_"${dirnumber}".txt << EOF
Frame_Number	${dirnumber}         
RC		${RC}		
RC_SP		${RC_SP}
RC_ZPE		${RC_ZPE}
RC_B2_ZPE	${RC_B2_ZPE}
TS		${TS}
TS_SP		${TS_SP}
TS_ZPE		${TS_ZPE}
TS_B2_ZPE	${TS_B2_ZPE}
PD		${PD}
PD_SP		${PD_SP}
PD_ZPE		${PD_ZPE}
PD_B2_ZPE	${PD_B2_ZPE}
EOF
  cat > Energy_"${dirnumber}".txt << EOF
Frame_Number		${dirnumber}         
RC			${RC}        
RC-B2+ZPE		${RC_B2_ZPE}        
TS			${TS}        
TS-B2+ZPE		${TS_B2_ZPE}        
PD			${PD}        
PD-B2+ZPE		${PD_B2_ZPE}        
HAT                     ${TSHAT}Kcal/mol
HAT_ZPE                 ${TSHAT_ZPE}Kcal/mol
PD_Energy		${PDHAT}Kcal/mol
PD_Energy_ZPE		${PDHAT_ZPE}Kcal/mol
EOF

cd ../QMMM || exit

done

cd ../Analysis/ || exit
#paste Energy_* | awk '{printf ("%15-s\t%10s\t%10s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6,$8,$10)}' > Energy.dat
#paste Whole_Energy_* | awk '{printf ("%15-s\t%10s\t%10s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6,$8,$10)}' > Whole_Energy.dat
cat Energy_*  > Energy.dat
cat Whole_Energy_*  > Whole_Energy.dat
rm Energy_* Whole_Energy_*
cd ../QMMM || exit

elif [ "${step}" = "CS" ]; then

for((i=1;i<=${#dirs[@]};i++))
do
  dirname=$(basename -- "${dirs[i]}")
  dirnumber="${dirname##*Frame}"
  echo "${dirnumber}"
  echo "$i" "${dirs[i]}"
  for step in 1-RC_Opt 2-Scan 3-TS_Opt 4-PD_Opt
  do
   if [ "${step}" = "2-Scan" ]; then
    cp "${dirs[i]}"/${step}/SUMMARY.txt ../Analysis/summary_"${dirnumber}".txt	
    grep "structure" ../Analysis/summary_"${dirnumber}".txt > ../Analysis/sum_str_"${dirnumber}".txt
    grep "Energy" ../Analysis/summary_"${dirnumber}".txt > ../Analysis/sum_energy_"${dirnumber}".txt
    grep "Distance" ../Analysis/summary_"${dirnumber}".txt > ../Analysis/sum_distance_"${dirnumber}".txt
    paste ../Analysis/sum_str_"${dirnumber}".txt ../Analysis/sum_energy_"${dirnumber}".txt ../Analysis/sum_distance_"${dirnumber}".txt > ../Analysis/sum_"${dirnumber}".txt
    rm ../Analysis/sum_str_"${dirnumber}".txt ../Analysis/sum_energy_"${dirnumber}".txt ../Analysis/sum_distance_"${dirnumber}".txt ../Analysis/summary_"${dirnumber}".txt
   else
    cd "${dirs[i]}"/${step} || exit	
    proper << EOF
pop
log on
mulliken
q
EOF
    cp population ../../../Analysis/population_"${dirnumber}"_${step}.txt
    cp coord ../../../Analysis/coord_"${dirnumber}"_${step}
    cd ../../
   
    cd ../Analysis || exit
    a=$(sed '$d' QM.pdb | awk 'END{print $2}')
    b=$(t2x coord_"${dirnumber}"_${step} | awk 'NR==1')
    sum=$(( b - a ))
    echo "${dirnumber}" "${step}" > crd_tmp
    t2x coord_"${dirnumber}"_${step} | tail -n ${b} >> crd_tmp
    awk '{if (NR==1) print $0 ;if (NR !=1) print NR-1,$0}' crd_tmp > CoordData_"${dirnumber}"_${step}
    rm crd_tmp
    t2x coord_"${dirnumber}"_${step}| head -n -${sum} > qm_without_link.xyz
    t2x coord_"${dirnumber}"_${step}| tail -n ${sum} > qm_link.xyz
    awk '{ print $0, NR }' qm_link.xyz > qm_link_nr.xyz
    tail -n+3 qm_without_link.xyz | awk '{ print $0, NR }' > qm_without_link_nr.xyz

    cat > calcdist.awk << EOF
	{
	  # create associative arrays that store relevant information
	  # from both files - atom id and xyz co-ordinates
	  if (NR == FNR) {
	    x[FNR] = \$2":"\$3":"\$4":"\$5
	    n = FNR
	  } else {
	    y[FNR] = \$2":"\$3":"\$4":"\$5
	    m = FNR
	  }
	}
	END {
 	 # The distance calculating formula is
	  # SQRT ((X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2)
	  print "Distance between cross-product of atom pairs"
	  print "--------------------------------------------"
	  for (i=1; i<=n; i++) {
	    split(x[i], a, ":")
	    for (j=1; j<=m; j++) {
	      split(y[j], b, ":")
	      printf("%2d %2d %.8f\n",a[4],b[4],sqrt((a[1]-b[1])**2 + (a[2]-b[2])**2 + (a[3]-b[3])**2))
	    }
	  }
	}
EOF
	cat > sum.awk << EOF
BEGIN{sum = 0}
{if (NR == FNR)for ( i=1; i<=NF; i++) res[i] = \$i
if (NR != FNR) 
for (x in res)
	if (\$1 == res[x]){sum += \$2} }
END{printf "%2.5f", sum}
EOF
	awk -f calcdist.awk qm_link_nr.xyz qm_without_link_nr.xyz | sort -n -k3 | head -n 6 | awk '{$1+=61}1' | tail -n 4   > link_"${dirnumber}"_${step}.txt
	grep -A 65 "atom      charge" population_"${dirnumber}"_${step}.txt | sed '1d' | awk '{print $1,$2}' > ch_"${dirnumber}"_${step}.txt
	grep -A 20 "Unpaired electrons" population_"${dirnumber}"_${step}.txt > UNP_"${dirnumber}"_${step}.txt
        sed '1,3d' UNP_"${dirnumber}"_${step}.txt | awk '{print $1,$2}' > spin_"${dirnumber}"_${step}.txt
		for j in FE1 OY1 SC1 GU1 HD1 HD2 M2L
		do	
			if [ "${j}" = "FE1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${residue}" '$4==i {print $2 tolower($12)}') 

    # Calculate total charge
    tot=$(awk -v i="${res}" '$1==i {print $2}' ch_"${dirnumber}"_${step}.txt)
    echo "${dirnumber}" "${step}" > Charge_"${dirnumber}"_${step}.txt
    echo ${residue} "${tot}" >> Charge_"${dirnumber}"_${step}.txt

    # Calculate spin density
    spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_"${dirnumber}"_${step}.txt)
    echo "${dirnumber}" "${step}" > Spin_Density_"${dirnumber}"_${step}.txt
    echo ${residue} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt

			elif [ "${j}" = "OY1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' ch_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> Charge_"${dirnumber}"_${step}.txt
			spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt

			elif [ "${j}" = "SC1" ]; then
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo ${x} > Residues_"${dirnumber}"_${step}_${j}.txt
			tot=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt ch_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> Charge_"${dirnumber}"_${step}.txt
			spin=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt
			
			else
			#rm Residues_"${dirnumber}"_${j}.txt
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo ${x}
			z=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2}')		
			echo ${z}
			for l in ${z}	
				do	
cat > tmp_"${l}" << EOF
{if (\$2=="$l") {link = \$1}} END {print link} 
EOF
cat > tmp1_"${l}" << EOF
{if (\$2=="$l") {at = \$2}} END {print at} 
EOF
					link=$(awk -f tmp_"${l}" link_"${dirnumber}"_${step}.txt)
					at=$(awk -f tmp1_"${l}" link_"${dirnumber}"_${step}.txt)				
					echo "${link}"
					echo "${at}"
					rm tmp_"${l}"
					rm tmp1_"${l}"					
					if [ -n "$link" ]; then
 					ch="${x} ${link}""h" 
					fi
				done
			echo ${ch}
			
			echo ${ch} > Residues_"${dirnumber}"_${step}_${j}.txt
			tot=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt ch_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> Charge_"${dirnumber}"_${step}.txt
			spin=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt
			fi
 		done
	cd ../QMMM || exit
	fi	
    done
   cd ../Analysis || exit
########################################COMBINING FILES########################################################################
   paste Spin_Density_"${dirnumber}"_*| awk '{printf ("%5-s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6)}' > SpinDensity_"${dirnumber}".txt 
   paste Charge_"${dirnumber}"_* | awk '{printf ("%5-s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6)}' > ChargeDistribution_"${dirnumber}".txt
########################################COMBINING FILES########################################################################
########################################REMOVING TMP UNWANTED FILES########################################################
   rm Charge_"${dirnumber}"*  ch_"${dirnumber}"* 
   rm Spin_Density_"${dirnumber}"* spin_"${dirnumber}"*
   rm Residues_"${dirnumber}"_*
########################################REMOVING TMP UNWANTED FILES########################################################
   cd ../QMMM || exit
done
########################################COMBINING FILES########################################################################
cd ../Analysis || exit
for f in SpinDensity_* ; do sed -e '$s/$/\n/' $f ; done > SpinDensity.dat
for f in ChargeDistribution_* ; do sed -e '$s/$/\n/' $f ; done > ChargeDistribution.dat
for f in CoordData_* ; do sed -e '$s/$/\n/' $f ; done > Coordinates.dat
########################################COMBINING FILES########################################################################

########################################REMOVING TMP UNWANTED FILES########################################################
rm SpinDensity_* ChargeDistribution_* link_* CoordData_*
########################################REMOVING TMP UNWANTED FILES########################################################
cd ../QMMM || exit
fi