Execution Syntax: QMMM.sh -i input.in -s <stepnumber> -a <atomnumber1> -b <atomnumber2> -t <transitionstate> -p <product state>  
(input -a and -b only for Scan calculation and -t for TS optimization and -p for Product Optimization)

Edit the script for changing the path for parse_amber.tcl file

Change the vmd atomselect tcl script according to your substrate and system(QM region and MM region)

Make sure to create an input file (input.in)

#####
Contents of Input File

#Input for QMMM Modelling

parsefile=				#Parse_amber.tcl File path

system=                      		#System(Filename of the parameter)

parm=                        		#Parameter File path

frame=                             	#Frame Number

trajin=                  		#Non-Autoimaged Trajectory File

resname=\"FE1 OY1 SC1 GU1 HD1 HD2\"     #RC Residues

substrate=M3L                           #Substrate Residue

numberofres=1-552                       #Residue range

basis=def2-SVP                          #basis

charge=0                                #Charge of the system

unp=4                                   #Unpaired electrons in Iron center

nodes=20                                #Number of processors

#######
**Architecture of Directory
**
  
  
 Steps of QMMM Calculations (Execution Folder given in Brackets)

-s 0 QM and MM Modelling and Creating Files for RC_OPT (6-md Folder)

-s 1 RC Optimization (1-RC_Opt Folder)

-s 1f RC Frequency (1-RC_Opt Folder)

-s 1s RC Single Point Calculation (1-RC_Opt Folder)

-s 2 Scan (HAT) (1-RC_Opt Folder)

-s 3 TS Optimization (2-Scan Folder)

-s 3f TS Frequency (3-TS_Opt Folder)

-s 3s TS Single Point Calculation (3-TS_Opt Folder)

-s 4 PD Optimization (2-Scan Folder)

-s 4f PD Frequency (4-PD Folder)

-s 4s PD Single Point Calculation (4-PD Folder)
