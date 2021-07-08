#!/bin/bash
while getopts s: flag
do
    case "${flag}" in
	  s) step=${OPTARG};;
    *) echo "usage: $0 [-s] " >&2
       exit 1 ;;
esac
done

if [ "$step" = "0" ]; then
eiger -a > MOs.txt
proper <<EOF
grid
mo 1-280
q
EOF

echo "Completed generating plt files"
echo "Converting plt to cube files"
mkdir plt-cube-files
cp MOs.txt plt-cube-files/.
mv ./*plt plt-cube-files/
mv plt2cub.bin plt-cube-files/
cd plt-cube-files || exit
cp ../../coord .

elif [ "$step" = "1" ]; then
for i in {1..137}
do
  ./plt2cub.bin "${i}"a_a.plt > "${i}"a_a.cube
done

for i in {133..137}
do
  ./plt2cub.bin "${i}"a_b.plt > "${i}"a_b.cube
done

elif [ "$step" = "2" ]; then

for i in {137..1}
do
  Chemcraft "${i}"a_a.cube
done

fi
