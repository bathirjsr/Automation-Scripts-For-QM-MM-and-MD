#! /bin/bash

if [[ ! -e ../Analysis ]]; then
    mkdir ../Analysis
elif [[ ! -d ../Analysis ]]; then
    echo "Analysis already exists but is not a directory" 1>&2
fi
cp QM.pdb ../Analysis/.
declare -a dirs
i=1
for d in *_Opt
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"


for((i=1;i<=${#dirs[@]};i++))
do 
    cd ${i} || exit	
    proper << EOF
pop
log on
mulliken
q
EOF
    cp population ../../Analysis/population_${i}.txt
    cp coord ../../Analysis/coord_${i}
    cd ../
   
    cd ../Analysis || exit
    a=$(sed '$d' QM.pdb | awk 'END{print $2}')
    b=$(t2x coord_${i} | awk 'NR==1')
    sum=$(( b - a ))
    echo "${i}" > crd_tmp
    t2x coord_${i} | tail -n ${b} >> crd_tmp
    awk '{if (NR==1) print $0 ;if (NR !=1) print NR-1,$0}' crd_tmp > CoordData_${i}
    rm crd_tmp
    t2x coord_${i}| head -n -${sum} > qm_without_link.xyz
    t2x coord_${i}| tail -n ${sum} > qm_link.xyz
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
	awk -f calcdist.awk qm_link_nr.xyz qm_without_link_nr.xyz | sort -n -k3 | head -n 6 | awk '{$1+=61}1' | tail -n 4   > link_${i}.txt
	grep -A 75 "atom      charge" population_${i}.txt | sed '1d' | awk '{print $1,$2}' > ch_${i}.txt
	grep -A 20 "Unpaired electrons" population_${i}.txt > UNP_${i}.txt
        sed '1,3d' UNP_${i}.txt | awk '{print $1,$2}' > spin_${i}.txt
		for j in FE1 OY1 AG1 AP1 HD1 HD2 ADG
		do	
			if [ "${j}" = "FE1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' ch_${i}.txt)
			echo  "${i}" > Charge_${i}.txt
			echo ${j} "${tot}" >> Charge_${i}.txt
			spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_${i}.txt)
			echo  "${i}" > Spin_Density_${i}.txt
			echo ${j} "${spin}" >> Spin_Density_${i}.txt

			elif [ "${j}" = "OY1" ]; then
			res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')	
			tot=$(awk -v i="${res}" '$1==i {print $2}' ch_${i}.txt)
			echo ${j} "${tot}" >> Charge_${i}.txt
			spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_${i}.txt)
			echo ${j} "${spin}" >> Spin_Density_${i}.txt

			elif [ "${j}" = "AG1" ]; then
			x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}') 
			echo ${x} > Residues_${i}_${j}.txt
			tot=$(awk -f sum.awk Residues_${i}_${j}.txt ch_${i}.txt)
			echo ${j} "${tot}" >> Charge_${i}.txt
			spin=$(awk -f sum.awk Residues_${i}_${j}.txt spin_${i}.txt)
			echo ${j} "${spin}" >> Spin_Density_${i}.txt
			
			else
			#rm Residues_${j}.txt
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
					link=$(awk -f tmp_"${l}" link_${i}.txt)
					at=$(awk -f tmp1_"${l}" link_${i}.txt)				
					echo "${link}"
					echo "${at}"
					rm tmp_"${l}"
					rm tmp1_"${l}"					
					if [ -n "$link" ]; then
 					ch="${x} ${link}""h" 
					fi
				done
			echo ${ch}
			
			echo ${ch} > Residues_${i}_${j}.txt
			tot=$(awk -f sum.awk Residues_${i}_${j}.txt ch_${i}.txt)
			echo ${j} "${tot}" >> Charge_${i}.txt
			spin=$(awk -f sum.awk Residues_${i}_${j}.txt spin_${i}.txt)
			echo ${j} "${spin}" >> Spin_Density_${i}.txt
			fi
 		done
	cd - || exit
done
   cd ../Analysis || exit
########################################COMBINING FILES########################################################################
   paste Spin_Density_*| awk '{printf ("%5-s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6)}' > SpinDensity_.txt 
   paste Charge_* | awk '{printf ("%5-s\t%10s\t%10s\t%10s\n", $1,$2,$4,$6)}' > ChargeDistribution_.txt
########################################COMBINING FILES########################################################################
########################################REMOVING TMP UNWANTED FILES########################################################
   rm Charge_*  ch_* 
   rm Spin_Density_* spin_*
   rm Residues_*
########################################REMOVING TMP UNWANTED FILES########################################################
   cd - || exit
########################################COMBINING FILES########################################################################
cd ../Analysis || exit
for f in SpinDensity_* ; do sed -e '$s/$/\n/' $f ; done > SpinDensity.dat
for f in ChargeDistribution_* ; do sed -e '$s/$/\n/' $f ; done > ChargeDistribution.dat
for f in CoordData_* ; do sed -e '$s/$/\n/' $f ; done > Coordinates.dat
########################################COMBINING FILES########################################################################

########################################REMOVING TMP UNWANTED FILES########################################################
rm SpinDensity_* ChargeDistribution_* link_* CoordData_*
########################################REMOVING TMP UNWANTED FILES########################################################
cd - || exit
