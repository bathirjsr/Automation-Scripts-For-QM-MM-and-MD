#! /bin/bash
echo "Favorites: simahjsr@gmail.com mgeorget@mtu.edu sdevadas@mtu.edu bvarada@mtu.edu"
read -re -p "To: " target 
read -re -p "Subject:" subject
read -re -p "Content:" content
read -re -p "Attachment(s):" attachment

declare -a attach
i=1
for d in $attachment
do
    attach[i++]="-a ${d%/}"
done
echo ${attach[*]}

echo "$content" | mail -s "${subject}"  ${attach[*]} "$target"
echo "Mail Sent"