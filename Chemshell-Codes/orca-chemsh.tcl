#
#  Object-oriented ORCA interface
#
#  Should work with all ORCA versions
#

proc new_orca { name args } {

  global orca
  global imagelist
  global firstcalc
  global neb

  # Option defaults
  set executable  orca
  set jobname     $name
  set restart     no
  set moinp       save.gbw
  set charge      0
  set mult        1
  set functional  undefined
  set list_option medium
  set unique_listing no
  set dispersion_correction undefined
  set gridsize    undefined
  set finalgridsize undefined
  set use_finalgrid yes
  set convergence NormalSCF
  set guess undefined
  set maxcyc undefined
  set optstr undefined
  set excited no
  set estate 1
  set eroots 1
  set tda yes
  set image undefined
  set brokensym undefined
  set bsmult undefined
  set hsmult undefined
  set spinstoflip undefined
  set neverrestart undefined
  set imagelist {}
  set firstcalc undefined
  set neb undefined

  # To run in parallel
  # Note when running in parallel the complete path should be specified
  # with the executable option in addition to having orca in your $PATH!
  # See Orca manual section 3.2
  set nproc 1

  set energy undefined
  set gradient undefined
  set hessian undefined
  set hessmode anfreq

  # ORCA input options
  set orca(in_args) { \
    coords energy gradient hessian \
    executable jobname restart moinp \
    charge mult functional \
    gridsize finalgridsize use_finalgrid
    list_option unique_listing \
    dispersion_correction \
    gridsize finalgridsize use_finalgrid \
    convergence guess nproc \
    maxcyc optstr orcasimpleinput orcablocks \
    excited estate eroots tda image brokensym bsmult hsmult spinstoflip neverrestart hessmode\
  }

  # All variables including internal ones
  set orca(variables) [ concat $orca(in_args) \
    verbose debug quiet restart_orca  listing_index ]

  # Assign name if not given
  if { "$name" == "*" } {
    if { [ info exists orca(index)  ] } {
      set index $orca(index)
      incr orca(index)
    } else {
      set index 1
      set orca(index) 2
    }
    set name orca$index
  }

  if { [ parsearg orca.init $orca(in_args) $args ] != 0 } {
    chemerror "orca failed due to bad argument"
  }

  set restart_orca [ check_boolean restart ]
  set unique_listing [ check_boolean unique_listing ]
  set excited [ check_boolean excited ]
  set tda [ check_boolean tda ]


  set verbose 0
  set debug 0
  set quiet 0
  switch $list_option {
    medium {
      set verbose 0
    }
    full {
      set verbose 1
    }
    debug {
      set verbose 1
      set debug 1
    }
    none {
      set verbose 0
      set quiet 1
    }
    default {
      chemerr "bad setting for list_option argument to orca"
    }
  }

  # for unique_listing
  set listing_index 1


  # process dispersion correction
  if { "$dispersion_correction" != "undefined" } {
    # functional first verbose coords energy gradient
    dispersion_correction_calc $dispersion_correction 1 $verbose $coords $energy $gradient
  }

  # All variables including internal ones
  set orca(variables) [ concat $orca(in_args) \
    verbose debug quiet restart_orca  listing_index ]

  # Store data for use at each point
  foreach var $orca(variables) {
    set orca($name,$var) [ set $var ]
  }

  # Create the new command
  proc $name { args } [ concat { return [ eval orca_objcmd } $name {$args ] } ]

  end_module
  return $name

}

proc orca_objcmd { name mode args } {

  global orca

  # Recover variables for this object
  foreach var $orca(variables) {
    set $var $orca($name,$var)
  }

  # image>0 is used to keep track of DL-FIND NEB images,
  # so that separate wavefunction guesses etc. can be used for each image.
  set image 0

  # Parse any args provided
  # Note this will parse the image argument for DL-FIND NEB calcs
  if { [ parsearg orca $orca(in_args) $args ] != 0 } then {
    chemerror "orca failed due to bad argument"
  }

  set gradflag 0
  set enerflag 0
  set hessflag 0

  switch $mode {
    {energy}   {
      case $energy in {
	{undefined} {
	  chemerr " you must provide an energy= argument to orca "
	}
	{default} {
	  set enerflag 1
	}
      }
    }
    {hessian}   {
      case $hessian in {
    {undefined} {
          chemerr " you must provide a hessian= argument to orca "
        }
    {default} {
          if { $hessmode == "approx" } then {
          set hessflag 3 
          } elseif { $hessmode == "numfreq" } then {
          set hessflag 2 
          }  elseif { $hessmode == "xtbfreq" } then {
          set hessflag 4
          } else { set hessflag 1 }
       }
      }
    }
    eandg -
    gradient {
      case $energy in {
	{undefined} {
	  chemerr " you must provide an energy= argument to orca "
	}
	{default} {
	  set enerflag 1
	}
      }
      case $gradient in {
	{undefined} {
	  chemerr " you must provide a gradient= argument to orca "
	}
	{default} {
	  set gradflag 1
	}
      }
    }
  }

  #  ================= Generate ORCA input file =================
  #
global neb
  push_banner_flag 0

# Putting Neb = yes as soon as image number changes
# A way to find out whether we are doing NEB or not. Better way??
if {$image > 1} {
set neb "yes"
}
#puts "Image is $image. neb is $neb"

#list to keep track of image numbers
global imagelist
global firstcalc
#puts "Current image is $image"
#puts "imagelist is $imagelist"
#puts "last list-image is [lindex $imagelist end] "
#puts "firstcalc is $firstcalc"

if  {$image < [lindex $imagelist end] && $firstcalc == "undefined" } {
#puts "image is $image"
#puts "last list-image is [lindex $imagelist end] "
puts ""
puts "---------------"
puts "First energy calculation of all images is now done (using ORCA guess orbitals). Setting firstcalc to done. "
puts "Images from now on will use previous orbitals for each specific image"
puts "--------"
set firstcalc "done"
}

puts ""
#Appending to list
lappend imagelist $image


#puts "We are about to generate Inputfile. image is $image . restart_orca is $restart_orca"
#puts "-----------"
  set fp [ open $jobname.inp w ]

  set natoms [ get_number_of_atoms coords=$coords ]
  set nbq [ get_number_of_bqs coords=$coords ]
  set ncent  [ expr $natoms + $nbq]

  puts $fp "# Orca input file generated by ChemShell"

  # "Simple input"
if { $gradflag } then {
    puts $fp " $orcasimpleinput Engrad"} else { puts $fp "$orcasimpleinput" }

# RB. Here adding keyword for Hessian. Hessflag=1 requests analytical Hessian. Hessflag2 is Numerical. Hessflag 3 is approximate Almlöf.
#Hessflag 4 is xtb Hessian. Requires xtb.
#RB
#puts "hessflag is $hessflag"

if { $hessflag == 1 } then {
    puts $fp "! freq"

}
if { $hessflag == 2 } then {
    puts $fp "! numfreq"
}
if { $hessflag == 3 } then {
    puts $fp "! OPT"
    puts $fp "%geom maxiter 1 end"
}

#Xtb Hessian. Requires xyzfile
if { $hessflag == "4"} then {
write_xyz coords=$coords file=$jobname.xyz
}


  # Parallel execution
  if { $nproc > 1 } then {
    puts $fp "%pal"
    puts $fp "  nprocs $nproc"
    puts $fp "end"
  }

  # Specify point charge file (created below)
  if { $nbq > 0 } then {
    puts $fp "%pointcharges \"pointcharges.xyz\" "
  }

# Adding extra blocks from Chemshell inputfile
  puts $fp "$orcablocks"

#Adding options to allow for ORCA Flipspin-BS optimization

  # SCF block to handle Autostart and guess orbitals
  puts $fp "%scf"

# neverrestart option to prevent MOREAD. Useful in NEB to prevent MOREAD in each ORCA calculation.

# NEB mode
if {$neb == "yes"} {
    if { $neverrestart == "yes" } {
        puts "NEB: Neverrestart is active! Creating new Guess orbitals for each ORCA calculation"
        puts $fp "  AutoStart false"
    } else {
           if  { $restart_orca && $firstcalc == "done" } {
              puts "NEB: Restart and Firstcalc done. Will read orbitals from $moinp"
              puts $fp "  Guess MORead"
              puts $fp "  MOInp \"$moinp\""
              if { $brokensym == "yes" } {
                  set mult $bsmult
              }
           } else {
               puts "NEB mode: Autostart false for this image"
               if { $guess != "undefined" } {
                   puts $fp "  Guess $guess"
               }
               # Adding possible Flipspin/FinalMS keywords here
               if { $brokensym == "yes" } {
                  puts $fp "  Flipspin $spinstoflip"
                  puts $fp "  FinalMS [expr ($bsmult - 1 ) / 2.0 ]"
                  set mult $hsmult
               }
        }
    }

} else {
    puts "OPT mode"
    # Regular mode
    if { $neverrestart == "yes" } {
        puts "Neverrestart is active! Creating new Guess orbitals for each ORCA calculation"
        puts $fp "  AutoStart false"
    } else {
          if  { $restart_orca } {
        puts "Using MOREAD. Will read orbitals from $moinp"
        puts $fp "  Guess MORead"
        puts $fp "  MOInp \"$moinp\""
            if { $brokensym == "yes" } {
            set mult $bsmult
            }
        } else {
            puts "Autostart false"
               if { $guess != "undefined" } {
            puts $fp "  Guess $guess"
            }
            puts $fp "  AutoStart false"
            # Adding possible Flipspin/FinalMS keywords here
            if { $brokensym == "yes" } {
            puts $fp "  Flipspin $spinstoflip"
            puts $fp "  FinalMS [expr ($bsmult - 1 ) / 2.0 ]"
            set mult $hsmult
            }
        }
    }
}

  if { $maxcyc != "undefined" } {
    puts $fp "  MaxIter $maxcyc"
  }
  puts $fp "end"


  # Geometry
  puts $fp "%coords"
  puts $fp "  CTyp xyz"
  puts $fp "  Charge $charge"
  puts $fp "  Mult $mult"
  puts $fp "  Units bohrs"
  puts $fp "  coords"
  for {set i 1} {$i <= $natoms} { incr i } {
    puts $fp [ get_atom_entry coords=$coords atom_number= $i ]
  }
  puts $fp "  end"
  puts $fp "end"

  # User-defined options
  if { $optstr != "undefined" } {
    puts $fp $optstr
  }

  close $fp
  # Point charge file
  if { $nbq > 0 } then {
    set pc [ open pointcharges.xyz w]
    puts $pc "$nbq"
    for { set i 1 } { $i <= $nbq } { incr i } {
      set entry [ get_bq_entry coords=$coords bq_number=$i unit=angstrom ]
      puts $pc "[ lindex $entry 4 ] [ lindex $entry 1 ] [ lindex $entry 2 ] [ lindex $entry 3 ] "
    }
    close $pc
  }

  #
  # =========================== Run ORCA ===========================
  #

  # Delete old output file if it exists from a previous run
  file delete $jobname.out
  if { $restart_orca == 0 } {
    # Discard restart information
    file delete $moinp
  }

  if {$image > 0 } {
  # Specify a file suffix to separate image files
  set imageid ".img$image"
    # Copy input file for actual image if present.
     puts "Before ORCA run: Copying file $moinp$imageid to file  $moinp"
    if { [ file exists "$moinp$imageid" ] } {
        catch { file copy -force -- "$moinp$imageid" $moinp }
        # Check whether file has really been copied.
        set status [catch {exec diff "$moinp$imageid" $moinp} result]
            if {$status == 1} {
            puts "** WARNING, copy process failed !!! Orca will try to restart from whatever is left in $moinp **"
            }
    }
  }

  set code 0
  set code [ exec_module orca "$executable $jobname.inp > $jobname.out " NULL ]



#If XTB Hessian requested do xtb job
if { $hessflag == "4"} then {
set unpel [expr $mult - 1]
    if {$unpel > 0 } {
    exec xtb $jobname.xyz -hess -chrg $charge -uhf $unpel > xtbhess.out
    } else {
    exec xtb $jobname.xyz -hess -chrg $charge > xtbhess.out
    }
}

  if { "$code" != "0" } then {
    puts stdout "error detected, code $code"
    error "ORCA failed"
  }

  # ORCA manual states that jobname.gbw cannot be used for restarts,
  # hence why we have to copy it to another name
  file copy -force $jobname.gbw $moinp

 if { $image > 0 } {
      catch { file copy -force -- $jobname.gbw "$moinp$imageid" }
      puts "ORCA done. Copying file $jobname.gbw to $moinp$imageid"
      # Check whether file has really been copied back.
      set status [catch {exec diff $jobname.gbw "$moinp$imageid"} result]
           if {$status == 1} {
           puts "** WARNING, process to copy back the actual wave function failed !!! "
           puts "This might lead to Orca failing in the next cycle for this image **"
	   }
  }

  # restart on future calcs
  set orca($name,restart_orca) 1

  #
  # ======================= Read ORCA output =======================
  #
# RB. Reading analytic or numerical hessian from orca1.hess file
  if { $hessflag == "1" || $hessflag == "2" } then {
  puts "Now finding exact Hessian ($hessmode)"
  #puts "variable hessian is $hessian"

set hessline hessian

set hfpout [ open orca1.hess r ]
    # search for "$hessian"
    set code [ gets $hfpout line ]
    while { $line != "$$hessline" && $code != -1 } {
      set code [ gets $hfpout line ]
    }
    if { $code == -1 } then { chemerr "Couldn't find hessian in orca1.hess" }
    # skip a line
    set code [ gets $hfpout line ]
    set hesssize [lindex $line 0]
    set code [ gets $hfpout line ]
    # read in data
#puts "ncent is $ncent"
    set_matrix_size datatype=real dimensions= "$hesssize $hesssize" matrix=$hessian name= "hessian"
set counthess 0
#Loop over batches
set batch [expr $hesssize / 6]
for {set q 0} {$q < $batch } { incr q 1} {
     # Loop for each bunch
    for {set i 0} {$i < $hesssize } { incr i 1} {
      set code [ gets $hfpout line ]
      set val [lindex $line 0 ]
      set val1 [lindex $line 1 ]
      set val2 [lindex $line 2 ]
      set val3 [lindex $line 3 ]
      set val4 [lindex $line 4 ]
      set val5 [lindex $line 5 ]
      set val6 [lindex $line 6 ]

# first index in matrix are the columns in orca1.hess. Second index is the row
set column [expr $counthess + 0]
set x1 [expr $column + 0]; set x2 [expr $column + 1]; set x3 [expr $column + 2]; set x4 [expr $column + 3]; set x5 [expr $column + 4]; set x6 [expr $column + 5]
      set_matrix_element indices= "$x1 $i" value = $val1 matrix=$hessian
      set_matrix_element indices= "$x2 $i" value = $val2 matrix=$hessian
      set_matrix_element indices= "$x3 $i" value = $val3 matrix=$hessian
      set_matrix_element indices= "$x4 $i" value = $val4 matrix=$hessian
      set_matrix_element indices= "$x5 $i" value = $val5 matrix=$hessian
      set_matrix_element indices= "$x6 $i" value = $val6 matrix=$hessian

    }
# Next columns have numbers +6
set counthess [expr $counthess + 6]
#Skipping the orca indices line here
set code [ gets $hfpout line ]
}
puts "Printing the Hessian"
print_matrix matrix=$hessian
    close $hfpout
  }

#########
# RB. Finding approximate Hessian (Almlöf)
######
  if { $hessflag == 3 } then {
  puts "Now finding approximate Hessian (Almlöf)"
set hessline hessian_approx

set hfpout [ open orca1.opt r ]
    # search for "$hessian"
    set code [ gets $hfpout line ]
    while { $line != "$$hessline" && $code != -1 } {
      set code [ gets $hfpout line ]
    }
    if { $code == -1 } then { chemerr "Couldn't find hessian in orca1.opt" }
    # skip a line
    set code [ gets $hfpout line ]
    set hesssize [lindex $line 0]
    set code [ gets $hfpout line ]
    # read in data
    set_matrix_size datatype=real dimensions= "$hesssize $hesssize" matrix=$hessian name= "hessian"
set counthess 0
#Loop over batches
set batch [expr $hesssize / 6]
for {set q 0} {$q < $batch } { incr q 1} {
     # Loop for each bunch
    for {set i 0} {$i < $hesssize } { incr i 1} {
      set code [ gets $hfpout line ]
      set val [lindex $line 0 ]
      set val1 [lindex $line 1 ]
      set val2 [lindex $line 2 ]
      set val3 [lindex $line 3 ]
      set val4 [lindex $line 4 ]
      set val5 [lindex $line 5 ]
      set val6 [lindex $line 6 ]

# first index in matrix are the columns in orca1.hess. Second index is the row
set column [expr $counthess + 0]
set x1 [expr $column + 0]; set x2 [expr $column + 1]; set x3 [expr $column + 2]; set x4 [expr $column + 3]; set x5 [expr $column + 4]; set x6 [expr $column + 5]
      set_matrix_element indices= "$x1 $i" value = $val1 matrix=$hessian
      set_matrix_element indices= "$x2 $i" value = $val2 matrix=$hessian
      set_matrix_element indices= "$x3 $i" value = $val3 matrix=$hessian
      set_matrix_element indices= "$x4 $i" value = $val4 matrix=$hessian
      set_matrix_element indices= "$x5 $i" value = $val5 matrix=$hessian
      set_matrix_element indices= "$x6 $i" value = $val6 matrix=$hessian

    }
# Next columns have numbers +6
set counthess [expr $counthess + 6]
#Skipping the orca indices line here
set code [ gets $hfpout line ]
}
puts "Printing the approximate Hessian"
print_matrix matrix=$hessian
    close $hfpout
  }

####
# RB. Finding the xtB Hessian
######
if { $hessflag == 4 } then {
puts "Now finding xTB Hessian in output"
set hesssize [expr $natoms *3]
puts "hesssize is $hesssize"
set_matrix_size datatype=real dimensions= "$hesssize $hesssize" matrix=$hessian name= "hessian"


set hfpout [ open hessian r ]
set file_data [read $hfpout]
close $hfpout
set data [split $file_data "\n"]
set data [lreplace $data 0 0]
set counthess 0
set counter 0
set i 0
foreach line $data {
  if {[llength $line] == 0} {
   break
  }
  set line [lindex $data $counter]
  set linelength [llength $line]
    for {set k 0 } {$k < $linelength} {incr k 1} {
        set val [lindex $line $k]
        #puts "counthess is $counthess and i is $i and val is $val"
        set_matrix_element indices= "$counthess $i" value = $val matrix=$hessian
        set counthess [expr $counthess + 1]
    }
    set counter [expr $counter + 1]
    if {$counthess == [expr $hesssize - 0] } {
        #puts "reset"
        set counthess 0
        set i [expr $i + 1]
    }

}
puts "Printing xTB Hessian:"
print_matrix matrix=$hessian
}


  if { $gradflag } then {
    set fpout [ open $jobname.engrad r ]
    if { $enerflag } then {
      # search for "# The current total energy in Eh" in $jobname.engrad
      set code [ gets $fpout line ]
      while { $line != "# The current total energy in Eh" && $code != -1 } {
        set code [ gets $fpout line ]
      }
      if { $code == -1 } then { chemerr "Couldn't find energy in ORCA .engrad file" }
      # skip a line
      set code [ gets $fpout line ]
      # read in data
      set code [ gets $fpout line ]
      set val [ lindex $line 0 ]
      set_matrix_size datatype=real dimensions= "1 1" matrix=$energy name="energy"
      set_matrix_element indices= "0 0" value = $val matrix=$energy
    }
    # search for "# The current gradient in Eh/bohr"
    set code [ gets $fpout line ]
    while { $line != "# The current gradient in Eh/bohr" && $code != -1 } {
      set code [ gets $fpout line ]
    }
    if { $code == -1 } then { chemerr "Couldn't find gradient in ORCA .engrad file" }
    # skip a line
    set code [ gets $fpout line ]
    # read in data
    set_matrix_size datatype=real dimensions= "3 $ncent" matrix=$gradient name= "gradient"
    for {set i 0} {$i < $natoms} { incr i } {
      set code [ gets $fpout line ]
      set val [lindex $line 0]
      set_matrix_element indices= "0 $i" value = $val matrix=$gradient
      set code [ gets $fpout line ]
      set val [lindex $line 0]
      set_matrix_element indices= "1 $i" value = $val matrix=$gradient
      set code [ gets $fpout line ]
      set val [lindex $line 0]
      set_matrix_element indices= "2 $i" value = $val matrix=$gradient
    }
    close $fpout
    # get point charge gradient if there is one
    if { $nbq != 0 } then {
      set fpout [ open $jobname.pcgrad r ]
      gets $fpout line
      set val [lindex $line 0]
      if { $val != $nbq } { chemerr "Inconsistent nbq in ORCA .pcgrad file" }
      set ncent [ expr $natoms + $nbq ]
      for { set i $natoms } { $i < $ncent } { incr i } {
	gets $fpout line
        set val [lindex $line 0]
	set_matrix_element indices= "0 $i" value = $val matrix=$gradient
        set val [lindex $line 1]
	set_matrix_element indices= "1 $i" value = $val matrix=$gradient
        set val [lindex $line 2]
	set_matrix_element indices= "2 $i" value = $val matrix=$gradient
      }
      close $fpout
    }
  } elseif { $enerflag } then {
    set fpout [ open $jobname.out r ]
    # search for "FINAL SINGLE POINT ENERGY" in $jobname.out
    # (.engrad has more sig figs but is only written out for gradient calcs)
    set code [ gets $fpout line ]
    while { [ string first "FINAL SINGLE POINT ENERGY" $line ] == -1  && $code != -1 } {
      set code [ gets $fpout line ]
    }
    if { $code == -1 } then { chemerr "Couldn't find energy in ORCA output file" }
    set val [ lindex $line 4 ]
    set_matrix_size datatype=real dimensions= "1 1" matrix=$energy name="energy"
    set_matrix_element indices= "0 0" value = $val matrix=$energy
    close $fpout
  }

  # save i/o files if requested
  if { $unique_listing } {
    file rename -force $jobname.inp $jobname.inp.$listing_index
    file rename -force $jobname.out $jobname.out.$listing_index
    incr orca($name,listing_index)
  }

  pop_banner_flag

  # process dispersion_correction
  if { "$dispersion_correction" != "undefined" } {
    # functional first verbose coords energy gradient
    dispersion_correction_calc $dispersion_correction 0 $verbose $coords $energy $gradient
  }

  end_module

  return 0

}

#
# Procedural interfaces

proc orca.potential { args } {
    puts "args is $args"

    #set Xgridfile gridmat.c
    set Xgridfile pbbpgrid

    flush_object $Xgridfile

    set coordfactor 1.0
    set gridfile [ open $Xgridfile r ]
    set grid_data [read $gridfile]
    set data [split $grid_data "\n"]
    set allxyz {}
    foreach line $data {
    if {[string match "block = coordinates records*" $line ] != 0} {
    set numpoints [lindex $line end]
        puts "numpoints is $numpoints"
    }
    if {[string match "bq*" $line ] != 0} {
        set x [lindex $line 1]
        set y [lindex $line 2]
        set z [lindex $line 3]
        set xyz {}
        lappend xyz $x;lappend xyz $y;lappend xyz $z
        lappend allxyz $xyz
    }
    }
    close $gridfile
    set gridfile2 [ open orca1.vpot.xyz w ]
    puts $gridfile2 $numpoints
    foreach val $allxyz {
        foreach c $val {
        set new_c [expr $c * $coordfactor]
        lappend new_val $new_c
        }
    puts $gridfile2 $new_val
    set new_val {}
    }
    close $gridfile2

    exec orca_vpot orca1.gbw orca1.scfp orca1.vpot.xyz orca1.vpot.out
    set potfile [ open orca1.vpot.out r ]
    set pot_data [read $potfile]
    set pdata [split $pot_data "\n"]
    set potcharges {}
    foreach line $pdata {
        if {[llength $line] > 1} {
            lappend potcharges [lindex $line 3]
        }
    }
    #Adding Elstat potential charges from orca1.vpot.out
    set factor 1.0
    push_banner_flag 0
    for {set i 0} {$i < [llength $potcharges] } {incr i 1 } {
        set charge [lindex $potcharges $i]
        set_atom_charge coords=$Xgridfile atom_number=[expr $i + 1] charge=[expr ($charge * $factor) ]
        #set_bq_charge coords=$Xgridfile bq_number=[expr $i + 1] charge=$charge
    }
    push_banner_flag 1
#Fit charges.???
#      fit_esp_charges coords=$mndo(mndo1,coords) grid=mndogrid.c \
#      method=$mndo(mndo1,esp_method)  store= $storefrag


#return [ orca potential]
}

# RB Hessian addition
#Trying out orca.hess here.

proc orca.hess args {
  return [ eval orca1 hessian $args ]
}

#
proc orca.init args {
  global orca
  new_orca orca1 $args
  return 0
}
proc orca.energy { args } {
  return [ eval orca1 energy $args ]
}
proc orca.gradient { args } {
  return [ eval orca1 gradient $args ]
}
proc orca.eandg { args } {
  return [ eval orca1 eandg $args ]
}
proc orca.update { args } {
  return 0
}
proc orca.kill args {
  return 0
}

proc orca2.init args {
  global orca
  new_orca orca2 $args
  return 0
}
proc orca2.energy { args } {
  return [ eval orca2 energy $args ]
}
proc orca2.gradient { args } {
  return [ eval orca2 gradient $args ]
}
proc orca2.eandg { args } {
  return [ eval orca2 eandg $args ]
}
proc orca2.update { args } {
  return 0
}
proc orca2.kill args {
  return 0
}

proc orca3.init args {
  global orca
  new_orca orca3 $args
  return 0
}
proc orca3.energy { args } {
  return [ eval orca3 energy $args ]
}
proc orca3.gradient { args } {
  return [ eval orca3 gradient $args ]
}
proc orca3.eandg { args } {
  return [ eval orca3 eandg $args ]
}
proc orca3.update { args } {
  return 0
}
proc orca3.kill args {
  return 0
}
