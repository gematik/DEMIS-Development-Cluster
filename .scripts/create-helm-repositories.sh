#!/usr/bin/env bash
# Creates a Helm repositories.yaml with all repositories required for helm_repository_source = "local".
# If the file already exists, missing repositories are added and existing entries with the same name are
# adjusted to the settings of helm-repositories.yaml, the credential data (username, password, caFile, certFile, keyFile) is kept.
# Before any change, a backup of the file is created, the last MAX_BACKUPS backups are kept.
set -euo pipefail

red='\033[0;31m' # Red
green='\033[0;32m' # Green
yellow='\033[0;33m' # Yellow
nc='\033[0m' # No Color

MAX_BACKUPS=5

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# Public repositories (published) and additional internal repositories (optional, not published)
REPOSITORIES_FILE="$root_dir/.scripts/helm-repositories.yaml"
ADDITIONAL_REPOSITORIES_FILE="$root_dir/deployments/local/helm-repositories.yaml"

# Reads the repositories of a file as name|url|requires credentials
function readRepositories() {
  yq '.repositories[] | .name + "|" + .url + "|" + ((.credentials // false) | tostring)' "$1"
}

# The repositories are identified by name: an additional entry replaces the public entry with the same name,
# additional entries with a new name are put in front
REPOSITORIES=()
if [ -f "$REPOSITORIES_FILE" ]; then
  while IFS= read -r line; do
    REPOSITORIES+=("$line")
  done < <(readRepositories "$REPOSITORIES_FILE")
fi
if [ -f "$ADDITIONAL_REPOSITORIES_FILE" ]; then
  new_repositories=()
  while IFS= read -r line; do
    replaced=false
    for i in "${!REPOSITORIES[@]}"; do
      if [ "${REPOSITORIES[$i]%%|*}" == "${line%%|*}" ]; then
        REPOSITORIES[i]=$line
        replaced=true
      fi
    done
    if [ "$replaced" == "false" ]; then
      new_repositories+=("$line")
    fi
  done < <(readRepositories "$ADDITIONAL_REPOSITORIES_FILE")
  REPOSITORIES=("${new_repositories[@]}" "${REPOSITORIES[@]}")
fi
if [ ${#REPOSITORIES[@]} -eq 0 ]; then
  echo -e "${red}No repositories found in $REPOSITORIES_FILE${nc}"
  exit 1
fi

function printUsage() {
  echo "Usage:"
  echo " $0 [-o <path>]"
  echo "  creates a Helm repositories.yaml with all repositories used by the cluster deployment,"
  echo "  or synchronizes an existing file: missing repositories are added, existing entries are adjusted"
  echo "  (except the credential data username, password, caFile, certFile and keyFile)"
  echo "Options:"
  echo "  -o <path>   target file (default: helm env HELM_REPOSITORY_CONFIG)"
  echo "Repositories are read from .scripts/helm-repositories.yaml and, if it exists,"
  echo "deployments/local/helm-repositories.yaml."
  echo "Credentials for repositories with 'credentials: true' are read from HELM_<NAME>_USERNAME and"
  echo "HELM_<NAME>_PASSWORD (name in upper case, '-' and '.' replaced by '_', e.g. HELM_DEMIS_USERNAME),"
  echo "otherwise they are prompted."
}

# Quote a value as single-quoted YAML scalar
function yamlQuote() {
  printf "'%s'" "${1//\'/\'\'}"
}

function writeRepositories() {
  local entry name url needs_credentials entry_username entry_password

  echo 'apiVersion: ""'
  echo "generated: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
  echo "repositories:"
  for entry in "${REPOSITORIES[@]}"; do
    IFS='|' read -r name url needs_credentials <<< "$entry"
    entry_username=""
    entry_password=""
    if [ "$needs_credentials" == "true" ]; then
      entry_username=${CREDENTIAL_USERNAMES[$name]}
      entry_password=${CREDENTIAL_PASSWORDS[$name]}
    fi
    echo "- name: $name"
    echo "  url: $url"
    echo "  username: $(yamlQuote "$entry_username")"
    echo "  password: $(yamlQuote "$entry_password")"
    echo '  caFile: ""'
    echo '  certFile: ""'
    echo '  keyFile: ""'
    echo "  insecure_skip_tls_verify: false"
    echo "  pass_credentials_all: false"
  done
}

# Helm resolves HELM_REPOSITORY_CONFIG, XDG_CONFIG_HOME and the OS specific default
default_target=$(helm env HELM_REPOSITORY_CONFIG)
target=$default_target
while getopts "o:h" opt; do
  case $opt in
    o) target=$OPTARG ;;
    h) printUsage; exit 0 ;;
    *) printUsage; exit 1 ;;
  esac
done

# Reads the credentials of a repository from HELM_<NAME>_USERNAME / HELM_<NAME>_PASSWORD or prompts for them
function readCredentials() {
  local name=$1
  local prefix user_var password_var
  prefix="HELM_$(tr '[:lower:]-.' '[:upper:]__' <<< "$name")"
  user_var="${prefix}_USERNAME"
  password_var="${prefix}_PASSWORD"
  username="${!user_var:-}"
  password="${!password_var:-}"
  if [ -z "$username" ]; then
    read -rp "Username for the Helm repository $name: " username
  fi
  if [ -z "$password" ]; then
    read -rsp "Password for the Helm repository $name: " password
    echo
  fi
}

# Keeps only the newest MAX_BACKUPS backups of the target file (timestamps sort chronologically)
function rotateBackups() {
  local backups=("$target".bak-*)
  local count=${#backups[@]}
  if [ -e "${backups[0]}" ] && [ "$count" -gt "$MAX_BACKUPS" ]; then
    rm -f "${backups[@]:0:count-MAX_BACKUPS}"
  fi
}

# Settings enforced on existing entries, the credential data (username, password, caFile, certFile, keyFile) is kept
ENTRY_SETTINGS='.url = strenv(URL) | .insecure_skip_tls_verify = false | .pass_credentials_all = false'

# Synchronizes an existing file: adjusts existing entries and adds the missing repositories
function syncRepositories() {
  local existing missing=() adjusted=() changed_urls=() entry name url needs_credentials before backup

  existing=$(yq '.repositories[].name' "$target")
  # global, the EXIT trap runs after the function has returned
  work_file=$(mktemp "$(dirname "$target")/.repositories.XXXXXX")
  trap 'rm -f "${work_file:-}"' EXIT
  cp -p "$target" "$work_file"

  for entry in "${REPOSITORIES[@]}"; do
    IFS='|' read -r name url needs_credentials <<< "$entry"
    if ! grep -qx -- "$name" <<< "$existing"; then
      missing+=("$entry")
      continue
    fi
    before=$(NAME="$name" yq -o=json '.repositories[] | select(.name == strenv(NAME))' "$work_file")
    if [ "$(NAME="$name" yq '.repositories[] | select(.name == strenv(NAME)) | .url' "$work_file")" != "$url" ]; then
      changed_urls+=("$name")
    fi
    NAME="$name" URL="$url" yq -i "(.repositories[] | select(.name == strenv(NAME))) |= ($ENTRY_SETTINGS)" "$work_file"
    if [ "$before" != "$(NAME="$name" yq -o=json '.repositories[] | select(.name == strenv(NAME))' "$work_file")" ]; then
      adjusted+=("$name")
    fi
  done

  if [ ${#missing[@]} -eq 0 ] && [ ${#adjusted[@]} -eq 0 ]; then
    echo -e "${green}All repositories in $target are up to date, nothing was changed.${nc}"
    return
  fi

  backup="$target.bak-$(date +%Y%m%d%H%M%S)"
  cp -p "$target" "$backup"
  echo "Backup created: $backup"
  rotateBackups

  if [ ${#adjusted[@]} -gt 0 ]; then
    mv -f "$work_file" "$target"
    echo -e "${green}Adjusted in $target: ${adjusted[*]}${nc}"
  fi

  for entry in "${missing[@]}"; do
    IFS='|' read -r name url needs_credentials <<< "$entry"
    if [ "$needs_credentials" == "true" ]; then
      readCredentials "$name"
      added=$(HELM_REPOSITORY_CONFIG="$target" helm repo add "$name" "$url" --username "$username" --password-stdin <<< "$password" 2>&1) || added="FAILED: $added"
    else
      added=$(HELM_REPOSITORY_CONFIG="$target" helm repo add "$name" "$url" 2>&1) || added="FAILED: $added"
    fi
    echo "$added"
    if [[ "$added" == FAILED:* ]]; then
      echo -e "${red}Adding $name failed, the original file is available as backup: $backup${nc}"
      exit 1
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${green}Added to $target: $(for entry in "${missing[@]}"; do printf '%s ' "${entry%%|*}"; done)${nc}"
  fi

  # The cached index of a repository with a changed URL is outdated
  if [ ${#changed_urls[@]} -gt 0 ]; then
    if ! HELM_REPOSITORY_CONFIG="$target" helm repo update "${changed_urls[@]}"; then
      echo -e "${yellow}Updating the index of ${changed_urls[*]} failed, run 'helm repo update' manually.${nc}"
    fi
  fi
}

if [ -e "$target" ]; then
  syncRepositories
  exit 0
fi

declare -A CREDENTIAL_USERNAMES CREDENTIAL_PASSWORDS
for entry in "${REPOSITORIES[@]}"; do
  IFS='|' read -r name url needs_credentials <<< "$entry"
  if [ "$needs_credentials" == "true" ]; then
    readCredentials "$name"
    CREDENTIAL_USERNAMES[$name]=$username
    CREDENTIAL_PASSWORDS[$name]=$password
  fi
done

target_dir=$(dirname "$target")
mkdir -p "$target_dir"
tmp_file=$(mktemp "$target_dir/.repositories.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT
chmod 600 "$tmp_file"
writeRepositories > "$tmp_file"

# Hard link fails if the target was created in the meantime, so an existing file is never overwritten
if ! ln "$tmp_file" "$target" 2>/dev/null; then
  echo -e "${red}$target could not be created (already exists?), nothing was changed.${nc}"
  exit 1
fi

echo -e "${green}Created $target${nc}"
if [ "$target" != "$default_target" ]; then
  echo -e "${yellow}Run: export HELM_REPOSITORY_CONFIG=$target${nc}"
fi
echo "Run 'helm repo update' to fill the index cache."
