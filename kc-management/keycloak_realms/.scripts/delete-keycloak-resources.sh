#!/usr/bin/env bash

# Generic helper to delete arbitrary resources through the Keycloak Admin REST API.
#
# Environment:
#   KEYCLOAK_TOKEN   (required) Bearer token of the admin client.
#   DELETE_REQUESTS  (optional) One request per line. If empty, nothing is done. Format: <url>[<TAB><json-body>]
#                    The optional JSON body is needed for endpoints like
#                    DELETE .../role-mappings/clients/<id> that expect the items to remove.
#                    Empty lines are ignored.
#   INSECURE         (optional) "true" disables TLS certificate verification.
#   HTTP_METHOD      (optional) HTTP method to use, defaults to DELETE.
#   MAX_ATTEMPTS     (optional) Attempts per request on transient errors, defaults to 5.
#
# A 404 counts as success (resource is already gone). Failing requests do not stop
# the run; the script exits with 1 after processing all requests if any of them failed.

set -euo pipefail

: "${KEYCLOAK_TOKEN:?KEYCLOAK_TOKEN must be set}"
DELETE_REQUESTS="${DELETE_REQUESTS:-}"

if [[ -z "${DELETE_REQUESTS//[[:space:]]/}" ]]; then
	echo "Nothing to delete."
	exit 0
fi

method="${HTTP_METHOD:-DELETE}"
max_attempts="${MAX_ATTEMPTS:-5}"

curl_opts=(--silent --show-error --max-time 30 --request "$method" --output /dev/null --write-out '%{http_code}')
if [[ "${INSECURE:-false}" == "true" ]]; then
	curl_opts+=(--insecure)
fi

# The token is passed via a curl config on stdin to keep it out of the process list.
auth_config() {
	printf 'header = "Authorization: Bearer %s"\n' "$KEYCLOAK_TOKEN"
}

send_request() {
	local url="$1" body="$2"
	local args=("${curl_opts[@]}" --config -)
	if [[ -n "$body" ]]; then
		args+=(--header 'Content-Type: application/json' --data "$body")
	fi
	auth_config | curl "${args[@]}" "$url" 2>&1 || true
}

failed=0
total=0

while IFS= read -r line || [[ -n "$line" ]]; do
	line="${line%$'\r'}"
	[[ -z "${line// /}" ]] && continue
	total=$((total + 1))

	url="${line%%$'\t'*}"
	body=""
	if [[ "$line" == *$'\t'* ]]; then
		body="${line#*$'\t'}"
	fi

	for ((attempt = 1; attempt <= max_attempts; attempt++)); do
		result="$(send_request "$url" "$body")"
		status="${result: -3}"

		case "$status" in
			2??)
				echo "Deleted: $url ${body}"
				break
				;;
			404)
				echo "Already gone: $url"
				break
				;;
			4??)
				echo "ERROR: $method $url failed with HTTP $status" >&2
				failed=$((failed + 1))
				break
				;;
			*)
				if ((attempt == max_attempts)); then
					echo "ERROR: $method $url failed after ${max_attempts} attempts: $result" >&2
					failed=$((failed + 1))
				else
					sleep "$attempt"
				fi
				;;
		esac
	done
done <<<"$DELETE_REQUESTS"

echo "Processed ${total} request(s), ${failed} failed."
((failed == 0))
