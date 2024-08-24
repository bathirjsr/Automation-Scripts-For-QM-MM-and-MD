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

bond resname FE1, resname AP1 and name O1;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname AG1 and name O1;
bond resname FE1, resname AG1 and name O5;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
select ligand, resname FE1+OY1+HD1+HD2+AP1+AG1+ADG;
set sphere_scale, 0.2, ligand;
set stick_radius, 0.1, ligand;
show sticks, ligand;    
show spheres, ligand;
hide everything, (elem H and not (neighbor elem N+O+F))
select substrate, resname AG1;
set sphere_scale, 0.2, substrate;
set stick_radius, 0.1, substrate;
show sticks, substrate;    
show spheres, substrate;
select mutant,resid 198+173+186+277;
set sphere_scale, 0.1, mutant;
set stick_radius, 0.05, mutant;
show sticks, mutant;    
show spheres, mutant;
set label_size, 18;
set ray_trace_mode, 1
set label_distance_digits, 2;
util.cba(20,"all",_self=cmd)
# Edit the name for the ditance, the selection criteria for atom 1, and the selection criteria for atom 2.;
# distance Op-Od, resname OY1 and name O1, resname OY1 and name O2;
# distance Od-C1, resname OY1 and name O1, resname AG1 and name C1;
# distance Od-C2, resname OY1 and name O2, resname AG1 and name C2;
# distance C1-C2, resname AG1 and name C1, resname AG1 and name C2;

set_color color1, [214, 206, 147]
set_color color2, [239, 235, 206]
set_color color3, [239, 235, 206]
set_color color4, [187, 133, 136]
color color1, pd.opt    
color color2, 5039_pd
color color3, 8386_pd
color color4, mutant

set_view (\
    -0.564175487,   -0.667428851,    0.486046940,\
     0.331022352,    0.356451452,    0.873704135,\
    -0.756388843,    0.653814793,    0.019832276,\
     0.000042114,   -0.000192702,  -45.779201508,\
    37.403354645,   31.536628723,   29.700807571,\
    -0.976287842,   92.525848389,  -20.000000000 )
# /GIT/Bathir-s-PHD/Python_Code/EFE_Pub.pml
util.cnc("all",_self=cmd)
wizard measurement;