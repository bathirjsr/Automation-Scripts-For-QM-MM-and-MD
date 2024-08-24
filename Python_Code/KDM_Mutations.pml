
util.cba(9,"all",_self=cmd)

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
select substrate, resname DEL;
set sphere_scale, 0.2, substrate;
set stick_radius, 0.1, substrate;
show sticks, substrate;    
show spheres, substrate;


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