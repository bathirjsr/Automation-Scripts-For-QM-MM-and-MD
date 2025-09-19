#!/bin/bash
t2x coord > QM.xyz
for pltfile in *.cub; do
    # Extract the base name without the file extension
    basename=${pltfile%.cub}
cat > MO.pml << EOF
set_color oxygen, [1.0,0.4,0.4];
set_color nitrogen, [0.5,0.5,1.0];
hide solvent;
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
bg_color white;
ray;
hide everything;

load QM.xyz ;
hide everything;
show lines, QM ;
load ${basename}.cub ;
isosurface alpha, ${basename}, 0.1 ;
isosurface beta, ${basename}, -0.1 ;

bond /QM///UNK\`32/Fe, /QM///UNK\`4/N ;
bond /QM///UNK\`32/Fe, /QM///UNK\`24/N ;
bond /QM///UNK\`32/Fe, /QM///UNK\`35/O ;


color grey, alpha ;
color yellow, beta ;

set_view (\
     0.659150422,    0.727530718,   -0.190314546,\
     0.641766608,   -0.412292063,    0.646645784,\
     0.391989291,   -0.548374534,   -0.738667369,\
    -0.000021746,    0.000027839,  -42.153450012,\
    58.358215332,   47.535514832,   49.235328674,\
    34.304023743,   50.003025055,  -20.000000000 )
### cut above here and paste into script ###

ray 3000,3000 ;
png ${basename}.png ;
quit

EOF
    pymol MO.pml
done
