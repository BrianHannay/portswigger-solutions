if [[ ${#1} -lt 32 ]]; then
	echo "USAGE: $0 url response"
	exit 1;
fi
url="$1";
response="$2";

echo "$response" | grep '< Set-Cookie: session=' | cut -d'=' -f2 | cut -d';' -f1