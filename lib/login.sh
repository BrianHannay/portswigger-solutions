if [[ ${#1} -lt 32 ]]; then
	echo "USAGE: $0 url username password"
	exit 1;
fi
url="$1"
username="$2";
password="$3";
csrfResponse=$(curl -v -sG "$url/login" 2>&1);
csrf=$(
  echo "$csrfResponse" |
  grep csrf |
  grep -Eo 'value=".+?"' |
  cut -d'"' -f2
);
currentDir="$(dirname "$0")"
session=$($currentDir/session.sh "$url" "$csrfResponse");
redirectResponse=$(
  curl -v "$url/login" \
  --cookie "session=$session;" \
  --data-raw "csrf=$csrf&username=$username&password=$password" 2>&1
);
if echo "$redirectResponse" | grep "class=is-warning" > /dev/null; then
  echo "$redirectResponse" | grep "class=is-warning" | cut -d'>' -f2 | cut -d'<' -f1;
  exit 1;
fi;
session=$($currentDir/session.sh "$url" "$redirectResponse");
curl -s "$url/my-account" \
  --cookie "session=$session;" | grep 'Your username is'