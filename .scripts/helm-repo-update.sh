#!/usr/bin/env bash
# Updates the Helm repository indexes if the chart versions may have changed since the last update.
# The fingerprint consists of the stage commit, the uncommitted changes of the stage and the commit
# of this repository (infrastructure chart versions are partly defined as defaults here).
# Nothing is updated if neither demis nor demis-public is configured in the Helm repositories.yaml.
# Usage: helm-repo-update.sh <stage-folder>
set -euo pipefail

stage_dir=${1:?Usage: ${BASH_SOURCE[0]} <stage-folder>}
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

repos=$(helm repo list 2>/dev/null | tail -n +2 | awk '{print $1}' || true)
# Without a DEMIS repository the Helm repositories.yaml is not used for this project (helm_repository_source = "url")
if ! grep -qx -e demis -e demis-public <<< "$repos"; then
  echo "## Skipping Helm repository update (neither demis nor demis-public is configured)"
  exit 0
fi

cache_dir=$(helm env HELM_REPOSITORY_CACHE)
# The fingerprint is project specific and therefore not stored in the global Helm cache.
# It is kept per stage and per Helm cache, so switching HELM_REPOSITORY_CACHE triggers an update.
state_dir=/tmp/cluster-deployment/.cache/helm-repo-update
mkdir -p "$state_dir"
marker_file="$state_dir/$(basename "$stage_dir")-$(echo "$cache_dir" | sha256sum | cut -c1-12).fingerprint"

function fingerprint() {
  git -C "$stage_dir" rev-parse HEAD
  git -C "$stage_dir" diff HEAD
  git -C "$root_dir" rev-parse HEAD
}

if ! current=$(fingerprint 2>/dev/null | sha256sum | cut -d' ' -f1); then
  current=""
fi

# Repositories without a cached index (e.g. newly added) always require an update
missing_index=false
for repo in $repos; do
  if [ ! -f "$cache_dir/$repo-index.yaml" ]; then
    missing_index=true
  fi
done

if [ -n "$current" ] && [ "$missing_index" == "false" ] && [ -f "$marker_file" ] && [ "$(cat "$marker_file")" == "$current" ]; then
  echo "## Helm Repository indexes are up to date (stage unchanged)"
  exit 0
fi

echo "## Updating Helm Repositories"
helm repo update
if [ -n "$current" ]; then
  echo "$current" > "$marker_file"
fi
