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

bond resname FE1, resname SC1 and name O2;
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
select substrate, resname MEL;
set sphere_scale, 0.2, substrate;
set stick_radius, 0.1, substrate;
show sticks, substrate;    
show spheres, substrate;

distance Op-Od, resname OY1 and name O1, resname MEL and name H12;

set ray_trace_mode, 1
set label_size, 18;
set label_distance_digits, 2;