#! /bin/bash

cat > Visual.dat << EOF
mol new ${prmtop}
mol addfile ${pdb}
mol delrep 0 top
mol selection resname FE1 OY1 HD1 HD2 SC1 GU1
mol representation CPK
mol addrep top
mol selection resid ${i}
mol representation CPK
mol addrep top
mol selection resid ${cor}
mol color ColorID 0
mol representation NewCartoon
mol addrep top
mol selection resid ${acor}
mol color ColorID 1
mol representation NewCartoon
mol addrep top
mol selection not resid ${all}
mol color Name
mol representation NewCartoon
mol addrep top
set viewpoints([molinfo top]) {{{1 0 0 9.74519} {0 1 0 -2.52271} {0 0 1 11.0417} {0 0 0 1}} {{-0.712001 -0.693475 -0.110206 0} {0.2181 -0.367596 0.904049 0} {-0.667447 0.619648 0.412976 0} {0 0 0 1}} {{0.0450694 0 0 0} {0 0.0450694 0 0} {0 0 0.0450694 0} {0 0 0 1}} {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}}}
lappend viewplist [molinfo top]
set topmol [molinfo top]
# done with molecule 0
foreach v \$viewplist {
  molinfo \$v set {center_matrix rotate_matrix scale_matrix global_matrix} \$viewpoints(\$v)
}
light 3 on
render TachyonLOptiXInternal DCCA_${i}.png
EOF