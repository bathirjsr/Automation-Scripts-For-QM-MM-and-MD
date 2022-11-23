#! /bin/bash

read -re -p "To: " target 
read -re -p "Subject:" subject
read -re -p "Content:" content
read -re -p "Attachment(s):" attachment

echo "$content" | mail -s "${subject}" -a $attachment $target