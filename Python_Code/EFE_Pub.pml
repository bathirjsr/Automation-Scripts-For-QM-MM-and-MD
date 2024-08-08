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
set label_size, 18;
set ray_trace_mode, 1

# /GIT/Bathir-s-PHD/Python_Code/EFE_Pub.pml