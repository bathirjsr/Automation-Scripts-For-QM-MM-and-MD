#!/bin/bash
# This script is used to generate Natural Orbital and Spin Natural Orbital Occupancy calculations
while getopts n: flag
do
     case "${flag}" in
 	    n) n=${OPTARG};;
 	    *) echo "usage: $0 [-n number of atoms in QM] " >&2
      exit 1 ;;
     esac
done
if [ "$1" = "RC" ]
then
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
  sed '1,4d' hybrid.turbomole.coords | sed -n "1,$n p" | awk '{printf "%2s%16f%14f%14f\n", $1,$2*0.529177249,$3*0.529177249,$4*0.529177249}' > inpcrd
  echo "" >> inpcrd

####################Change Charge and Multiplicity here#################
  cat > Gauss_code.txt << EOF
%nproc=12
%mem=2gb
%chk=RC_NO
#ub3lyp/def2tzvp guess=(only,cards) gfinput gfoldprint pop=NaturalOrbitals iop(2/11=1)

MOs

0   5
EOF
  cat Gauss_code.txt inpcrd alpha_edit beta_edit > RC_NO.com
  nohup g16 < RC_NO.com > RC_NO.log
  cp RC_NO.com RC_SNO.com
  cp RC_NO.chk RC_SNO.chk
  sed -i 's/RC_NO/RC_SNO/g;s/NaturalOrbitals/SpinNatural/g' RC_SNO.com
  nohup g16 < RC_SNO.com > RC_SNO.log
  grep 'Eigenvalues' RC_NO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > NO_Occupancy.dat
  grep 'Eigenvalues' RC_SNO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > SNO_Occupancy.dat

elif [ "$1" = "TS" ]
then
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
  sed '1,4d' hybrid.turbomole.coords | sed -n "1,$n p" | awk '{printf "%2s%16f%14f%14f\n", $1,$2*0.529177249,$3*0.529177249,$4*0.529177249}' > inpcrd
  echo "" >> inpcrd
  cat > Gauss_code.txt << EOF
%nproc=12
%mem=2gb
%chk=TS_NO
#ub3lyp/def2tzvp guess=(only,cards) gfinput gfoldprint pop=NaturalOrbitals iop(2/11=1)

MOs

0   5
EOF
  cat Gauss_code.txt inpcrd alpha_edit beta_edit > TS_NO.com
  nohup g16 < TS_NO.com > TS_NO.log
  cp TS_NO.com TS_SNO.com
  cp TS_NO.chk TS_SNO.chk
  sed -i 's/TS_NO/TS_SNO/g;s/NaturalOrbitals/SpinNatural/g' TS_SNO.com
  nohup g16 < TS_SNO.com > TS_SNO.log
  grep 'Eigenvalues' TS_NO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > NO_Occupancy.dat
  grep 'Eigenvalues' TS_SNO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > SNO_Occupancy.dat

elif [ "$1" = "PD" ]
then
  mkdir NO_SNO
  cd NO_SNO || exit
  cp ../SP/alpha .
  sed '1,3d' alpha | sed '$d' > tmp_alpha
  echo "" >> tmp_alpha
  printf '%s\n' "(4d20.14)" | cat - tmp_alpha > alpha_edit
  cp ../SP/beta .
  sed '1,3d' beta | sed '$d' > beta_edit
  echo "" >> beta_edit
  cp ../hybrid.turbomole.coords .
  sed '1,4d' hybrid.turbomole.coords | sed -n "1,$n p" | awk '{printf "%2s%16f%14f%14f\n", $1,$2*0.529177249,$3*0.529177249,$4*0.529177249}' > inpcrd
  echo "" >> inpcrd
  cat > Gauss_code.txt << EOF
%nproc=12
%mem=2gb
%chk=PD_NO
#ub3lyp/def2tzvp guess=(only,cards) gfinput gfoldprint pop=NaturalOrbitals iop(2/11=1)

MOs

0   5
EOF
  cat Gauss_code.txt inpcrd alpha_edit beta_edit > PD_NO.com
  nohup g16 < PD_NO.com > PD_NO.log
  cp PD_NO.com PD_SNO.com
  cp PD_NO.chk PD_SNO.chk
  sed -i 's/PD_NO/PD_SNO/g;s/NaturalOrbitals/SpinNatural/g' PD_SNO.com
  nohup g16 < PD_SNO.com > PD_SNO.log
  grep 'Eigenvalues' PD_NO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > NO_Occupancy.dat
  grep 'Eigenvalues' PD_SNO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > SNO_Occupancy.dat

fi