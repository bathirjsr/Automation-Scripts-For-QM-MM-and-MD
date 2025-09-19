#!/bin/bash
eiger > MOs.txt
less MOs.txt 
read -p "Enter MO range:" mo
proper <<EOF
grid
mo $mo
q
EOF

echo "Completed generating plt files"
echo "Converting plt to cube files"
mkdir MO
cp MOs.txt MO/.
t2x coord > MO/QM.xyz
mv ./*.plt MO/
cd MO || exit
pymol QM.xyz
read -p "Paste View:" view
cp ../coord .
for pltfile in *.plt; do
    # Extract the base name without the file extension
    basename=${pltfile%.plt}

    # Convert plt to cub using plt2cub.bin
    plt2cub.bin $pltfile > "${basename}.cub"
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
bond /QM///UNK\`24/Fe, /QM///UNK\`4/N ;
bond /QM///UNK\`24/Fe, /QM///UNK\`15/N ;
bond /QM///UNK\`24/Fe, /QM///UNK\`23/Cl ;
bond /QM///UNK\`24/Fe, /QM///UNK\`25/O ;
bond /QM///UNK\`24/Fe, /QM///UNK\`28/0 ;

show lines, QM ;
load ${basename}.cub ;
isosurface alpha, ${basename}, 0.1 ;
isosurface beta, ${basename}, -0.1 ;




color grey, alpha ;
color yellow, beta ;

$view

ray 3000,3000 ;
png ${basename}.png ;
quit

EOF
    pymol MO.pml
    echo "Converted $pltfile to ${basename}.cub"
done
