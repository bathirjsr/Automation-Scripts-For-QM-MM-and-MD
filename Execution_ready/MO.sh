#!/bin/bash
eiger -a > MOs.txt
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
mv ./*.plt MO/
mv plt2cub.bin MO/
cd MO || exit
cp ../coord .
