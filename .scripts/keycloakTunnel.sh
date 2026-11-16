#!/usr/bin/env bash

# Manages a local port-forward to the Keycloak service in Kubernetes.
# Supports starting and stopping the tunnel, as well as executing commands
# while ensuring that the tunnel is available.
#
# The tunnel provides local access to the Keycloak administrative interface
# when the service is not directly reachable via normal network routes.

set -euo pipefail

namespace="${KEYCLOAK_TUNNEL_NAMESPACE:-idm}"
service="${KEYCLOAK_TUNNEL_SERVICE:-keycloak}"
local_port="${KEYCLOAK_TUNNEL_LOCAL_PORT:-43434}"
service_port="${KEYCLOAK_TUNNEL_SERVICE_PORT:-8080}"
health_url="${KEYCLOAK_TUNNEL_HEALTH_URL:-http://127.0.0.1:${local_port}/realms/master/.well-known/openid-configuration}"
pid_file="${KEYCLOAK_TUNNEL_PID_FILE:-/tmp/keycloak-port-forward.pid}"
startup_timeout="${KEYCLOAK_TUNNEL_STARTUP_TIMEOUT:-10}"
log_file="${KEYCLOAK_TUNNEL_LOG_FILE:-/tmp/keycloak-port-forward.log}"
tunnel_started_by_script=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_ready() {
	curl --silent --fail --max-time 2 "$health_url" >/dev/null 2>&1
}

# Liveness check for the child started by this script. It must not inspect the
# command line: right after "&" the forked shell has not exec'd kubectl yet, so
# a command line match would wrongly report the process as dead (race condition).
is_alive() {
	kill -0 "$1" 2>/dev/null
}

# Check for a PID read from the PID file, which may be stale or reused.
is_port_forward() {
	local pid="$1"
	is_alive "$pid" || return 1
	[[ "$(ps -p "$pid" -o args= 2>/dev/null)" == *"kubectl"*"port-forward"* ]]
}

stop_owned_tunnel() {
    echo "Stopping Keycloak port-forward if running."
	if [[ -f "$pid_file" ]]; then
		local pid
		pid="$(cat "$pid_file")"
		if is_port_forward "$pid"; then
			kill "$pid" 2>/dev/null || true
		fi
		rm -f "$pid_file"
	fi
}

ensure_tunnel() {
	if is_ready; then
		echo "Using existing Keycloak port-forward on localhost:${local_port}."
		return
	fi

	stop_owned_tunnel

	if [[ -f "$SCRIPT_DIR/../infrastructure/kind-config" ]]; then
		export KUBECONFIG="$SCRIPT_DIR/../infrastructure/kind-config"
	fi

	echo "Starting Keycloak port-forward on localhost:${local_port}."
	kubectl -n "$namespace" port-forward "svc/$service" "$local_port:$service_port" \
		>"$log_file" 2>&1 &
	local pid=$!
	echo "$pid" >"$pid_file"
	tunnel_started_by_script=true

	local deadline=$((SECONDS + startup_timeout))
	while ((SECONDS < deadline)); do
		if is_ready; then
			return
		fi

		if ! is_alive "$pid"; then
			local rc=0
			wait "$pid" || rc=$?
			cat "$log_file"
			echo "Keycloak port-forward stopped unexpectedly (exit code ${rc})." >&2
			rm -f "$pid_file"
			exit 1
		fi

		sleep 0.5
	done

	cat "$log_file"
	echo "Keycloak port-forward did not become ready within ${startup_timeout}s." >&2
	stop_owned_tunnel
	exit 1
}

cleanup() {
	if [[ "$tunnel_started_by_script" == true ]]; then
		stop_owned_tunnel
	fi
}

case "${1:-}" in
    # Start the port-forward if no working tunnel is available.
	start)
		ensure_tunnel
		;;
	# Stop the port-forward managed through the PID file.
	stop)
		stop_owned_tunnel
		;;
	# Execute a command with the port-forward available and clean up a tunnel
	# started by this script after the command completes.
	run)
		shift
		[[ "${1:-}" == "--" ]] && shift
		if [[ "$#" -eq 0 ]]; then
			echo "Usage: $0 run -- <command> [args...]" >&2
			exit 2
		fi
		trap cleanup EXIT INT TERM
		ensure_tunnel
		"$@"
		;;
	*)
		echo "Usage: $0 {start|stop|run -- <command> [args...]}" >&2
		exit 2
		;;
esac
