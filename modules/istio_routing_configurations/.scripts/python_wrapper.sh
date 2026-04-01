#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
module_dir="$(cd -- "${script_dir}/.." && pwd -P)"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <python-interpreter> <script> [args...]" >&2
  exit 1
fi

requested_python="$1"
shift

if ! command -v "$requested_python" >/dev/null 2>&1; then
  echo "Error: ${requested_python} is not installed or not on PATH."
  exit 1
fi

python_bin="$(command -v "$requested_python")"
requested_python_name="$(basename "$python_bin")"
if ! "$python_bin" -m venv --help >/dev/null 2>&1; then
  echo "Error: python3-venv is not installed for ${requested_python}. Please install the matching venv package."
  exit 1
fi

readonly requirements=(
  "jsonschema==4.26.0"
  "pyyaml==6.0.3"
)
readonly requirements_key="$(printf '%s\n' "${requirements[@]}")"
readonly import_check='import jsonschema, yaml'

cache_root="${DEMIS_VALIDATION_CACHE_DIR:-/tmp/cluster-deployment/.cache/istio-routing-validation}"
mkdir -p "$cache_root"

cache_key="$(DEMIS_VALIDATION_REQUIREMENTS="$requirements_key" "$python_bin" - <<'PY'
import hashlib
import os
import sys

payload = "\n".join([
    os.path.realpath(sys.executable),
    sys.version.split()[0],
    os.environ["DEMIS_VALIDATION_REQUIREMENTS"],
])
print(hashlib.sha256(payload.encode()).hexdigest()[:16])
PY
)"

venv_dir="${cache_root}/${cache_key}"
venv_python=""
stamp_file="${venv_dir}/.deps-ready"
lock_file="${venv_dir}.lock"

resolve_venv_python() {
  local candidate
  for candidate in \
    "${venv_dir}/bin/${requested_python_name}" \
    "${venv_dir}/bin/python3" \
    "${venv_dir}/bin/python"
  do
    if [[ -x "$candidate" ]]; then
      venv_python="$candidate"
      return 0
    fi
  done

  echo "Error: could not resolve a Python executable inside ${venv_dir}." >&2
  exit 1
}

ensure_environment() {
  if [[ ! -x "${venv_dir}/bin/${requested_python_name}" ]] \
    && [[ ! -x "${venv_dir}/bin/python3" ]] \
    && [[ ! -x "${venv_dir}/bin/python" ]]; then
    "$python_bin" -m venv "$venv_dir"
  fi

  resolve_venv_python

  if [[ ! -f "$stamp_file" ]] \
    || ! cmp -s "$stamp_file" <(printf '%s\n' "${requirements[@]}") \
    || ! "$venv_python" -c "$import_check" >/dev/null 2>&1; then
    "$venv_python" -m pip install --disable-pip-version-check --quiet "${requirements[@]}"
    "$venv_python" -c "$import_check" >/dev/null
    printf '%s\n' "${requirements[@]}" > "$stamp_file"
  fi
}

if command -v flock >/dev/null 2>&1; then
  exec 9>"$lock_file"
  flock 9
fi

ensure_environment

exec "$venv_python" "$@"
