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
set ambient_occlusion_scale, 10;
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
select ligand, resname FE1+OY1+HD1+HD2+SC1+Cl1+D5M;
preset.ball_and_stick(selection='ligand');
util.cbaw ligand;
set stick_color, white, ligand;
set valence, off, ligand;
unset valence;
# above command is required after using preset;
set sphere_color, black, elem C and ligand;
set sphere_color, red, elem O and ligand;
set sphere_color, blue, elem N and ligand;
set sphere_color, lightblue, elem F and ligand;
set stick_radius, 0.05;
set sphere_quality, 1;
set sphere_scale, 0.15;
set cartoon_ring_finder, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.1, ligand;
set cartoon_ring_transparency, .0, ligand;



