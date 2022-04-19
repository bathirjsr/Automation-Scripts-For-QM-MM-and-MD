#! /bin/bash
while getopts t:a:d:r:s: flag
do
    case "${flag}" in
    t) type=${OPTARG};;
	a) acceptor=${OPTARG};;
	d) donor=${OPTARG};;
	r) residues=${OPTARG};;
	s) substrate=${OPTARG};;	
    *) echo "usage: $0 [-a acceptor filename] [-d donor filename] [-r residues(ID or name) ] [-s substrate residue range] " >&2
       exit 1 ;;
esac
done
residinp=$(basename -- "${substrate}")
residlast="${residinp##*-}"
residfirst="${residinp%-*}"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
cat > Hbond_analysis_sub.dat <<EOF

EOF
cat > Hbond_analysis.dat <<EOF

EOF
if [ "${type}" = "0" ]; then
 for i in $(seq "${residfirst}" 1 "${residlast}");
 do
 awk -v i="${i}" '$1 ~ i {print $0}' "${acceptor}" | sort -n >> Hbond_analysis_sub.dat
 awk -v i="${i}" '$2 ~ i {print $0}' "${donor}" | sort -n >> Hbond_analysis_sub.dat
 done

list=$(awk '{ a[$1]++ } END { for (b in a) { print b } }' Hbond_analysis_sub.dat )
list_arr=(${list})
for i in $list
do
	row2=$( awk -v r="$i" '$1==r{print $0}' Hbond_analysis_sub.dat | awk '{ a[$2]++ } END { for (b in a) { print b } }' )
	for j in $row2
	do
		r2r="${j%@*}"
		awk -v r="$i" -v r2="$r2r" '$1 == r && $2 ~ r2 {sum += $5} END{print r,r2,sum}' Hbond_analysis_sub.dat > "${i}"_"${j}"_sub.dat
	done
done

cat "${list_arr[0]}"*_sub.dat > hbond_sum_sub.dat

for k in "${list_arr[@]:1}"
do
	cat "${k}"*_sub.dat >> hbond_sum_sub.dat
done

< hbond_sum_sub.dat sort -n > Hbond_Substrate_Sum.dat
rm hbond_sum_sub.dat


elif [ "${type}" = "1" ]; then
 for i in ${residues};
 do
 awk -v i="${i}" '$1 ~ i  {print $0}' "${acceptor}" | sort -n >> Hbond_analysis.dat
 awk -v i="${i}" '$2 ~ i  {print $0}' "${donor}" | sort -n >> Hbond_analysis.dat
 done

list=$(awk '{ a[$1]++ } END { for (b in a) { print b } }' Hbond_analysis_sub.dat )
list_arr=(${list})
for i in $list
do
	row2=$( awk -v r="$i" '$1==r{print $0}' Hbond_analysis.dat | awk '{ a[$2]++ } END { for (b in a) { print b } }' )
	for j in $row2
	do
		r2r="${j%@*}"
		awk -v r="$i" -v r2="$r2r" '$1 == r && $2 ~ r2 {sum += $5} END{print r,r2,sum}' Hbond_analysis.dat > "${i}"_"${j}".dat
	done
done

cat "${list_arr[0]}"_*.dat > hbond_sum.dat

for k in "${list_arr[@]:1}"
do
	cat "${k}"_*.dat >> hbond_sum.dat
done

< hbond_sum.dat sort -n > Hbond_Sum.dat
rm hbond_sum.dat
fi
