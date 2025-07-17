#! /bin/bash
#!/bin/bash

steps=(
"1-RC_Opt" "3-metaTS_Opt" "4-metaIM_Opt" "3-TS_Opt" 
"4-PD_Opt" "6-Cl_TS_Opt" "7-Cl-PD_Opt" "6-OH_TS_Opt" "7-OH-PD_Opt"
)

for step in "${steps[@]}"; do
    cd "${step}" || exit

    proper << EOF
pop
log on
mulliken
q
EOF

    cp population ../population_"${step}".txt
    cp coord ../coord_"${step}"
    cd ../

    a=$(sed '$d' QM.pdb | awk 'END{print $2}')
    b=$(t2x coord_"${step}" | awk 'NR==1')
    sum=$(( b - a ))

    echo "${step}" > crd_tmp
    t2x coord_"${step}" | tail -n ${b} >> crd_tmp
    awk '{if (NR==1) print $0; else print NR-1,$0}' crd_tmp > CoordData_"${step}"
    rm crd_tmp

    t2x coord_${step} | head -n -${sum} > qm_without_link.xyz
    t2x coord_${step} | tail -n ${sum} > qm_link.xyz

    awk '{ print $0, NR }' qm_link.xyz > qm_link_nr.xyz
    tail -n+3 qm_without_link.xyz | awk '{ print $0, NR }' > qm_without_link_nr.xyz

    # create calcdist.awk
    cat > calcdist.awk << 'EOF'
{
  if (NR == FNR) {
    x[FNR]=$2":"$3":"$4":"$5
    n=FNR
  } else {
    y[FNR]=$2":"$3":"$4":"$5
    m=FNR
  }
}
END {
  print "Distance between cross-product of atom pairs"
  print "--------------------------------------------"
  for (i=1;i<=n;i++) {
    split(x[i],a,":")
    for (j=1;j<=m;j++) {
      split(y[j],b,":")
      printf("%2d %2d %.8f\n",a[4],b[4],sqrt((a[1]-b[1])^2+(a[2]-b[2])^2+(a[3]-b[3])^2))
    }
  }
}
EOF

    cat > sum.awk << 'EOF'
BEGIN{sum=0}
{if (NR==FNR) for(i=1;i<=NF;i++) res[i]=$i
 if (NR!=FNR) for(x in res) if($1==res[x]) sum+=$2}
END{printf "%2.5f", sum}
EOF

    awk -f calcdist.awk qm_link_nr.xyz qm_without_link_nr.xyz | sort -n -k3 | head -n 6 | awk '{$1+=71}1' | tail -n 4 > link_${step}.txt
    grep -A 75 "atom      charge" population_${step}.txt | sed '1d' | awk '{print $1,$2}' > ch_${step}.txt
    grep -A 20 "Unpaired electrons" population_${step}.txt | sed '1,3d' | awk '{print $1,$2}' > spin_${step}.txt

    for j in FE1 OY1 SC1 Cl1 HD1 HD2 D5M; do
        res=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')
        if [[ "${j}" == "FE1" ]]; then
            tot=$(awk -v i="${res}" '$1==i {print $2}' ch_${step}.txt)
            spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_${step}.txt)
            echo "${step}" > Charge_${step}.txt
            echo "${j} ${tot}" >> Charge_${step}.txt
            echo " ${step}" > Spin_Density_${step}.txt
            echo "${j} ${spin}" >> Spin_Density_${step}.txt
        elif [[ "${j}" == "OY1" ]] ; then
            tot=$(awk -v i="${res}" '$1==i {print $2}' ch_${step}.txt)
            spin=$(awk -v i="${res}" '$1==i {printf "%2.5f", $2}' spin_${step}.txt)
            #echo "${step}" > Charge_${step}.txt
            echo "${j} ${tot}" >> Charge_${step}.txt
            #echo " ${step}" > Spin_Density_${step}.txt
            echo "${j} ${spin}" >> Spin_Density_${step}.txt

        else
            x=$(sed '1d' QM.pdb | awk -v i="${j}" '$4==i {print $2 tolower($12)}')
            echo "${x}" > Residues_${step}_${j}.txt
            tot=$(awk -f sum.awk Residues_${step}_${j}.txt ch_${step}.txt)
            spin=$(awk -f sum.awk Residues_${step}_${j}.txt spin_${step}.txt)
            echo "${j} ${tot}" >> Charge_${step}.txt
            echo "${j} ${spin}" >> Spin_Density_${step}.txt
        fi
    done
done

# Combine & clean up
paste Spin_Density_* | awk '{printf("%s\t%s\t%s\t%s\n",$1,$2,$4,$6)}' > SpinDensity_.txt
paste Charge_* | awk '{printf("%s\t%s\t%s\t%s\n",$1,$2,$4,$6)}' > ChargeDistribution_.txt


