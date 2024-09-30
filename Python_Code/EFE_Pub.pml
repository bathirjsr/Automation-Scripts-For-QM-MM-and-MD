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
set_color color1, [214, 206, 147]
set_color color2, [239, 235, 206]
set_color color3, [216, 164, 143]
set_color color4, [187, 133, 136]
set_color SCS, [29, 43, 35]
bond resname FE1, resname AP1 and name O1;
bond resname FE1, resname OY1 and name O1;
bond resname FE1, resname AG1 and name O1;
# bond resname FE1, resname AG1 and name O5;
bond resname FE1, resname HD1 and name NE2;
bond resname FE1, resname HD2 and name NE2;

# Edit the selection that is named ligand here.;
select ligand, resname FE1+OY1+HD1+HD2+AP1+AG1+ADG;
set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
show sticks, ligand;    
show spheres, ligand;
color color4, ligand
hide everything, (elem H and not (neighbor elem N+O+F))
select substrate, resname AG1;
set sphere_scale, 0.15, substrate;
set stick_radius, 0.05, substrate;
show sticks, substrate;    
show spheres, substrate;
color color4, substrate
select mutant,resid 171+84;
#select mutant,resid 198+173+186+277;
set sphere_scale, 0.15, mutant;
set stick_radius, 0.05, mutant;
show sticks, mutant;    
show spheres, mutant;
color SCS, mutant

cmd.set('ray_trace_mode', 1)
cmd.set('label_size', 18);
cmd.set('label_distance_digits', 2);
set label_size, 18;
set ray_trace_mode, 1
set label_distance_digits, 2;
# util.cba(20,"all",_self=cmd)
# Edit the name for the ditance, the selection criteria for atom 1, and the selection criteria for atom 2.;
# distance Op-Od, resname OY1 and name O1, resname OY1 and name O2;
# distance Od-C1, resname OY1 and name O1, resname AG1 and name C1;
# distance Od-C2, resname OY1 and name O2, resname AG1 and name C2;
# distance C1-C2, resname AG1 and name C1, resname AG1 and name C2;

# set_view (\
#      0.881057441,   -0.377248317,    0.285336554,\
#      0.140230864,    0.784443974,    0.604129970,\
#     -0.451738268,   -0.492262661,    0.744042575,\
#      0.000026004,   -0.000045376,  -58.860935211,\
#     36.605026245,   33.335952759,   28.217453003,\
#     12.095874786,  105.597991943,  -20.000000000 )

# set_view (\
#     -0.564175487,   -0.667428851,    0.486046940,\
#      0.331022352,    0.356451452,    0.873704135,\
#     -0.756388843,    0.653814793,    0.019832276,\
#      0.000042114,   -0.000192702,  -45.779201508,\
#     37.403354645,   31.536628723,   29.700807571,\
#     -0.976287842,   92.525848389,  -20.000000000 )
# /GIT/Bathir-s-PHD/Python_Code/EFE_Pub.pml
util.cnc("all",_self=cmd)
set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
set_view (\
    -0.442739934,    0.678269565,    0.586454034,\
     0.448561877,   -0.398776978,    0.799846649,\
     0.776376605,    0.617189169,   -0.127691895,\
    -0.000496496,   -0.000044974,  -42.715820312,\
    33.477523804,   32.973075867,   31.773399353,\
    -4.040980339,   89.461151123,  -20.000000000 )

    
set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
set_view (\
    -0.600393414,   -0.183592260,   -0.778342783,\
    -0.789617717,    0.290185869,    0.540642023,\
     0.126605064,    0.939193189,   -0.319194078,\
     0.000057578,   -0.000049323,  -45.774826050,\
    45.426643372,   34.651290894,   32.545803070,\
    -0.976287842,   92.525848389,  -20.000000000 )

set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
set_view (\
     0.808889449,   -0.219957337,   -0.545254409,\
    -0.029711569,    0.910897911,   -0.411535949,\
     0.587196887,    0.349090368,    0.730284512,\
    -0.000316434,   -0.000621893,  -45.210735321,\
    38.435756683,   32.183849335,   31.165201187,\
    -1.544848680,   91.957298279,  -20.000000000 )


set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
set_view (\
    -0.177861780,    0.983633876,   -0.028749384,\
    -0.226282060,   -0.069314688,   -0.971587837,\
    -0.957683027,   -0.166303560,    0.234905630,\
     0.000303861,   -0.000132287,  -50.125015259,\
    33.727935791,   46.486312866,   39.906391144,\
     3.273229599,   96.986213684,  -20.000000000 )

set sphere_scale, 0.15, ligand;
set stick_radius, 0.05, ligand;
set_view (\
    -0.765524745,    0.625551999,    0.150499001,\
     0.421918541,    0.311481088,    0.851442993,\
     0.485746264,    0.715300679,   -0.502380013,\
    -0.000121512,   -0.000551250,  -45.652069092,\
    35.438755035,   33.767082214,   38.520996094,\
    -1.201806903,   92.511184692,  -20.000000000 )

wizard measurement;

set_view (\
     0.385858864,    0.461182177,    0.799010873,\
     0.796854198,   -0.603049994,   -0.036744937,\
     0.464898974,    0.650874615,   -0.600188255,\
    -0.000256717,   -0.000053182,  -67.677345276,\
    46.294128418,   35.603355408,   35.314426422,\
    51.190029144,   84.163940430,  -20.000000000 )
    
wizard label;