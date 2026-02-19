#!/usr/bin/env bash
# Redclaw system status check
# Usage: status.sh
#
# Environment:
#   REDCLAW_URL      - Redclaw backend URL (default: http://localhost:8000)
#   REDCLAW_API_KEY  - API key for authentication

set -euo pipefail

BASE_URL="${REDCLAW_URL:-http://localhost:8000}"
BASE_URL="${BASE_URL%/}"  # strip trailing slash
API_KEY="${REDCLAW_API_KEY:-}"

if [[ -z "$API_KEY" ]]; then
    echo "Error: REDCLAW_API_KEY is not set" >&2
    exit 1
fi

AUTH_HEADER="X-API-Key: ${API_KEY}"

_curl() {
    curl -sf \
        -H "$AUTH_HEADER" \
        "$@" || {
        echo "Error: failed to connect to Redclaw at ${BASE_URL}" >&2
        exit 1
    }
}

RESPONSE=$(_curl "${BASE_URL}/api/v1/status")
echo "$RESPONSE" | jq '.data | {
    keyword_count,
    alert_count_24h,
    sources: (.sources | to_entries | map({
        source: .key,
        last_run: .value.last_run
    }))
}'
