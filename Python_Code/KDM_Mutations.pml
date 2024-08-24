<<<<<<< HEAD
set light_count,10;
set spec_count,1;
set shininess, 10;
set specular,0.25;
set ambient,0;
set direct,0;
set reflect,1.5;
set ray_shadow_decay_factor, 0.1;
set ray_shadow_decay_range, 2;
set depth_cue, 0.2;
set ray_shadow, off;
bg_color white;
ray;
hide everything;
util.cba(6,"all",_self=cmd)
=======

util.cba(9,"all",_self=cmd)
>>>>>>> 2ab8d5d89fc39a5bc35093d0754e1905e04af2d8

bond resname FE1, resname SC1 and name O1;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname GU1 and name OE2;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
select ligand, resname FE1+OY1+HD1+HD2+GU1+SC1;
set sphere_scale, 0.2, ligand;
set stick_radius, 0.1, ligand;
show sticks, ligand;    
show spheres, ligand;
hide everything, (elem H and not (neighbor elem N+O+F))
<<<<<<< HEAD
select substrate, resname MEL;
=======
select substrate, resname DEL;
>>>>>>> 2ab8d5d89fc39a5bc35093d0754e1905e04af2d8
set sphere_scale, 0.2, substrate;
set stick_radius, 0.1, substrate;
show sticks, substrate;    
show spheres, substrate;

<<<<<<< HEAD
distance Op-Od, resname OY1 and name O1, resname MEL and name H12;

set ray_trace_mode, 1
set label_size, 18;
set label_distance_digits, 2;
=======

set ray_trace_mode, 1
set label_size, 18;
set label_distance_digits, 2;

set_view (\
    -0.342459202,   -0.840235710,    0.420387566,\
    -0.239779219,   -0.354463607,   -0.903803706,\
     0.908419609,   -0.410318345,   -0.080083914,\
     0.000159135,   -0.000191981,  -58.897499084,\
    62.706779480,   42.024501801,   54.592456818,\
   -28.421421051,  146.211990356,  -20.000000000 )
### cut above here and paste into script ###
wizard measurement
>>>>>>> 2ab8d5d89fc39a5bc35093d0754e1905e04af2d8
