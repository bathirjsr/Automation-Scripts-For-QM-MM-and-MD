set_color oxygen, [1.0,0.4,0.4];
set_color nitrogen, [0.5,0.5,1.0];
hide solvent;
as spheres;
util.cbaw;
set light_count,3;
set spec_count,1;
set shininess, 10;
set specular,0.25;
set ambient,0.5;
set direct,0.4;
set spec_power, 100;
set reflect,1.5;
set antialias, 2;
set ray_shadow_decay_factor, 0.1;
set ray_shadow_decay_range, 2;
set depth_cue, 0.2;
set ray_shadow, off;
bg_color white;
ray;
hide everything;


bond resname FE1, resname Cl1 ;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname SC1 and name O5;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
select ligand, resname FE1+OY1+HD1+HD2+SC1+Cl1;
set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
show sticks, ligand;    
show spheres, ligand;
color color4, ligand
hide everything, (elem H and not (neighbor elem N+O+F))
select substrate, resname D5M;
set sphere_scale, 0.15, substrate;
set stick_radius, 0.05, substrate;
show sticks, substrate;    
show spheres, substrate;
cmd.set('ray_trace_mode', 1)
cmd.set('label_size', 18);
cmd.set('label_distance_digits', 2);
set label_size, 18;
set ray_trace_mode, 1
set label_distance_digits, 2;



