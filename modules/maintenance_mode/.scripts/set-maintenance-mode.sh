#!/usr/bin/env bash
set -euo pipefail

SERVICE_COUNT="${UPDATE_SERVICE_COUNT:=0}"
ACTIVATE_MAINTENANCE="${ACTIVATE_MAINTENANCE_MODE:=false}"
SCRIPT_FOLDER="$(dirname "$0")"
command="";
implementation_check="$(kubectl get EnvoyFilter ingressgateway-maintenance-mode-automatic-update -n istio-system --ignore-not-found)";

if [ "${SERVICE_COUNT}" -gt 0 ] && [ -z "$implementation_check" ] && [ "${ACTIVATE_MAINTENANCE}" = true ]; then
  command="apply";
fi

if [ "${SERVICE_COUNT}" -eq 0 ] && [ ! -z "$implementation_check" ] && [ "${ACTIVATE_MAINTENANCE}" = false ]; then
  command="delete";
fi

if [ ! -z "$command" ]; then
  kubectl $command -f ${SCRIPT_FOLDER}/maintenance-mode.yaml;
fi