#! /bin/bash

source "${1}"

cat > QM_MM_MD.tcl <<ENDOFFILE
mol load pdb ${pdb}
set QM [atomselect top "(resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)"]
set QM_Fe [atomselect top "((resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)) and element Fe "]
set QM_C [atomselect top "((resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)) and element C "]
set QM_N [atomselect top "((resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)) and element N "]
set QM_O [atomselect top "((resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)) and element O"]
set QM_H [atomselect top "((resname ${His1} ${His2} ${Carb} ${Co_sub} ${Metal} ${Oxygen} and not backbone and not type HA H) or (resname ${Sub} and not backbone and not type HA H CB CD CG HB2 HB3 HD2 HD3 HG2 HG3)) and element H"]

set link_His1 [atomselect top "resname ${His1} and type CA CB"]
set link_His2 [atomselect top "resname ${His2} and type CA CB"]
set link_Carb [atomselect top "resname ${Carb} and type CA CB"]
set link_Sub [atomselect top "resname ${Sub} and type CD CE"]

\$QM num
\$QM_C num
\$QM_N num
\$QM_O num
\$QM_H num
\$QM_Fe num
\$QM writepdb QM.pdb
\$QM writexyz QM.xyz

set QM_file [open qm.txt w]
puts \$QM_file [\${QM} list]
close \$QM_file

set QM_C_file [open qm_C.txt w]
puts \${QM_C_file} [\${QM_C} list]
close \${QM_C_file}

set QM_N_file [open qm_N.txt w]
puts \$QM_N_file [\${QM_N} list]
close \$QM_N_file

set QM_O_file [open qm_O.txt w]
puts \$QM_O_file [\${QM_O} list]
close \$QM_O_file

set QM_H_file [open qm_H.txt w]
puts \$QM_H_file [\${QM_H} list]
close \$QM_H_file

set QM_Fe_file [open qm_Fe.txt w]
puts \$QM_Fe_file [\${QM_Fe} list]
close \$QM_Fe_file

set link_His1_file [open link_His1.txt w]
puts \$link_His1_file [\${link_His1} list]
close \$link_His1_file

set link_His2_file [open link_His2.txt w]
puts \$link_His2_file [\${link_His2} list]
close \$link_His2_file

set link_Carb_file [open link_Carb.txt w]
puts \$link_Carb_file [\${link_Carb} list]
close \$link_Carb_file

set link_Sub_file [open link_Sub.txt w]
puts \$link_Sub_file [\${link_Sub} list]
close \$link_Sub_file

exit
ENDOFFILE

vmd -dispdev text -e QM_MM_MD.tcl

cat > addone-awk <<ENDOFFILE

BEGIN{
   RS = " "
}

{
a = \$1
++a
printf( "%d " , a )
}

ENDOFFILE

awk -f addone-awk qm.txt > QM.dat
awk -f addone-awk qm_C.txt > QM_C.dat
awk -f addone-awk qm_N.txt > QM_N.dat
awk -f addone-awk qm_O.txt > QM_O.dat
awk -f addone-awk qm_H.txt > QM_H.dat
awk -f addone-awk qm_Fe.txt > QM_Fe.dat
awk -f addone-awk link_His1.txt > Link_His1.dat
awk -f addone-awk link_His2.txt > Link_His2.dat
awk -f addone-awk link_Carb.txt > Link_Carb.dat
awk -f addone-awk link_Sub.txt > Link_Sub.dat 

QM_C=$(< QM_C.dat awk 'NR==1{print $0}')
QM_N=$(< QM_N.dat awk 'NR==1{print $0}')
QM_O=$(< QM_O.dat awk 'NR==1{print $0}')
QM_H=$(< QM_H.dat awk 'NR==1{print $0}')
QM_Fe=$(< QM_Fe.dat awk 'NR==1{print $0}')
link_His1_1=$(< Link_His1.dat awk 'NR==1{print $1}')
link_His1_2=$(< Link_His1.dat awk 'NR==1{print $2}')
link_His2_1=$(< Link_His2.dat awk 'NR==1{print $1}')
link_His2_2=$(< Link_His2.dat awk 'NR==1{print $2}')
link_Carb_1=$(< Link_Carb.dat awk 'NR==1{print $1}')
link_Carb_2=$(< Link_Carb.dat awk 'NR==1{print $2}')
link_Sub_1=$(< Link_Sub.dat awk 'NR==1{print $1}')
link_Sub_2=$(< Link_Sub.dat awk 'NR==1{print $2}')

x_dec=$(< "${pdb}" awk 'NR==1{print $2}')
y_dec=$(< "${pdb}" awk 'NR==1{print $3}')
z_dec=$(< "${pdb}" awk 'NR==1{print $4}')

x_abs=$(< "${pdb}" awk 'NR==1{printf "%.0f\n", $2}')
y_abs=$(< "${pdb}" awk 'NR==1{printf "%.0f\n", $3}')
z_abs=$(< "${pdb}" awk 'NR==1{printf "%.0f\n", $4}')

if [ "${Run_Type}" = "SP" ]; then

cat > QMMM_MD_SP_ "${System}".inp <<EOF

&GLOBAL
  PROJECT_NAME  ${System}_RC_SP
  RUN_TYPE ENERGY_FORCE
  PRINT_LEVEL HIGH
&END GLOBAL

&FORCE_EVAL
  METHOD QMMM

  &MM
    &FORCEFIELD
      VDW_SCALE14 0.5
      EI_SCALE14 0.8333333
      PARM_FILE_NAME ${prmtop}
      PARMTYPE AMBER
      SHIFT_CUTOFF .FALSE.
	&SPLINE	
		EMAX_SPLINE 6
	&END SPLINE
    &END FORCEFIELD
    &POISSON
      POISSON_SOLVER PERIODIC
      PERIODIC XYZ
      &EWALD
        EWALD_TYPE SPME
        ALPHA 0.35
        GMAX ${x_abs} ${y_abs} ${z_abs}
        O_SPLINE 6
      &END EWALD
    &END POISSON
  &END MM

  &DFT
    BASIS_SET_FILE_NAME BASIS_MOLOPT
    BASIS_SET_FILE_NAME BASIS_ADMM
    BASIS_SET_FILE_NAME BASIS_ADMM_MOLOPT
    POTENTIAL_FILE_NAME GTH_POTENTIALS
    UKS
    CHARGE 0
    MULTIPLICITY 5
    &SCF
      MAX_SCF 30
      EPS_SCF 2.0E-5
      SCF_GUESS RESTART 
      &OT
        MINIMIZER CG
        PRECONDITIONER FULL_ALL
      &END OT
      &OUTER_SCF
        MAX_SCF 20
        EPS_SCF 2.0E-5
      &END OUTER_SCF
      &PRINT
	&MOS_MOLDEN ON
	  FILENAME MOS
        &END MOS_MOLDEN
      &END PRINT
    &END SCF
    &MGRID
      CUTOFF 360
      COMMENSURATE
      NGRIDS 5
    &END MGRID
    &QS
      METHOD GPW
      EPS_PGF_ORB 1.0E-32
    &END QS
       &AUXILIARY_DENSITY_MATRIX_METHOD
      METHOD BASIS_PROJECTION
      ADMM_PURIFICATION_METHOD MO_DIAG
    &END
    &XC
      &XC_FUNCTIONAL
       &LYP
         SCALE_C 0.81
       &END
       &BECKE88
         SCALE_X 0.72
       &END
       &VWN
         FUNCTIONAL_TYPE VWN5
         SCALE_C 0.19
       &END
       &XALPHA
         SCALE_X 0.08
       &END
      &END XC_FUNCTIONAL
      &HF
        &MEMORY
          MAX_MEMORY  10000
         EPS_STORAGE_SCALING 1.0E-1
        &END
        &SCREENING
          EPS_SCHWARZ 1.0E-7
          EPS_SCHWARZ_FORCES 1.0E-6
        &END
        &INTERACTION_POTENTIAL
          POTENTIAL_TYPE TRUNCATED
          CUTOFF_RADIUS 6.0
      T_C_G_DATA  t_c_g.dat
        &END
        FRACTION 0.20
      &END
    &END XC
    &POISSON
      PERIODIC NONE
      POISSON_SOLVER MT
    &END POISSON
    &PRINT
      &E_DENSITY_CUBE MEDIUM
      &END E_DENSITY_CUBE
      &MO_CUBES
	NLUMO -1
	NHOMO -1
	WRITE_CUBE .TRUE.
      &END MO_CUBES
      &MULLIKEN MEDIUM
	PRINT_ALL .TRUE.
	PRINT_GOP .TRUE.
      &END MULLIKEN
      &MO
	FILENAME MO
	OCCUPATION_NUMBERS .TRUE.
      &END MO
    &END PRINT
  &END DFT

  &QMMM
    E_COUPL GAUSS
    USE_GEEP_LIB 10
    &CELL
      ABC [angstrom] 20 20 20 
      PERIODIC NONE
    &END CELL
    &INTERPOLATOR
      EPS_R 1.0e-14
      EPS_X 1.0e-14
      MAXITER 100
    &END INTERPOLATOR
    &QM_KIND FE
      MM_INDEX ${QM_Fe}
    &END QM_KIND
    &QM_KIND O 
      MM_INDEX ${QM_O}
    &END QM_KIND
    &QM_KIND N
      MM_INDEX ${QM_N}
    &END QM_KIND
    &QM_KIND C
      MM_INDEX ${QM_C}
    &END QM_KIND
    &QM_KIND H
       MM_INDEX ${QM_H}
    &END QM_KIND

    &LINK
      LINK_TYPE IMOMM
      QM_INDEX ${link_His1_2}
      MM_INDEX ${link_His1_1}
    &END LINK
    &LINK
      LINK_TYPE IMOMM
      QM_INDEX ${link_His2_2}
      MM_INDEX ${link_His2_1}
    &END LINK
    &LINK
      LINK_TYPE IMOMM
      QM_INDEX ${link_Carb_2}
      MM_INDEX ${link_Carb_1}
    &END LINK
    &LINK
      LINK_TYPE IMOMM
      QM_INDEX ${link_Sub_2}
      MM_INDEX ${link_Sub_1}
    &END LINK

  &END QMMM

  &SUBSYS
    &CELL
      ABC [angstrom]   ${x_dec} ${y_dec} ${z_dec}
      PERIODIC XYZ
    &END CELL
    &TOPOLOGY
      COORD_FILE_NAME ${pdb}
      COORD_FILE_FORMAT PDB
      CONN_FILE_NAME ${prmtop}
      CONN_FILE_FORMAT AMBER
     &END TOPOLOGY
      &KIND FE
      BASIS_SET DZVP-MOLOPT-SR-GTH
      BASIS_SET AUX_FIT FIT13
      POTENTIAL GTH-BLYP-q16
    &END KIND
    &KIND O
      BASIS_SET DZVP-MOLOPT-SR-GTH
      BASIS_SET AUX_FIT cpFIT3
      POTENTIAL GTH-BLYP-q6
    &END KIND
    &KIND N
      BASIS_SET DZVP-MOLOPT-SR-GTH
      BASIS_SET AUX_FIT cpFIT3
      POTENTIAL GTH-BLYP-q5
    &END KIND
    &KIND C
      BASIS_SET DZVP-MOLOPT-SR-GTH
      BASIS_SET AUX_FIT cpFIT3
      POTENTIAL GTH-BLYP-q4
    &END KIND
    &KIND H
      BASIS_SET DZVP-MOLOPT-SR-GTH
      BASIS_SET AUX_FIT cpFIT3
      POTENTIAL GTH-BLYP-q1
    &END KIND

  &END SUBSYS

&END FORCE_EVAL


EOF

nohup mpirun -n "${nproc}" cp2k.popt -o QMMM_MD_SP_ "${System}".out QMMM_MD_SP_ "${System}".inp &
elif [ "${Run_type}" = "MD" ]; then

cat > QMMM-MD_ "${System}".inp <<EOF
&GLOBAL
        PROJECT ${System}_MD
        RUN_TYPE MD
        PRINT_LEVEL LOW
&END GLOBAl


&FORCE_EVAL
        METHOD QMMM
        &DFT
                CHARGE 0
                MULTIPLICITY 5
		UKS
                BASIS_SET_FILE_NAME BASIS_MOLOPT
                BASIS_SET_FILE_NAME BASIS_ADMM
                BASIS_SET_FILE_NAME BASIS_ADMM_MOLOPT
                POTENTIAL_FILE_NAME GTH_POTENTIALS
		WFN_RESTART_FILE_NAME ${Restart}
                
                &MGRID
                        CUTOFF 360
			COMMENSURATE
			NGRIDS 5
                &END MGRID

                &QS
                        METHOD GPW
                        EPS_DEFAULT 1.0E-10
			EPS_PGF_ORB 1.0E-16
                        EXTRAPOLATION ASPC
                        &SE
                                &COULOMB
                                        CUTOFF 10.0
                                &END
                                &EXCHANGE
                                        CUTOFF 10.0
                                &END
                        &END
                &END

                &POISSON
                        PERIODIC NONE
                        POISSON_SOLVER MT
                &END 

                &SCF
                        MAX_SCF 30
                        EPS_SCF 2.0E-5
                        SCF_GUESS RESTART

                        &PRINT
                                &RESTART OFF
                                &END
                                &RESTART_HISTORY OFF
                                &END
                       &END
                       
                       &OUTER_SCF
                               MAX_SCF 20
                               EPS_SCF 2.0E-5
                       &END
                       
                       &OT
                               PRECONDITIONER FULL_ALL
                               MINIMIZER CG
                       &END OT

                &END SCF
                
                &XC
                        &XC_FUNCTIONAL
                                &LYP
					SCALE_C 0.81
                                &END
                                &BECKE88
                                        SCALE_X 0.72
                                &END
                                &VWN
                                        FUNCTIONAL_TYPE VWN5
                                        SCALE_C 0.19
                                &END
                                &XALPHA
                                        SCALE_X 0.08
                                &END
                        &END XC_FUNCTIONAL

                        &VDW_POTENTIAL
                                &PAIR_POTENTIAL
                                        PARAMETER_FILE_NAME dftd3.dat
                                        TYPE DFTD3
                                        REFERENCE_FUNCTIONAL B3LYP
                                        R_CUTOFF 10.0
                                &END
                        &END VDW_POTENTIAL

                        &HF
                                &MEMORY
                                        MAX_MEMORY 10000
                                        EPS_STORAGE_SCALING 1.0E-1
                                &END
                                &SCREENING
                                        EPS_SCHWARZ 1.0E-7
                                        EPS_SCHWARZ_FORCES 1.0E-6
                                &END
                                &INTERACTION_POTENTIAL
                                        POTENTIAL_TYPE TRUNCATED
                                        CUTOFF_RADIUS 6.0
                                        T_C_G_DATA  t_c_g.dat
                                &END
                                FRACTION 0.20
                        &END HF
                &END XC

                &AUXILIARY_DENSITY_MATRIX_METHOD
                        METHOD BASIS_PROJECTION
                        ADMM_PURIFICATION_METHOD MO_DIAG
                &END AUXILIARY_DENSITY_MATRIX_METHOD

                &PRINT
			&MULLIKEN HIGH
				&EACH
					JUST_ENERGY 1
				&END
				FILENAME MULLIKEN
				ADD_LAST NUMERIC
				LOG_PRINT_KEY
			&END MULLIKEN
			&HIRSHFELD HIGH
				&EACH
					JUST_ENERGY 1
				&END
				FILENAME HIRSHFELD
				ADD_LAST NUMERIC
				LOG_PRINT_KEY
			&END HIRSHFELD
			&LOWDIN HIGH
				&EACH
					JUST_ENERGY 1
				&END
				FILENAME LOWDIN
				ADD_LAST NUMERIC
				LOG_PRINT_KEY
			&END LOWDIN
                &END
        &END DFT


        &MM
                &FORCEFIELD 
                        VDW_SCALE14 0.5
                        EI_SCALE14 0.8333333
                        PARM_FILE_NAME PHF8_ES_1000.prmtop
                        PARMTYPE AMBER
                        SHIFT_CUTOFF .FALSE.
                        &SPLINE
                                RCUT_NB [angstrom] 10.0
                        &END
                &END FORCEFIELD
                &POISSON
                        &EWALD
                                EWALD_TYPE SPME
                                ALPHA 0.35
                                GMAX ${x_abs} ${y_abs} ${z_abs}
                                O_SPLINE 6
                        &END EWALD
                &END POISSON
        &END MM
        &QMMM
                ECOUPL GAUSS
                USE_GEEP_LIB 10
                &CELL
                        ABC 20 20 20
                        ALPHA_BETA_GAMMA 90 90 90
                        PERIODIC NONE
                &END CELL

                &INTERPOLATOR
                        EPS_R 1.0e-14
                        EPS_X 1.0e-14
                        MAXITER 100
                &END INTERPOLATOR

                &QM_KIND H
                        MM_INDEX ${QM_H}
                &END QM_KIND
                &QM_KIND C
                        MM_INDEX ${QM_C}
                &END QM_KIND
                &QM_KIND O
                        MM_INDEX ${QM_O}
                &END QM_KIND
                &QM_KIND N
                        MM_INDEX ${QM_N}
                &END QM_KIND
                &QM_KIND FE
                        MM_INDEX ${QM_Fe}
                &END QM_KIND
                
		&LINK
			LINK_TYPE IMOMM
			QM_INDEX ${link_His1_2}
			MM_INDEX ${link_His1_1}
		&END LINK
    		&LINK
      			LINK_TYPE IMOMM
      			QM_INDEX ${link_His2_2}
      			MM_INDEX ${link_His2_1}
    		&END LINK
    		&LINK
      			LINK_TYPE IMOMM
      			QM_INDEX ${link_Carb_2}
      			MM_INDEX ${link_Carb_1}
    		&END LINK
    		&LINK
      			LINK_TYPE IMOMM
      			QM_INDEX ${link_Sub_2}
			MM_INDEX ${link_Sub_1}
    		&END LINK


                &PRINT
                        &QMMM_CHARGES
                        &END QMMM_CHARGES
                &END PRINT

        &END QMMM
        &SUBSYS
                &CELL
                        ABC ${x_dec} ${y_dec} ${z_dec}
                        PERIODIC XYZ
                &END CELL
                &TOPOLOGY
                        CONN_FILE_NAME ${prmtop}
                        CONN_FILE_FORMAT AMBER
                        COORD_FILE_NAME ${pdb}
                        COORD_FILE_FORMAT PDB
                &END TOPOLOGY

                &KIND H
                        BASIS_SET DZVP-MOLOPT-SR-GTH
                        BASIS_SET AUX_FIT cpFIT3
                        POTENTIAL GTH-BLYP-q1
                &END KIND

                &KIND C
                        BASIS_SET DZVP-MOLOPT-SR-GTH
                        BASIS_SET AUX_FIT cpFIT3
                        POTENTIAL GTH-BLYP-q4
                &END KIND

                &KIND O
                        BASIS_SET DZVP-MOLOPT-SR-GTH
                        BASIS_SET AUX_FIT cpFIT3
                        POTENTIAL GTH-BLYP-q6
                &END KIND

                &KIND N
                        BASIS_SET DZVP-MOLOPT-SR-GTH
                        BASIS_SET AUX_FIT cpFIT3
                        POTENTIAL GTH-BLYP-q5
                &END KIND

                &KIND FE
                        BASIS_SET DZVP-MOLOPT-SR-GTH
                        BASIS_SET AUX_FIT FIT13
                        POTENTIAL GTH-BLYP-q16
                &END KIND

                &KIND Cl-
                        ELEMENT Cl
                &END KIND
        &END SUBSYS

&END FORCE_EVAL

&MOTION
        &MD
                ENSEMBLE NVT
                STEPS 20000
                TIMESTEP [fs] 0.5
                TEMPERATURE 298
                &THERMOSTAT
                        TYPE NOSE
                        REGION GLOBAL
                        &NOSE
                                TIMECON [fs] 100.
                        &END NOSE
                &END THERMOSTAT
                &PRINT
                        &ENERGY
                                &EACH
                                        MD 10
                                &END
                        &END ENERGY
                &END PRINT
        &END MD
        &PRINT
                &RESTART OFF
                        &EACH
                                MD 1000
                        &END
                &END

                &RESTART_HISTORY
                        &EACH
                                MD 1000
                        &END
                &END

                &TRAJECTORY
                        &EACH
                                MD 10
                        &END
                &END
                &VELOCITIES OFF
                &END
                &CELL
                        &EACH
                                MD 10
                        &END
                        COMMON_ITERATION_LEVELS 3
                &END
        &END
&END MOTION

&EXT_RESTART ON
  RESTART_FILE_NAME ${System}.restart
&END EXT_RESTART

EOF

nohup mpirun -n "${nproc}" cp2k.popt -o QMMM_MD_ "${System}".out QMMM_MD_ "${System}".inp &
fi