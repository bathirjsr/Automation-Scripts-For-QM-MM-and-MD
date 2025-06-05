#!/bin/bash
while getopts n:o:s: flag
do
     case "${flag}" in
        n) n=${OPTARG};;
        o) one=${OPTARG};;
        s) sn=${OPTARG};;
        *) echo "usage: $0 [-n number of atoms in QM] " >&2
      exit 1 ;;
     esac
done
i=1
for d in *_Opt
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} dirs in the current path"
home=$(pwd)
if [ -n "$one" ]; then
    if [ -d "$one" ]; then
        dir=$one
        echo "Found directory: $dir"
        cd "${dir}" || exit 
        mkdir SNO_Turbomole
        cd SNO_Turbomole || exit
        cp ../* .
        tm2molden << EOF
        SNO.input
        Y
        Y
EOF
        Multiwfn SNO.input << EOF
        100
        2
        7
        SNO.fch
        0
        q
EOF
        Multiwfn SNO.fch << EOF
        200
        16
        SCF
        3
        y
        3
        1-5,$sn
        2
        1
        0
        q
EOF
        t2x coord > QM.xyz
        cat pymol_SNO.py << EOF
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
        set sphere_scale, 0.2, active;
        set stick_radius, 0.1, active;
        show sticks
        show spheres
        load QM.xyz, QM
        load orb000001.cub, SNO_1
        load orb000002.cub, SNO_2
        load orb000003.cub, SNO_3
        load orb000004.cub, SNO_4
        load orb000005.cub, SNO_5
        load orb000644.cub, SNO_6
        isosurface SNO_1_a, SNO_1, 0.1, transparency=0.5
        isosurface SNO_1_b, SNO_1, -0.1, transparency=0.5
        isosurface SNO_2_a, SNO_2, 0.1, transparency=0.5
        isosurface SNO_2_b, SNO_2, -0.1, transparency=0.5
        isosurface SNO_3_a, SNO_3, 0.1, transparency=0.5
        isosurface SNO_3_b, SNO_3, -0.1, transparency=0.5
        isosurface SNO_4_a, SNO_4, 0.1, transparency=0.5
        isosurface SNO_4_b, SNO_4, -0.1, transparency=0.5
        isosurface SNO_5_a, SNO_5, 0.1, transparency=0.5
        isosurface SNO_5_b, SNO_5, -0.1, transparency=0.5
        isosurface SNO_6_a, SNO_6, 0.1, transparency=0.5
        isosurface SNO_6_b, SNO_6, -0.1, transparency=0.5

EOF
    fi
else
for((i=1;i<=${#dirs[@]};i++))
do
    cd "${dirs[i]}" || exit 
    mkdir SNO_Turbomole
    cd SNO_Turbomole || exit
    cp ../alpha .
    sed '1,3d' alpha | sed '$d' > tmp_alpha
    echo "" >> tmp_alpha
    printf '%s\n' "(4d20.14)" | cat - tmp_alpha > alpha_edit
    cp ../beta .
    sed '1,3d' beta | sed '$d' > beta_edit
    echo "" >> beta_edit
    cp ../hybrid.turbomole.coords .
    #######################Change sed number here to total number of atoms###############
    sed '1,4d' hybrid.turbomole.coords | sed -n "1,${n} p" | awk '{printf "%2s%16f%14f%14f\n", $1,$2*0.529177249,$3*0.529177249,$4*0.529177249}' > inpcrd
    echo "" >> inpcrd

    ####################Change Charge and Multiplicity here#################
cat > Gauss_code.txt << EOF
%nproc=12
%mem=2gb
%chk=NO
#ub3lyp/def2svp guess=(only,cards) gfinput gfoldprint pop=NaturalOrbitals iop(2/11=1)

MOs

0   5
EOF
    cat Gauss_code.txt inpcrd alpha_edit beta_edit > NO.com
    nohup g16 < NO.com > NO.log
    cp NO.com SNO.com
    cp NO.chk SNO.chk
    sed -i 's/NO/SNO/g;s/NaturalOrbitals/SpinNatural/g' SNO.com
    nohup g16 < SNO.com > SNO.log
    grep 'Eigenvalues' NO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > NO_Occupancy.dat
    grep 'Eigenvalues' SNO.log |awk '{ if (NF==7) print $(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==6) print $(NF-3),$(NF-2),$(NF-1),$NF; else if (NF==5) print $(NF-2),$(NF-1),$NF; else if (NF==4) print $(NF-1),$NF; else if (NF==3) print $NF}' | awk '{ for(i=1;i<=NF;i++) print $i; }' | awk '{print NR,$0}' > SNO_Occupancy.dat
cd "$home" || exit
done
fi