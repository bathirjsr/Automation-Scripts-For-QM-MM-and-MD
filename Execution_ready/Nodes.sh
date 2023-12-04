#! /bin/bash

if [ "$1" = "chemsh.x" ]; then
sum=0  
for dir in $(pwdx $(pidof chemsh.x) | awk '{print $NF}'); do
    file="$dir/input.in"
    file2="$dir/dscf.log"
    if [ -e "$file" ]; then
        line=$(grep "nodes" "$file")
        check=$(tail -2 $file2)
        if [ -n "$line" ]; then
            echo "In directory $dir:"
            echo "$line"
            echo "$check"
            sum=$((sum + line))
        fi
    fi
done
echo "Total CPUs used by $1: $sum"
fi