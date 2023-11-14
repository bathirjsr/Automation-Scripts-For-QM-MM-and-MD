#! /bin/bash

if [ "$1" = "chemsh.x" ]; then
sum=0  
for dir in $(pwdx $(pidof chemsh.x) | awk '{print $NF}'); do
    file="$dir/input.in"
    if [ -e "$file" ]; then
        line=$(grep "nodes" "$file")
        if [ -n "$line" ]; then
            echo "In directory $dir:"
            echo "$line"
            sum=$((sum + line))
        fi
    fi
done
echo "Total CPUs used by $1: $sum"
fi