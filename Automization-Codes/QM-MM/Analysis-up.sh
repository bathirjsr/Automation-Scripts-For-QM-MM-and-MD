#! /bin/bash
if [[ ! -e ../Analysis ]]; then
    mkdir ../Analysis
elif [[ ! -d ../Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi
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
END{print sum}
EOF
	awk -f calcdist.awk qm_link_nr.xyz qm_without_link_nr.xyz | sort -n -k3 | head -n 6 | awk '{$1+=61}1' | tail -n 4   > link_"${dirnumber}"_${step}.txt
	rm "${dirnumber}"_${step}.txt	
	grep -A 65 "atom      charge" population_"${dirnumber}"_${step}.txt | sed '1d' | awk '{print $1,$2}' > Charge_"${dirnumber}"_${step}.txt
	grep -A 10 "Unpaired electrons" population_"${dirnumber}"_${step}.txt > UNP_"${dirnumber}"_${step}.txt

		for j in FE1 OY1 SC1 GU1 HD1 HD2 M3L
		do	
			if [ "${j}" = "FE1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" > "${dirnumber}"_${step}.txt
			elif [ "${j}" = "OY1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> "${dirnumber}"_${step}.txt
			elif [ "${j}" = "SC1" ]; then
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo "${x}" > Residues_"${dirnumber}"_${step}_${j}.txt
			tot=$(awk -f sum.awk Residues_"${dirnumber}"_${step}_${j}.txt Charge_"${dirnumber}"_${step}.txt)
			echo ${j} "${tot}" >> "${dirnumber}"_${step}.txt			
			else
			rm Residues_"${dirnumber}"_${j}.txt
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
			fi
 		done
	cd ../QMMM || exit
	fi	
    done
done

