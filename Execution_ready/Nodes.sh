#! /bin/bash

if [ "$1" = "chemsh.x" ]; then
for dir in $(pwdx $(pidof chemsh.x) | awk '{print $NF}'); do
    file="$dir/input.in"
    if [ -e "$file" ]; then
        line=$(grep "nodes" "$file")
        if [ -n "$line" ]; then
            echo "In directory $dir:"
            echo "$line"
        fi
    fi
done
fi