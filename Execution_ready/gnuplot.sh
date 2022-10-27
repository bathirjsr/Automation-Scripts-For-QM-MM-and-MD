#!/bin/bash
inp=${1}
function RMSD() {
    gnuplot <<EOF
    
set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "tmp.eps";
p "${inp}" w l lc rgb "blue" lw 1.0 notitle, \

reset

EOF
evince tmp.eps
echo "Do you want to save? y/n"
read -re save
if [ "$save" = "n" ]; then
	rm tmp.eps
	exit 0
else
    echo "Filename? "
    read -re title
    mv tmp.eps "${title}".eps
	exit 0
fi

}

function Distance() { 
   
    gnuplot <<EOF

    set encoding iso_8859_1
    set term post enhanced eps solid color lw 2.0 "Arial" 24

    set ylabel "$ylabel ({\305})"
    set xlabel "Time (ns)"
    set key right bottom Left reverse
    set yrange [0:10]
    set xrange [0:1000]

    set output "tmp.eps";
    p "${inp}" w l lc rgb "blue" lw 1.0 notitle, \

EOF
evince tmp.eps
echo "Do you want to save? y/n"
read -re save
if [ "$save" = "n" ]; then
	rm tmp.eps
	exit 0
else
    echo "Filename? "
    read -re title
    mv tmp.eps "${title}".eps
	exit 0
fi
}
function Angle() { 
    echo "y label?"
    read -re ylabel
gnuplot <<EOF

    set encoding iso_8859_1
    set term post enhanced eps solid color lw 2.0 "Arial" 24

    set ylabel "${ylabel}"
    set xlabel "Time ({\260})"
    set key right bottom Left reverse
    set yrange [120:180]
    set xrange [0:1000]

    set output "tmp.eps";
    p "${inp}" w l lc rgb "blue" lw 1.0 notitle, \

EOF
evince tmp.eps
echo "Do you want to save? y/n"
read -re save
if [ "$save" = "n" ]; then
	rm tmp.eps
	exit 0
else
    echo "Filename? "
    read -re title
    mv tmp.eps "${title}".eps
	exit 0
fi
}

function Exit() {
	echo "Do you want to keep Max and Min data files? y/n"
	read -re tmp
if [ "$tmp" = "n" ]; then
	rm tmp.eps
	exit 0
else
    mv
	exit 0
fi
}

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
$(ColorGreen '1)') RMSD
$(ColorGreen '2)') Distance
$(ColorGreen '3)') Angle
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read -r a
        case $a in
	        1) RMSD ; menu ;;
	        2) Distance ; menu ;;
	        3) Angle ; menu ;;
		    0) Exit ;;
		*) echo -e "$red""Wrong option.""$clear";;
        esac
}
# Call the menu function
menu
