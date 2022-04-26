#! /bin/bash
if [[ ! -e ../Analysis ]]; then
    mkdir ../Analysis
elif [[ ! -d ../Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi
rm ../Analysis/Energy.txt
cd ../MD/6-md/ || exit
cat > QM.tcl <<ENDOFFILE
mol load pdb rc.pdb
atomselect top "(resname FE1 OY1 SC1 GU1 HD1 HD2 and not backbone and not type HA H) or (resname M3L and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)"
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
for((i=1;i<=${#dirs[@]};i++))
do
  dirname=$(basename -- "${dirs[i]}")
  dirnumber="${dirname##*Frame}"
  echo "${dirnumber}"
  echo "$i" "${dirs[i]}"
  RC=$(grep 'Final converged energy' "${dirs[i]}"/1-RC_Opt/RC_dlfind.log|awk '{printf "%30f", $NF}') 
  RC_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/1-RC_Opt/SP/RC_SP.log|awk '{printf "%30f", $(NF-1)}')
  RC_ZPE=$(grep 'total ZPE' "${dirs[i]}"/1-RC_Opt/Frequency/RC_Freq.log|awk '{printf "%30f", $(NF-1)}'| awk '{printf "%30f", $1/(1000*4.184*627.5095)}')
  RC_B2_ZPE=$(awk -v t="$RC_SP" -v r="$RC_ZPE" 'BEGIN{printf "%30f", (t + r)}')
  TS=$(grep 'Final converged energy' "${dirs[i]}"/3-TS_Opt/TS_Opt.log|awk '{printf "%30f", $NF}')
  TS_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/3-TS_Opt/SP/TS_SP.log|awk '{printf "%30f", $(NF-1)}')
  TS_ZPE=$(grep 'total ZPE' "${dirs[i]}"/3-TS_Opt/Frequency/TS_Freq.log|awk '{printf "%30f", $(NF-1)}'| awk '{printf "%30f", $1/(1000*4.184*627.5095)}')
  TS_B2_ZPE=$(awk -v t="$TS_SP" -v r="$TS_ZPE" 'BEGIN{printf "%30f", (t + r)}')
  PD=$(grep 'Final converged energy' "${dirs[i]}"/4-PD_Opt/PD_Opt.log|awk '{printf "%30f", $NF}')
  PD_SP=$(grep 'Energy (     hybrid):' "${dirs[i]}"/4-PD_Opt/SP/PD_SP.log|awk '{printf "%30f", $(NF-1)}')
  PD_ZPE=$(grep 'total ZPE' "${dirs[i]}"/4-PD_Opt/Frequency/PD_Freq.log|awk '{printf "%30f", $(NF-1)}'| awk '{printf "%30f", $1/(1000*4.184*627.5095)}')
  PD_B2_ZPE=$(awk -v p="$PD_SP" -v r="$PD_ZPE" 'BEGIN{printf "%30f", (p + r)}')
  TSHAT=$(awk -v t="$TS" -v r="$RC" 'BEGIN{printf "%30f", (t - r)*627.5095}')
  TSHAT_ZPE=$(awk -v t="$TS_B2_ZPE" -v r="$RC_B2_ZPE" 'BEGIN{printf "%30f", (t - r)*627.5095}')
  PDHAT=$(awk -v p="$PD" -v r="$RC" 'BEGIN{printf "%30f", (p - r)*627.5095}')
  PDHAT_ZPE=$(awk -v p="$PD_B2_ZPE" -v r="$RC_B2_ZPE" 'BEGIN{printf "%30f", (p - r)*627.5095}')
  cd ../Analysis || exit
  cat > Whole_Energy_"${dirnumber}".txt << EOF
RC			${RC}		
RC_SP		${RC_SP}
RC_ZPE		${RC_ZPE}
RC_B2_ZPE	${RC_B2_ZPE}
TS			${TS}
TS_SP		${TS_SP}
TS_ZPE		${TS_ZPE}
TS_B2_ZPE	${TS_B2_ZPE}
PD			${PD}
PD_SP		${PD_SP}
PD_ZPE		${PD_ZPE}
PD_B2_ZPE	${PD_B2_ZPE}
EOF
	cat > Energy_"${dirnumber}".txt << EOF
Frame_Number	${dirnumber}         
RC				${RC}        
RC-B2+ZPE		${RC_B2_ZPE}        
TS				${TS}        
TS-B2+ZPE		${TS_B2_ZPE}        
PD				${PD}        
PD-B2+ZPE		${PD_B2_ZPE}        
HAT				${TSHAT}Kcal/mol
HAT_ZPE         ${TSHAT_ZPE}Kcal/mol
PD_Energy		${PDHAT}Kcal/mol
PD_Energy_ZPE	{PDHAT_ZPE}Kcal/mol
EOF
	cat > Reaction_"${dirnumber}".txt << EOF
1 0  RC
1.5 0

2.5  ${TSHAT_ZPE} TS
3  ${TSHAT_ZPE}

4 ${PDHAT_ZPE} PD
4.5 ${PDHAT_ZPE}
EOF

	gnuplot << EOF
set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24
set output "Reaction_"${dirnumber}".eps"
set xrange [0.5:5]
set ylabel "Energy (kcal/mol)" rotate by 90
set arrow from 1.5,0 to 2.5,${TSHAT_ZPE} nohead lc rgb 'red' lt 2
set arrow from 3,${TSHAT_ZPE} to 4,${PDHAT_ZPE} nohead lc rgb 'red' lt 2
unset xtics
unset key
plot 'Reaction_"${dirnumber}".txt' using 1:2 with lines lw 5 lc rgb 'blue', '' using 1:2:3 with labels offset 1,1 
EOF

  cd ../QMMM || exit
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
	echo "${dirnumber}" "${step}" > CoordData_"${dirnumber}"_${step}
	t2x coord_"${dirnumber}"_${step} | tail -n "${b}" >> CoordData_"${dirnumber}"_${step}	
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
END{printf "%30f", sum}
EOF
	awk -f calcdist.awk qm_link_nr.xyz qm_without_link_nr.xyz | sort -n -k3 | head -n 6 | awk '{$1+=61}1' | tail -n 4   > link_"${dirnumber}"_${step}.txt
	grep -A 65 "atom      charge" population_"${dirnumber}"_${step}.txt | sed '1d' | awk '{print $1,$2}' > Charge_"${dirnumber}"_${step}.txt
	grep -A 20 "Unpaired electrons" population_"${dirnumber}"_${step}.txt > UNP_"${dirnumber}"_${step}.txt
        sed '1,3d' UNP_"${dirnumber}"_${step}.txt | awk '{print $1,$2}' > spin_"${dirnumber}"_${step}.txt
		for j in FE1 OY1 SC1 GU1 HD1 HD2 M3L
		do	
			if [ "${j}" = "FE1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" > "${dirnumber}"_${step}.txt
			spin=$(awk -v i="${res}" '$1==i {printf "%20f", $2}' spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" > Spin_Density_"${dirnumber}"_${step}.txt

			elif [ "${j}" = "OY1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> "${dirnumber}"_${step}.txt
			spin=$(awk -v i="${res}" '$1==i {printf "%20f", $2}' spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt

			elif [ "${j}" = "SC1" ]; then
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo "${x}" > Residues_"${dirnumber}"_${step}_${j}.txt
			tot=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> "${dirnumber}"_${step}.txt
			spin=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt
			
			else
			#rm Residues_"${dirnumber}"_${j}.txt
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo "${x}"
			z=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2}')		
			echo "${z}"
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
			echo "${ch}"
			
			echo "${ch}" > Residues_"${dirnumber}"_${step}_${j}.txt
			tot=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> "${dirnumber}"_${step}.txt
			spin=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt spin_"${dirnumber}"_${step}.txt)
			echo ${j} "${spin}" >> Spin_Density_"${dirnumber}"_${step}.txt
			fi
 		done
	cd ../QMMM || exit
	fi	
    done
done
cd ../Analysis || exit
paste Energy_* | awk '{printf ("%15-s\t%10s\t%10s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6,$8,$10)}' > Energy.txt
cd ../QMMM || exit
