#! /bin/bash
# nohup ./MDCommand.sh -g <GPU ID> -p <parameter file> -c <input coordinate> -n <Number of CPU processors> -x <Number of GPU processors> -r <Residues restraining> > MDCommand.log &
while getopts g:p:c:n:x:r:s:m: flag
do
    case "${flag}" in
        g) CUDA=${OPTARG};;
        p) prmtop=${OPTARG};;
        c) coords=${OPTARG};;
        n) nprocs=${OPTARG};;
        x) ngpu=${OPTARG};;
	    r) residues=${OPTARG};;
	    s) step=${OPTARG};;
	    m) resmask=${OPTARG};;
        *) echo "usage: $0 [-g] [-p] [-c] [-n] [-x] [-r] [-s] [-m]" >&2
       exit 1 ;;
esac
done
job=$(pwd)
if [ "${step}" = "restrained" ]; then
if [ ! -e Restrained ]; then
	    mkdir Restrained
	elif [ ! -d Restrained ]; then
	    echo "Restrained already exists but is not a directory" 1>&2
	fi
cd Restrained || exit
cp ../"${prmtop}" .
cp ../"${coords}" .
cat > 1-min.in << ENDOFFILE
initial minimisation solvent
 &cntrl
	imin   = 1,
	maxcyc = 10000,
	ncyc   = 5000,
	ntb    = 1,
	ntr    = 1,
	cut    = 10,
        restraintmask = ':$residues',!residue numbers
        restraint_wt = 500
 /
ENDOFFILE
cat > 2-min.in << ENDOFFILE
initial minimisation solvent
 &cntrl
	imin   = 1,
	maxcyc = 10000,
	ncyc   = 5000,
	ntb    = 1,
	ntr    = 0,
	cut    = 10
	restraintmask = '${resmask}',
     	restraint_wt = 500,
 /
ENDOFFILE
cat > 3-heat.in << ENDOFFILE
Relaxation 1
 &cntrl
     imin=0, ntx=1, ! Run MD [imin=0]
     ntb=1,cut=10.0, ! NVT, 8 A cutoff
     ntp=0, ! No barostat
     ntc=2, ntf=2 ! Shake on
     ntt=3, gamma_ln=1.0, ! Langevin Thermostat, 1.0ps-1
     tempi=0.0, ! Initial Temperature of 0K
     temp0=300.0,
     nstlim=100000, dt=0.001,! 50K steps x 1fs = 100ps
     iwrap=1, ! Wrap coordinates to central box
     ioutfm=1, ! Write binary mdcrd
     ntpr=5000, ntwx=5000, ! Write to mdout and mdcrd every 5,000 steps
     ntwr=50000, ! Write restart file every 50,000 steps
     ntr=1, restraint_wt=50.0, ! Restrain backbone atoms with 4.0 KCal/Mol/A
     restraintmask=':$residues',
     ig=-1, ! Use 'random' random number seed.
     nmropt=1, ! Used to ramp temperature slowly
 /

&wt type='TEMP0', istep1=0, istep2=50000,value1=0.0, value2=300.0, /
&wt type='TEMP0', istep1=50000, istep2=100000,value1=300.0, value2=300.0, /
&wt type='END'  / 
ENDOFFILE
cat > 4-density.in << ENDOFFILE
Relaxation 2
&cntrl
   imin=0, ntx=5, irest=1, ! Read box and velocity info from inpcrd
   ntb=2,cut=10.0, ! NPT
   ntp=1, pres0=1.0, ! Anisotropic pressure scaling at 1 atm
   ntc=2,
   ntf=2,
   ntt=3, temp0=300.0, gamma_ln=1.0,
   nstlim=500000, dt=0.002,
   iwrap=1, ioutfm=1,
   ntpr=5000, ntwr=50000, ntwx=5000,
   ntr=1, restraint_wt=5.0, restraintmask=':$residues', ! Keep weak restraints on backbone
   ig=-1,
   nmropt=1,
/
&wt type='TEMP0', istep1=0, istep2=500000,value1=300.0, value2=300.0 /
&wt type='END'  /
ENDOFFILE
cat > 5-Res_run.in << ENDOFFILE
Production simulation
 &cntrl
  imin = 0, irest = 1, ntx = 7,
  ntb = 2, pres0 = 1.0, ntp = 1,
  taup = 2.0,
  cut = 10, ntr = 0,
  ntc = 2, ntf = 2,
  temp0 = 300.0,
  ntt = 3, gamma_ln = 2.0,
  nstlim = 100000000, dt = 0.002,ioutfm=1,
  ntpr = 10000, ntwx = 10000, ntwr = 10000, ntxo = 2
  restraintmask = '${resmask}',
  restraint_wt = 500,
/
ENDOFFILE
cat > 6-equil.in << ENDOFFILE
protein: equilibration
 &cntrl
	imin   = 0,
	irest  = 1,
	ntx    = 5,
	ntb    = 2,
	cut    = 10,
	ntp    = 1,
	ntc    = 2,
	ntf    = 2,
	taup    = 2.0,
	temp0  = 300.0,
	ntt    = 3,
	gamma_ln = 2.0,
	nstlim = 1500000, dt = 0.002,ioutfm=1,
	ntpr = 5000, ntwx = 5000, ntxo = 2
 /
ENDOFFILE
cat > 7-md.in << ENDOFFILE
Production simulation
 &cntrl
  imin = 0, irest = 1, ntx = 7,
  ntb = 2, pres0 = 1.0, ntp = 1,
  taup = 2.0,
  cut = 10, ntr = 0,
  ntc = 2, ntf = 2,
  temp0 = 300.0,
  ntt = 3, gamma_ln = 2.0,
  nstlim = 400000000, dt = 0.002,ioutfm=1,
  ntpr = 10000, ntwx = 10000, ntwr = 10000, ntxo = 2
 /
ENDOFFILE
echo "Using GPU ID:${CUDA}"
echo "Using Parameter file:${prmtop}"
echo "Using Coords:${coords}"
echo "Restraining Residues:${residues}"
echo "Started MD on $(date) "
do_parallel="nohup mpirun -n ${nprocs} $AMBERHOME/bin/sander.MPI"
do_gpu="nohup mpirun -n ${ngpu} $AMBERHOME/bin/pmemd.cuda.MPI"

MDINPUTS=( 1-min 2-min 3-heat 4-density 5-Res_run 6-equil 7-md )

for input in "${MDINPUTS[@]}"; 
do
if [ "${input}" = "1-min" ]
then 

	if [[ ! -e "${input}" ]]; then
	    mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
	    echo "${input} already exists but is not a directory" 1>&2
	fi

	cp "${input}".in "${input}"/.
	$do_parallel -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${coords}" -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${coords}" -inf "${input}"/"${input}".mdinfo -O&
	echo "First minimization started on $(date)" | mail -s "${input} MD started in $(hostname) at ${job}" simahjsr@gmail.com
	coords="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;	

elif [ "${input}" = "2-min" ] 
then

	if [ "$(grep -c "Total time" 1-min/1-min.out)" -ge 1 ]; then
		echo "First minimization completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job} " simahjsr@gmail.com
	else
		echo "First minimization terminated in $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi

	if [[ ! -e "${input}" ]]; then
	    mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
	    echo "${input} already exists but is not a directory" 1>&2
	fi

	cp "${input}".in "${input}"/.
	$do_parallel -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${coords}"/"${coords}".rst -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${coords}"/"${coords}".rst -inf "${input}"/"${input}".mdinfo -O&
	echo "Second minimization started on $(date) "
	coords="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;
	

	if [ "$(grep -c "Total time" 2-min/2-min.out)" -ge 1 ]; then
		min="${coords}"
		echo "Second minimization completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job} " simahjsr@gmail.com
	else
		echo "Second minimization terminated on $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi


else

	if [[ ! -e "${input}" ]]; then
		mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
		echo "${input} already exists but is not a directory" 1>&2
	fi   

	cp "${input}".in "${input}"/.
	export CUDA_VISIBLE_DEVICES="${CUDA}"
	$do_gpu -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${min}"/"${min}".rst -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${min}"/"${min}".rst -inf "${input}"/"${input}".mdinfo -O&
	echo "${input} calculation started on $(date)"
	min="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;
	

	if [ "$(grep -c "Master Total wall time:" "${input}"/"${input}".out)" -ge 1 ]; then
		echo "${input} calculation completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job} " simahjsr@gmail.com	
		echo "Calculation proceed"
	else
		echo "${input} calculation terminated on $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi

fi
done
echo "Finished MD on $(date) "

else
cat > 1-min.in << ENDOFFILE
initial minimisation solvent
 &cntrl
	imin   = 1,
	maxcyc = 10000,
	ncyc   = 5000,
	ntb    = 1,
	ntr    = 1,
	cut    = 10,
        restraintmask = ':$residues',!residue numbers
        restraint_wt = 500
 /
ENDOFFILE
cat > 2-min.in << ENDOFFILE
initial minimisation solvent
 &cntrl
	imin   = 1,
	maxcyc = 10000,
	ncyc   = 5000,
	ntb    = 1,
	ntr    = 0,
	cut    = 10
 /
ENDOFFILE
cat > 3-heat.in << ENDOFFILE
Relaxation 1
 &cntrl
     imin=0, ntx=1, ! Run MD [imin=0]
     ntb=1,cut=10.0, ! NVT, 8 A cutoff
     ntp=0, ! No barostat
     ntc=2, ntf=2 ! Shake on
     ntt=3, gamma_ln=1.0, ! Langevin Thermostat, 1.0ps-1
     tempi=0.0, ! Initial Temperature of 0K
     temp0=300.0,
     nstlim=100000, dt=0.001,! 50K steps x 1fs = 100ps
     iwrap=1, ! Wrap coordinates to central box
     ioutfm=1, ! Write binary mdcrd
     ntpr=5000, ntwx=5000, ! Write to mdout and mdcrd every 5,000 steps
     ntwr=50000, ! Write restart file every 50,000 steps
     ntr=1, restraint_wt=50.0, ! Restrain backbone atoms with 4.0 KCal/Mol/A
     restraintmask=':$residues',
     ig=-1, ! Use 'random' random number seed.
     nmropt=1, ! Used to ramp temperature slowly
 /

&wt type='TEMP0', istep1=0, istep2=50000,value1=0.0, value2=300.0, /
&wt type='TEMP0', istep1=50000, istep2=100000,value1=300.0, value2=300.0, /
&wt type='END'  / 
ENDOFFILE
cat > 4-density.in << ENDOFFILE
Relaxation 2
&cntrl
   imin=0, ntx=5, irest=1, ! Read box and velocity info from inpcrd
   ntb=2,cut=10.0, ! NPT
   ntp=1, pres0=1.0, ! Anisotropic pressure scaling at 1 atm
   ntc=2,
   ntf=2,
   ntt=3, temp0=300.0, gamma_ln=1.0,
   nstlim=500000, dt=0.002,
   iwrap=1, ioutfm=1,
   ntpr=5000, ntwr=50000, ntwx=5000,
   ntr=1, restraint_wt=5.0, restraintmask=':$residues', ! Keep weak restraints on backbone
   ig=-1,
   nmropt=1,
/
&wt type='TEMP0', istep1=0, istep2=500000,value1=300.0, value2=300.0 /
&wt type='END'  /
ENDOFFILE
cat > 5-equil.in << ENDOFFILE
protein: equilibration
 &cntrl
	imin   = 0,
	irest  = 1,
	ntx    = 5,
	ntb    = 2,
	cut    = 10,
	ntp    = 1,
	ntc    = 2,
	ntf    = 2,
	taup    = 2.0,
	temp0  = 300.0,
	ntt    = 3,
	gamma_ln = 2.0,
	nstlim = 1500000, dt = 0.002,ioutfm=1,
	ntpr = 5000, ntwx = 5000, ntxo = 2
 /
ENDOFFILE
cat > 6-md.in << ENDOFFILE
Production simulation
 &cntrl
  imin = 0, irest = 1, ntx = 7,
  ntb = 2, pres0 = 1.0, ntp = 1,
  taup = 2.0,
  cut = 10, ntr = 0,
  ntc = 2, ntf = 2,
  temp0 = 300.0,
  ntt = 3, gamma_ln = 2.0,
  nstlim = 500000000, dt = 0.002,ioutfm=1,
  ntpr = 10000, ntwx = 10000, ntwr = 10000, ntxo = 2
 /
ENDOFFILE
echo "Using GPU ID:${CUDA}"
echo "Using Parameter file:${prmtop}"
echo "Using Coords:${coords}"
echo "Restraining Residues:${residues}"
echo "Started MD on $(date) "
do_parallel="nohup mpirun -n ${nprocs} $AMBERHOME/bin/sander.MPI"
do_gpu="nohup mpirun -n ${ngpu} $AMBERHOME/bin/pmemd.cuda.MPI"
MDINPUTS=(1-min 2-min 3-heat 4-density 5-equil 6-md)

for input in "${MDINPUTS[@]}"; 
do
if [ "$input" = "1-min" ]
then 

	if [[ ! -e "${input}" ]]; then
	    mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
	    echo "${input} already exists but is not a directory" 1>&2
	fi

	cp "${input}".in "${input}"/.
	$do_parallel -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${coords}" -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${coords}" -inf "${input}"/"${input}".mdinfo -O&
	echo "First minimization started on $(date)" | mail -s "${input} MD started in $(hostname) at ${job}" simahjsr@gmail.com
	coords="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;	
if [ "$(grep -c "Total time" 1-min/1-min.out)" -ge 1 ]; then
		echo "First minimization completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job} " simahjsr@gmail.com
	else
		echo "First minimization terminated in $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi
elif [ "${input}" = "2-min" ] 
then

	if [ "$(grep -c "Total time" 1-min/1-min.out)" -ge 1 ]; then
		coords=1-min
		echo "First minimization completed on $(date)"
	else
		echo "First minimization terminated in $(date)"
		exit
	fi

	if [[ ! -e "${input}" ]]; then
	    mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
	    echo "${input} already exists but is not a directory" 1>&2
	fi

	cp "${input}".in "${input}"/.
	$do_parallel -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${coords}"/"${coords}".rst -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${coords}"/"${coords}".rst -inf "${input}"/"${input}".mdinfo -O&
	echo "Second minimization started on $(date)" | mail -s "${input} MD started in $(hostname) at ${job}" simahjsr@gmail.com
	coords="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;
	

	if [ "$(grep -c "Total time" 2-min/2-min.out)" -ge 1 ]; then
		min="${coords}"
		echo "Second minimization completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job} " simahjsr@gmail.com
	else
		echo "Second minimization terminated on $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi

else

	if [[ ! -e "${input}" ]]; then
		mkdir "${input}"
	elif [[ ! -d "${input}" ]]; then
		echo "${input} already exists but is not a directory" 1>&2
	fi   

	cp "${input}".in "${input}"/.
	export CUDA_VISIBLE_DEVICES="${CUDA}"
	$do_gpu -i "${input}"/"${input}".in -o "${input}"/"${input}".out -p "${prmtop}" -c "${min}"/"${min}".rst -r "${input}"/"${input}".rst -x "${input}"/"${input}".nc -ref "${min}"/"${min}".rst -inf "${input}"/"${input}".mdinfo -O&
	echo "${input} calculation started on $(date)" | mail -s "${input} MD started $(hostname)" simahjsr@gmail.com
	min="${input}"
	process=$!
	while ps -p $process > /dev/null;do sleep 1;done;
	

	if [ "$(grep -c "Master Total wall time:" "${input}"/"${input}".out)" -ge 1 ]; then
		echo "${input} calculation completed on $(date)" | mail -s "${input} MD completed in $(hostname) at ${job}  at ${job} " simahjsr@gmail.com	
		echo "Calculation proceed"
	else
		echo "${input} calculation terminated on $(date)" | mail -s "${input} MD terminated in $(hostname) at ${job} " simahjsr@gmail.com
		exit
	fi

fi
done
echo "Finished MD on $(date) "
fi