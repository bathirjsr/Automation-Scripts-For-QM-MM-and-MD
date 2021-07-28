while getopts p:r:f:t: flag
do
    case "${flag}" in
        p) parm=${OPTARG};;
        r) resid=${OPTARG};;
        f) ref=${OPTARG};;
	t) traj=${OPTARG};;
esac
done

trajname=$(basename -- "$traj")
trajext="${trajname##*.}"
trajname="${trajname%.*}"

parmname=$(basename -- "$parm")
parmext="${parmname##*.}"
parmfile="${parmname%_solv*}"

residinp=$(basename -- "$resid")
residlast="${residinp##-*.}"
residfirst="${residinp%-*}"

cat > RMSD.in << EOF
parm ${parm}
trajin ${traj}
autoimage
trajout ${trajname}_auto.nc
reference ${ref}
rms reference out RMSD_${parmfile}.dat :${resid}@CA,ZN,FE,O1 time 0.02
atomicfluct reference out RMSF_${parmfile}.dat :${resid}@CA,ZN,FE,O1 byres
radgyr :${resid}@CA,ZN,FE,O1 out ROG_${parmfile}.dat
surf :${resid}@CA,ZN,FE,O1 out SURF_${parmfile}.dat
run
EOF

mpirun -np 96 cpptraj.MPI -i RMSD.in

rmsd=RMSD_${parmfile}.dat
rmsf=RMSF_${parmfile}.dat
radgyr=ROG_${parmfile}.dat
surf=SURF_${parmfile}.dat

gnuplot  << EOF

set encoding iso_8859_1
set term postscript enhanced color font "Arial,24";

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "RMSD_${parmfile}.eps";
p "${rmsd}" w l lc rgb "red" lw 0.1 ti "RMSD", \

EOF


gnuplot  << EOF

set encoding iso_8859_1
set term postscript enhanced color font "Arial,24";

set xlabel "Resdiues"
set ylabel "RMSF ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "RMSF_${parmfile}.eps";
p "${rmsf}" w l lc rgb "red" lw 0.1 ti "RMSF", \

EOF

gnuplot  << EOF

set encoding iso_8859_1
set term postscript enhanced color font "Arial,24";

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:${residlast}]

set output "ROG_${parmfile}.eps";
p "${radgyr}" u (\$1):(\$2) w l lc rgb "red" lw 0.1 ti "CM1", \
p "${radgyr}" u (\$1):(\$3) w l lc rgb "red" lw 0.1 ti "CM1", \

EOF

gnuplot  << EOF

set encoding iso_8859_1
set term postscript enhanced color font "Arial,24";

set xlabel "Time (ns)"
set ylabel "RMSD ({\305})"
set key right top Left reverse
set yrange [0:10]
set xrange [0:1000]

set output "SURF_${parmfile}.eps";
p "${surf}" w l lc rgb "red" lw 0.1 ti "SURF", \

EOF

