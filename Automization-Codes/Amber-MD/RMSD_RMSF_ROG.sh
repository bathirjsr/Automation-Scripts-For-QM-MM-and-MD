#!/bin/bash
while getopts p:r:f:t:s: flag
do
    case "${flag}" in
        p) parm=${OPTARG};;
        r) resid=${OPTARG};;
        f) ref=${OPTARG};;
	    t) traj=${OPTARG};;
	    s) step=${OPTARG};;
        *) echo "usage: $0 [-p] [-r] [-f] [-t] [-s] " >&2
       exit 1 ;;
esac
done

trajname=$(basename -- "$traj")
trajext="${trajname##*.}"
trajfile="${trajname%.*}"

parmname=$(basename -- "$parm")
parmext="${parmname##*.}"
parmfile="${parmname%_solv*}"

residinp=$(basename -- "$resid")
residlast="${residinp##*-}"
residfirst="${residinp%-*}"

function run {
cat > RMSD.in << EOF
parm ${parm}
trajin ${traj}
autoimage
trajout ${trajfile}_auto.nc
reference ${ref}
rms reference out RMSD_${parmfile}.dat :${resid}@CA,ZN,FE,O1 time 0.02
atomicfluct reference out RMSF_${parmfile}.dat :${resid}@CA,ZN,FE,O1 byres
radgyr :${resid}@CA,ZN,FE,O1 out ROG_${parmfile}.dat time 0.02
surf :${resid}@CA,ZN,FE,O1 out SURF_${parmfile}.dat time 0.02
run
EOF

cpptraj.cuda -i RMSD.in
}

function plot {
rmsd=RMSD_${parmfile}.dat
rmsf=RMSF_${parmfile}.dat
radgyr=ROG_${parmfile}.dat
surf=SURF_${parmfile}.dat

gnuplot  << EOF

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "RMSD_${parmfile}.eps";
p "${rmsd}" w l lc rgb "red" lw 1.0 notitle, \

EOF


gnuplot  << EOF

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Resdiues"
set ylabel "RMSF ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:${residlast}]

set output "RMSF_${parmfile}.eps";
p "${rmsf}" w l lc rgb "red" lw 1.0 notitle, \

EOF

gnuplot  << EOF

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "ROG ({\305}^2)"
set key right top Left reverse
#set yrange [0:10]
#set xrange [0:${residlast}]

set output "ROG_${parmfile}.eps";
p "${radgyr}" u (\$1):(\$2) w l lc rgb "red" lw 1.0 notitle, \

EOF

gnuplot  << EOF

set encoding iso_8859_1
set term post enhanced eps solid color lw 2.0 "Arial" 24

set xlabel "Time (ns)"
set ylabel "SAS ({\305})^2"
set key right bottom Left reverse
#set yrange [0:10]
#set xrange [0:1000]

set output "SURF_${parmfile}.eps";
p "${surf}" w l lc rgb "red" lw 1.0 notitle, \

EOF
}
if [ "${step}" = "run" ];
then
run
elif [ "${step}" = "plot" ];
then
plot
else 
plot 
run
fi