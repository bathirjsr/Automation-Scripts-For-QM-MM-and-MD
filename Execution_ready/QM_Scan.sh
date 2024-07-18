#!/bin/bash
grep 'Final converged energy:' "$@" | awk 'NR==1{init=$NF}{print NR,($(NF)-init)*627.5095}' > PES.dat
awk 'prev!=""&&prev<=prev2&&prev<=$2{print line}{prev2=prev;prev=$2;line=$0}' PES.dat | awk '{printf "%2.0f %5.12f \n", $1,$2}' > min.dat
awk 'prev!=""&&prev>=prev2&&prev>=$2{print line}{prev2=prev;prev=$2;line=$0}' PES.dat | awk '{printf "%2.0f %5.12f \n", $1,$2}' > max.dat
last=$(awk 'END{print NR}' PES.dat)
lastenergy=$(awk 'END{print $NF}' PES.dat)
highenergy=$(awk 'NR == 1 {line = $0; max = $2}; NR > 1 && $2 > max {line = $0; max = $2}; END{print max}' PES.dat)
lowenergy=$(awk 'NR == 1 {line = $0; min = $2}; NR > 1 && $2 < min {line = $0; min = $2}; END{print min}' PES.dat)

function ActivationEnergy() {
    echo ""
	echo "Local Minimas:"
	echo "Step Energy"
	cat min.dat
	echo "Choose the RC (from Minimas):"
	read -r rc
    echo ""
	echo "Local Maximas:"
	echo "Step Energy"
	cat max.dat
	echo "Choose the TS (from Maximas):"
	read -r ts
	act=$(awk -v r="${rc}" -v t="${ts}" 'NR==r {rc=$(NF)};NR==t {ts=$(NF)};END {printf "%5.12f", (ts-rc)}' PES.dat)
    echo ""
	echo "Activation Energy for Maxima=${ts}(TS) is: " "$act"
    echo ""
}

function ReactionEnergy() {
	echo ""
	echo "Local Minimas:"
	echo "Step Energy"
	cat min.dat	
	echo "Choose the RC (from Minimas):"
	read -re rc
	echo "Choose the PD (from Minimas):"
	read -re pd
	r_act=$(awk -v r="${rc}" -v p="${pd}" 'NR==r {rc=$(NF)};NR==p {pd=$(NF)};END {printf "%5.12f", (pd-rc)}' PES.dat)
    echo ""
	echo "Reaction Energy for Minima=${ts}(PD) is: " "${r_act}"
    echo ""
}

function Plot() {
	echo "Give the filename for Potential Energy Surface Plot?  Note: Will be saved as .eps file"
	read -re plot
cat > PES.gnu << EOF
set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24
set output "${plot}.eps";
set key left top
set xlabel "Reaction Coordinate"
set ylabel "Energy(Kcal/mol)"
set xrange [0:${last}+1]
set yrange [${lowenergy}-1 : ${highenergy}+1]
plot "PES.dat" u 1:2 t "Energy" w lp pt 7 ps 2 lc rgb "black",\
     "min.dat" u 1:2 w p pt 7 ps 3 lc rgb "blue" t "Min",\
     "max.dat" u 1:2 w p pt 7 ps 3 lc rgb "red" t "Max",\
     "min.dat" u 1:2:(sprintf("(%d)", \$1)) with labels point  pt 7 offset char 1.5,0 notitle,\
     "max.dat" u 1:2:(sprintf("(%d)", \$1)) with labels point  pt 7 offset char 1.5,0 notitle,
EOF
	gnuplot PES.gnu
	evince "${plot}".eps
}
function Optimization_Status() {
grep 'QM/MM Energy: ' "$@" | awk '{print $(NF-1)}' > tmp.dat
gnuplot << EOF
set encoding iso_8859_1
set terminal postscript eps enhanced color size 3in,3in 
set output "tmp.eps";
plot 'tmp.dat' with linespoints pt 7 lc "black"
EOF
evince tmp.eps

}

function Exit() {
	echo "Do you want to keep Max and Min data files? y/n"
	read -r tmp
if [ "$tmp" = "n" ]; then
	rm PES.dat min.dat max.dat tmp.dat tmp.eps 
	exit 0
else
	exit 0
fi
}
##
# Color  Variables
##
green='\e[32m'
blue='\e[34m'
red='\e[41m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -ne "$green""$1""$clear"
}
ColorBlue(){
	echo -ne "$blue""$1""$clear"
}

menu(){
echo -ne "
Scan Menu
$(ColorGreen '1)') Activation Energy 
$(ColorGreen '2)') Reaction Energy
$(ColorGreen '3)') Plot
$(ColorGreen '4)') Optimization Status
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read -r a
        case $a in
	       # 1) Minimas ; menu ;;
	       # 2) Maximas ; menu ;;
	        1) ActivationEnergy ; menu ;;
	        2) ReactionEnergy ; menu ;;
	        3) Plot ; menu ;;
			4) Optimization_Status ; menu ;;
			0) Exit ;;
		*) echo -e "$red""Wrong option.""$clear";;
        esac
}
echo -ne "$(ColorGreen 'Last Energy:')" "$lastenergy"
# Call the menu function
menu
