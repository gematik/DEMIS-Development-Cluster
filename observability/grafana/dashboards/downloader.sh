#!/usr/bin/env sh

set -e

ISTIO_VERSION=$1
PROXY_URL="http://192.168.110.10:3128"
USE_PROXY=false

# Function to check if the proxy is reachable
check_proxy() {
    if curl -x $PROXY_URL --connect-timeout 2 -s --head --request GET http://www.google.com | grep "200 OK" > /dev/null; then
        echo "## Proxy is reachable"
        USE_PROXY=true
    else
        echo "## Proxy is not reachable"
        USE_PROXY=false
    fi
}

# Function to determine the curl command based on the USE_PROXY variable
curl_cmd() {
    if [ "$USE_PROXY" = "true" ]; then
        echo "curl -x $PROXY_URL"
    else
        echo "curl"
    fi
}

# Check if the proxy is reachable
check_proxy

# First Parameter: Dashboard ID
# Second Parameter: if true, check if the dashboard is compatible with Istio, otherwise download the specified version
download_dashboard() {
    DASHBOARD_ID="$1"
    REVISION=$2
    CURL=$(curl_cmd)
    if [ "$2" = "true" ]; then
        REVISION=$($CURL -s https://grafana.com/api/dashboards/${DASHBOARD_ID}/revisions -s | jq ".items[] | select(.description | contains(\"${ISTIO_VERSION}\")) | .revision" | tail -n 1)
    fi
    echo "## Downloading Dashboard ${DASHBOARD_ID} with revision ${REVISION}"
    $CURL -s https://grafana.com/api/dashboards/${DASHBOARD_ID}/revisions/${REVISION}/download -o ${DASHBOARD_ID}.json
    sed -i '/-- .* --/! s/"datasource":.*,/"datasource": "Prometheus",/g' ${DASHBOARD_ID}.json
    # Removed unwanted chars in title, replace whitespaces with "-"
    NAME=$(jq -r '.title' < ${DASHBOARD_ID}.json | sed 's/[^[:blank:][:alnum:]\t]//g' | sed 's/\s/-/g')
    mv ${DASHBOARD_ID}.json "${NAME}.json"
    echo "-- Dashboard ${DASHBOARD_ID} - completed"
}

echo "## Removing old dashboards, if present"
rm -rf *.json

# Istio Dashboards
download_dashboard 7630 true
download_dashboard 7636 true
download_dashboard 7639 true
download_dashboard 7645 true
download_dashboard 11829 true
download_dashboard 13277 true

# Basic Dashboards
download_dashboard 4701 10
download_dashboard 19105 9

# Kubernetes
download_dashboard 15757 43
download_dashboard 15760 41
download_dashboard 15758 46
download_dashboard 15759 40
download_dashboard 15761 21
download_dashboard 15762 22
