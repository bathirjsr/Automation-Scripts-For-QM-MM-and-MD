#!/bin/bash
while getopts n: flag
do
     case "${flag}" in
        n) n=${OPTARG};;
        *) echo "usage: $0 [-n number of atoms in QM] " >&2
      exit 1 ;;
     esac
done
i=1
for d in *_Opt
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
home=$(pwd)
for((i=1;i<=${#dirs[@]};i++))
do
    cd "${dirs[i]}" || exit 
    mkdir NO_SNO
    cd NO_SNO || exit
    cp ../SP/alpha .
    sed '1,3d' alpha | sed '$d' > tmp_alpha
    echo "" >> tmp_alpha
    printf '%s\n' "(4d20.14)" | cat - tmp_alpha > alpha_edit
    cp ../SP/beta .
    sed '1,3d' beta | sed '$d' > beta_edit
    echo "" >> beta_edit
    cp ../SP/hybrid.turbomole.coords .
    #######################Change sed number here to total number of atoms###############
    sed '1,4d' hybrid.turbomole.coords | sed -n "1,${n} p" | awk '{printf "%2s%16f%14f%14f\n", $1,$2*0.529177249,$3*0.529177249,$4*0.529177249}' > inpcrd
    echo "" >> inpcrd

    ####################Change Charge and Multiplicity here#################
cat > Gauss_code.txt << EOF
%nproc=12
%mem=2gb
%chk=NO
#ub3lyp/def2tzvp guess=(only,cards) gfinput gfoldprint pop=NaturalOrbitals iop(2/11=1)

MOs

0   5
EOF
    cat Gauss_code.txt inpcrd alpha_edit beta_edit > NO.com
    nohup g16 < NO.com > NO.log
    cp NO.com SNO.com
    cp NO.chk SNO.chk
    sed -i 's/NO/SNO/g;s/NaturalOrbitals/SpinNatural/g' SNO.com
    nohup g16 < SNO.com > SNO.log
    grep 'Eigenvalues' NO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > NO_Occupancy.dat
    grep 'Eigenvalues' SNO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > SNO_Occupancy.dat
cd "$home" || exit
done

