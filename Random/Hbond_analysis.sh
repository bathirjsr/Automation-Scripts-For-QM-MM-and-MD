#!/bin/bash

cat > Hbond_analysis_sub.dat <<EOF

EOF
cat > Hbond_analysis.dat <<EOF

EOF

 for i in 346;
 do
 awk -v i="${i}" '$1 ~ i {print $0}' ${1} | sort -n >> Hbond_analysis_sub.dat
 awk -v i="${i}" '$2 ~ i {print $0}' ${2} | sort -n >> Hbond_analysis_sub.dat
 done

list=$(awk '{ a[$1]++ } END { for (b in a) { print b } }' Hbond_analysis_sub.dat )
mapfile -t list_arr <<< "$list"
for i in $list
do
	row1=$( awk -v r="$i" '$1==r{print $0}' Hbond_analysis_sub.dat | awk '{ a[$2]++ } END { for (b in a) { print b } }' )
	for j in $row1
	do
		r2r="${j%@*}"
		awk -v r="$i" -v r2="$r2r" '$1 == r && $2 ~ r2 {sum += $5} END{print r,r2,sum}' Hbond_analysis_sub.dat > "${i}"_"${r2r}"_sub.dat
	done
done

cat "${list_arr[0]}"*_sub.dat > hbond_sum_sub.dat

for k in "${list_arr[@]:1}"
 do
 	cat "${k}"*_sub.dat >> hbond_sum_sub.dat
 done

# < hbond_sum_sub.dat sort -n > Hbond_Substrate_Sum.dat
# #rm hbond_sum_sub.dat


# for i in ${active};
#  do
#  	awk -v i="${i}" '$1 ~ i  {print $0}' hbond_avg_"${parmfile}"_acceptor.dat | sort -n >> Hbond_analysis.dat
#  	awk -v i="${i}" '$2 ~ i  {print $0}' hbond_avg_"${parmfile}"_donor.dat | sort -n >> Hbond_analysis.dat
#  done

# act=$(awk '{ a[$1]++ } END { for (b in a) { print b } }' Hbond_analysis.dat )
# mapfile -t act_arr <<< "$act"
# for i in $act
# 	do
# 	row2=$( awk -v r="$i" '$1==r{print $0}' Hbond_analysis.dat | awk '{ a[$2]++ } END { for (b in a) { print b } }' )
# 		for j in $row2
# 			do
# 			r2r="${j%@*}"
# 			awk -v r="$i" -v r2="$r2r" '$1 == r && $2 ~ r2 {sum += $5} END{print r,r2,sum}' Hbond_analysis.dat > "${i}"_"${r2r}".dat
# 			done
# 	done

# cat "${act_arr[0]}"_*.dat > hbond_sum.dat

# for k in "${act_arr[@]:1}"
# 	do
# 		cat "${k}"_*.dat >> hbond_sum.dat
# 	done

# < hbond_sum.dat sort -n > Hbond_Sum.dat
# #rm hbond_sum.dat
# rm ./*@*.dat
# echo "Hbond_Sum.dat and Hbond_Substrate_Sum.dat Files will be created"