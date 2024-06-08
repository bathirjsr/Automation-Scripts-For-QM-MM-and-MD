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
mv ./*.plt MO/
cd MO || exit
cp ../coord .
for pltfile in *.plt; do
    # Extract the base name without the file extension
    basename=${pltfile%.plt}

    # Convert plt to cub using plt2cub.bin
    plt2cub.bin $pltfile > "${basename}.cub"

    echo "Converted $pltfile to ${basename}.cub"
done
