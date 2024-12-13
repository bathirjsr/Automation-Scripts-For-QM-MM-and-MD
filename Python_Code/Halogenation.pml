set ray_trace_mode, 1
set ray_trace_shadow, 1
set ray_shadows, 1
set ray_shadow_fudge, 0.2

# Adjust ambient light and specular reflections
set ambient, 0.5
set spec_direct, 0.4
set spec_power, 100
set shininess, 10

# Enable antialiasing
set antialias, 2

# Adjust light sources
set light_count, 3
set light2, 0.2
set light3, 0.2

# Optional silhouette edges for enhanced depth
set cartoon_silhouette, 1
set cartoon_silhouette_width, 1.5
set cartoon_silhouette_color, black
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

set stick_radius, 0.05