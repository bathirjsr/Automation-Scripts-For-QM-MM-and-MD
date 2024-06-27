# Edit the selection that is named ligand here.;
create ligand, /bluComplex/C/A/1101;
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
set stick_radius, 0.12;
set sphere_quality, 4;
set cartoon_ring_finder, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.12, ligand;
set cartoon_ring_transparency, .0, ligand;
show cartoon, ligand;

set_color oxygen, [1.0,0.4,0.4];
set_color nitrogen, [0.5,0.5,1.0];
remove solvent;
as sticks;
util.cbaw;
bg white;
set light_count,10;
set spec_count,1;
set shininess, 10;
set specular,0.25;
set ambient,0;
set direct,0;
set reflect,1.5;
set ray_shadow_decay_factor, 0.1;
set ray_shadow_decay_range, 2;
color gray00, symbol c
color gray90, symbol h
set depth_cue, 0;
ray;

set_color oxygen, [1.0,0.4,0.4];
set_color nitrogen, [0.5,0.5,1.0];
remove solvent;
as spheres;
util.cbaw;
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
ray;
hide everything;


bond resname FE1, resname AP1 and name O1;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname AG1 and name O1;
bond resname FE1, resname AG1 and name O5;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
create ligand, resname FE1+OY1+HD1+HD2+AP1+AG1+ADG;
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
set cartoon_ring_finder, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.1, ligand;
set cartoon_ring_transparency, .0, ligand;


# Edit the selection that is named ligand here.;
create triad, resname HD1 or resname HD2;
preset.ball_and_stick(selection='triad');
util.cbaw triad;
set stick_color, white, triad;
set valence, off, triad;
unset valence;
# above command is required after using preset;
set sphere_color, black, elem C and triad;
set sphere_color, red, elem O and triad;
set sphere_color, blue, elem N and triad;
set sphere_color, lightblue, elem F and triad;
set stick_radius, 0.05;
set sphere_quality, 1;
set cartoon_ring_finder, 4, triad;
set cartoon_ring_mode, 3, triad;
set cartoon_ring_width, 0.1, triad;
set cartoon_ring_transparency, .0, triad;
show cartoon, triad;

create 2OG, resname AG1;
preset.ball_and_stick(selection='2OG');
util.cbaw 2OG;
set stick_color, white, 2OG;
set valence, off, 2OG;
unset valence;
# above command is required after using preset;
set sphere_color, black, elem C and 2OG;
set sphere_color, red, elem O and 2OG;
set sphere_color, blue, elem N and 2OG;
set sphere_color, lightblue, elem F and 2OG;
set stick_radius, 0.05;
set sphere_quality, 1;
set cartoon_ring_finder, 4, 2OG;
set cartoon_ring_mode, 3, 2OG;
set cartoon_ring_width, 0.1, 2OG;
set cartoon_ring_transparency, .0, 2OG;
show cartoon, 2OG;

create SCS, byres (resname FE1+OY1+AG1 around 5 and not resname FE1+OY1+AG1+HD1+HD2+ADG+AP1);
util.cbaw SCS;
set valence, off, SCS;
unset valence;
# above command is required after using preset;
set sphere_color, black, elem C and SCS;
set sphere_color, red, elem O and SCS;
set sphere_color, blue, elem N and SCS;
set sphere_color, lightblue, elem F and SCS;
set stick_radius, 0.05, SCS;
set sphere_quality, 1;
set cartoon_ring_finder, 4, SCS;
set cartoon_ring_mode, 3, SCS;
set cartoon_ring_width, 0.1, SCS;
set cartoon_ring_transparency, .0, SCS;
show sticks, 2OG;
space cmyk
util.performance(0)
dist polar, SCS, ligand, mode=2


# Select donor atoms (e.g., nitrogen and oxygen atoms that can donate hydrogen bonds)
select donor1, ligand and (elem N+O) and not (resn HOH)
select donor2, SCS and (elem N+O) and not (resn HOH)

# Select acceptor atoms (e.g., nitrogen and oxygen atoms that can accept hydrogen bonds)
select acceptor1, ligand and (elem N+O) and not (resn HOH)
select acceptor2, SCS and (elem N+O) and not (resn HOH)

# Find pairs of atoms within 3.5 angstroms (hydrogen bonds typically are within this range)
find_pairs cutoff=3.5, selection1=donor1, selection2=acceptor2
find_pairs cutoff=3.5, selection1=donor2, selection2=acceptor1

# Create a distance object to visualize the polar contacts
dist polar_contacts, donor1, acceptor2, cutoff=3.5
dist polar_contacts, donor2, acceptor1, cutoff=3.5

# Edit the selection that is named ligand here.;
create ligand, resname FE1+OY1+HD1+HD2+AP1+AG1+ADG;
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
set stick_radius, 0.12;
set sphere_quality, 4;
set cartoon_ring_finder, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.12, ligand;
set cartoon_ring_transparency, .0, ligand;
show cartoon, ligand;


delete all;
fetch 4PCO, type=pdb,async=0;
select G2G3, ( ((resi 2 or resi 3) and chain A) or ((resi 8 or resi 9) and chain B) );
hide everything, element h; 
remove not G2G3;
bg_color white;
show sticks;
set stick_radius=0.14;
set stick_ball, on; 
set stick_ball_ratio,1.9;
set_view (-0.75,0.09,0.66,-0.2,0.92,-0.35,-0.64,-0.39,-0.67,-0.0,-0.0,-43.7,7. 24,9.55,11.78,29.46,57.91,-20.0);
hide everything, element H;
select carbon1, element C and (resi 3 or resi 8); 
# select lower base pair;
select carbon2, element C and (resi 2 or resi 9);
#select upper base pair;
color gray70,carbon1;
color gray10,carbon2;
space cmyk;
distance hbond1,/4PCO//B/U`9/N3,/4PCO//A/G`2/O6;
distance hbond2,/4PCO//B/U`9/O2,/4PCO//A/G`2/N1;
distance hbond3,/4PCO//A/U`3/N3,/4PCO//B/G`8/O6;
distance hbond4,/4PCO//A/U`3/O2,/4PCO//B/G`8/N1;
color black, hbond1;
color black, hbond2;
color gray70, hbond3;
color gray70, hbond4;
show nb_spheres;
set nb_spheres_size, 0.35;
hide labels;
ray 1600,1000;
png 4PCO.png

viewport 900,600;
fetch 3nd4, type=pdb, async=0;
run ~/Scripts/PyMOLScripts/quat.py;
quat 3nd4;
show sticks;
set stick_radius=0.125;
hide everything, name H*;
bg_color white;
create coorCov, (3nd4_1 and (resi 19 or resi 119 or resi 219 or resi 319 or resi 419 or resi 519 or (resi 3 and name N7)));
bond (coorCov//A/NA`19/NA),(coorCov//A/A`3/N7);
bond (coorCov//A/NA`19/NA),(coorCov//A/HOH`119/O);
bond (coorCov//A/NA`19/NA),(coorCov//A/HOH`219/O);
bond (coorCov//A/NA`19/NA),(coorCov//A/HOH`319/O);
bond (coorCov//A/NA`19/NA),(coorCov//A/HOH`519/O);
distance (3nd4_1 and chain Aand resi 19 and name NA), (3nd4_1 and chain A and resi 519);
distance (3nd4_1 and chain A and resi 19 and name NA), (3nd4_1 and chain A and resi 419);
distance (3nd4_1 and chain A and resi 19 and name NA), (3nd4_1 and chain A and resi 319);
distance (3nd4_1 and chain A and resi 19 and name NA), (3nd4_1 and chain A and resi 219);
show nb_spheres; 
set nb_spheres_size, .35;
distance hbond1,/3nd4_1/1/A/HOH`119/O, /3nd4_1/1/A/A`3/OP2;
distance hbond2,/3nd4_1/1/A/HOH`319/O, /3nd4_1/1/A/A`3/OP2;
distance hbond3,/3nd4_1/1/A/HOH`91/O,/3nd4_1/1/A/HOH`119/O;
distance hbond4,/3nd4_1/1/A/G`4/N7,/3nd4_1/1/A/HOH`91/O;
distance hbond5,/3nd4_1/1/A/G`4/O6, /3nd4_1/1/A/HOH`419/O;
distance hbond6,/3nd4_1/1/A/HOH`91/O,/3nd4_1/1/A/G`4/OP2;
distance hbond7,/3nd4_1/1/A/HOH`319/O,/3nd4_1/1/A/G`2/OP2;
distance  hbond9,/3nd4_1/1/A/HOH`419/O,/3nd4_2/2/A/HOH`74/O;
distance hbond10,/3nd4_2/2/A/C`15/O2,/3nd4_1/1/A/G`2/N2;
distance hbond11, /3nd4_2/2/A/C`15/N3,/3nd4_1/1/A/G`2/N1;
distance hbond12,/3nd4_2/2/A/C`15/N4,/3nd4_1/1/A/G`2/O6;
distance hbond13, /3nd4_2/2/A/U`14/N3,/3nd4_1/1/A/A`3/N1;
distance hbond14,3nd4_2/2/A/U`14/O4,/3nd4_1/1/A/A`3/N6;
distance hbond15, /3nd4_2/2/A/C`13/N4,/3nd4_1/1/A/G`4/O6;
 distance hbond16,/3nd4_2/2/A/C`13/N3, /3nd4_1/1/A/G`4/N1;
distance hbond17, /3nd4_1/1/A/G`4/N2,/3nd4_2/2/A/C`13/O2;
distance hbond18,/3nd4_1/1/A/G`2/N2,/3nd4_2/2/A/C`15/O2;
distance hbond19,/3nd4_1/1/A/HOH`91/O,/3nd4_1/1/A/G`4/OP2;    
set depth_cue=0;
set ray_trace_fog=0;
set dash_color, black;
set label_font_id, 5;
set label_size, 36;
set label_position, (0.5, 1.0, 2.0);
set label_color, black;
set dash_gap, 0.2;
set dash_width, 2.0;
set dash_length, 0.2;
set label_color, black;
set dash_gap, 0.2;
set dash_width, 2.0;
set dash_length, 0.2;
select carbon, element C;
color yellow, carbon;
disable carbon;
set_view(-0.9,0.34,-0.26,0.33,0.18,-0.93,-0.27,-0.92,-0.28,-0.07,-0.23,-27.83,8.63,19.85,13.2,16.0,31.63,-20.0)

# Edit the selection that is named ligand here.;
create ligand, /bluComplex/C/A/1101;
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
set stick_radius, 0.1;
set sphere_quality, 4;
set cartoon_ring_finder, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.1, ligand;
set cartoon_ring_transparency, .0, ligand;
show cartoon, ligand;

set_color oxygen, [1.0,0.4,0.4];
set_color nitrogen, [0.5,0.5,1.0];
remove solvent;
as spheres;
util.cbaw;
bg white;
set light_count,10;
set spec_count,1;
set shininess, 10;
set specular,0.25;
set ambient,0;
set direct,0;
set reflect,1.5;
set ray_shadow_decay_factor, 0.1;
set ray_shadow_decay_range, 2;
set depth_cue, 0;
ray;

# Edit the selection that is named ligand here.;
create ligand, /bluComplex/C/A/1101;
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
set stick_radius, 0.12;
set sphere_quality, 4;
set cartoon_ring_fcribbon er, 4, ligand;
set cartoon_ring_mode, 3, ligand;
set cartoon_ring_width, 0.12, ligand;
set cartoon_ring_transparency, .0, ligand;
show cartoon, ligand;
preset.ball_and_stick(selection='SCS');
util.cbaw SCS;
set stick_color, green, SCS;
set valence, off, SCS;
unset valence;
# above command is required after using preset;
set sphere_color, black, elem C and SCS;
set sphere_color, red, elem O and SCS;
set sphere_color, blue, elem N and SCS;
set sphere_color, lightblue, elem F and SCS;
set stick_radius, 0.1;
set sphere_quality, 1;
set cartoon_ring_finder, 4, SCS;
set cartoon_ring_mode, 3, SCS;
set cartoon_ring_width, 0.1, SCS;
set cartoon_ring_transparency, .0, SCS;
show cartoon, SCS;

delete all;
fetch 4PCO, type=pdb,async=0;
select G2G3, ( ((resi 2 or resi 3) and chain A) or ((resi 8 or resi 9) and chain B) );
hide everything, element h; 
remove not G2G3;
bg_color white;
show sticks;
set stick_radius=0.14;
set stick_ball, on; 
set stick_ball_ratio,1.9;
set_view (-0.75,0.09,0.66,-0.2,0.92,-0.35,-0.64,-0.39,-0.67,-0.0,-0.0,-43.7,7. 24,9.55,11.78,29.46,57.91,-20.0);
hide everything, element H;
select carbon1, element C and (resi 3 or resi 8); 
# select lower base pair;
select carbon2, element C and (resi 2 or resi 9);
#select upper base pair;
color gray70,carbon1;
color gray10,carbon2;
space cmyk;
distance hbond1,/4PCO//B/U`9/N3,/4PCO//A/G`2/O6;
distance hbond2,/4PCO//B/U`9/O2,/4PCO//A/G`2/N1;
distance hbond3,/4PCO//A/U`3/N3,/4PCO//B/G`8/O6;
distance hbond4,/4PCO//A/U`3/O2,/4PCO//B/G`8/N1;
color black, hbond1;
color black, hbond2;
color gray70, hbond3;
color gray70, hbond4;
show nb_spheres;
set nb_spheres_size, 0.35;
hide labels;
ray 1600,1000;
png 4PCO.png

# Select polar atoms (e.g., N, O, F, etc.)
select polar_atoms1, SCS and (elem N+O+F)
select polar_atoms2, ligand and (elem N+O+F)

# Find and select polar contacts within 3.5 angstroms
find_pairs dist=3.5, selection1=polar_atoms1, selection2=polar_atoms2, mode=3, quiet=0

# Visualize polar contacts
dist polar_contacts, polar_atoms1, polar_atoms2, cutoff=3.5