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
set sphere_scale, 0.2;
set stick_radius, 0.1;
bg_color white;
ray;
hide everything;

bond resname FE1, resname AP1 and name OD2;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname AG1 and name O1;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
select ligand, (resname FE1+OY1+HD1+HD2+AP1+AG1+ADG) or (resname WAT and resid 2446);
set sphere_scale, 0.2, ligand;
set stick_radius, 0.1, ligand;
show sticks, ligand;    
show spheres, ligand;
hide everything, (elem H and not (neighbor elem N+O+F) )
select substrate, resname AG1;
set sphere_scale, 0.2, substrate;
set stick_radius, 0.1, substrate;
show sticks, substrate;    
show spheres, substrate;
cmd.set('ray_trace_mode', 1)
cmd.set('label_size', 18);
cmd.set('label_distance_digits', 2);
set label_size, 18;
set ray_trace_mode, 1
set label_distance_digits, 2;
util.cba(5271,"all",_self=cmd)
# Edit the name for the ditance, the selection criteria for atom 1, and the selection criteria for atom 2.;
# distance Op-Od, resname OY1 and name O1, resname OY1 and name O2;
# distance Od-C1, resname OY1 and name O1, resname AG1 and name C1;
# distance Od-C2, resname OY1 and name O2, resname AG1 and name C2;
# distance C1-C2, resname AG1 and name C1, resname AG1 and name C2;

# set_color color1, [214, 206, 147]
# set_color color2, [239, 235, 206]
# set_color color3, [216, 164, 143]
# set_color color4, [187, 133, 136]
# color color1, pd.opt    
# color color2, 5039_pd
# color color3, 8386_pd
# color color4, mutant
# set_view (\
#     -0.153048858,    0.974280059,    0.165386051,\
#     -0.254223377,    0.122906312,   -0.959300160,\
#     -0.954955697,   -0.188865423,    0.228872821,\
#      0.000300374,   -0.000132024,  -50.095298767,\
#     33.487796783,   46.329124451,   39.412361145,\
#      3.241513014,   96.954513550,  -20.000000000 )
# ### cut above here and paste into script ###

set_view (\
     0.837318718,    0.531110346,    0.129679412,\
    -0.026537690,    0.276400328,   -0.960671306,\
    -0.546067894,    0.800948262,    0.245527729,\
     0.000026099,   -0.000360886,  -50.095233917,\
    33.954673767,   34.942344666,   38.790073395,\
     3.241513014,   96.954513550,  -20.000000000 )
### cut above here and paste into script ###

# /GIT/Bathir-s-PHD/Python_Code/EFE_Pub.pml
util.cnc("all",_self=cmd)
wizard measurement;