#!/usr/bin/env bash
# Redclaw keyword management
# Usage: keywords.sh <add|list|delete|toggle|export> [args]
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

_validate_uuid() {
    local id="$1"
    if ! [[ "$id" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
        echo "Error: keyword_id must be a valid UUID (e.g. 550e8400-e29b-41d4-a716-446655440000)" >&2
        exit 1
    fi
}

case "${1:-}" in
    add)
        # $2 = keyword (required), remaining = flags (optional)
        KEYWORD="${2:-}"
        FLAGS="${*:3}"  # capture all remaining args as flags string
        if [[ -z "$KEYWORD" ]]; then
            echo "Usage: keywords.sh add <keyword> [flags]" >&2
            exit 1
        fi
        if [[ ${#KEYWORD} -gt 500 ]]; then
            echo "Error: keyword must be 500 characters or fewer" >&2
            exit 1
        fi
        _curl -X POST "${BASE_URL}/api/v1/keywords" \
            -H "Content-Type: application/json" \
            -d "$(jq -n \
                --arg k "$KEYWORD" \
                --arg f "$FLAGS" \
                '{keyword: $k, flags: $f}')" \
            | jq '.'
        ;;

    list)
        _curl "${BASE_URL}/api/v1/keywords" \
            | jq '.data[] | {id, keyword, flags, enabled, hit_count_24h}'
        ;;

    delete)
        KW_ID="${2:-}"
        if [[ -z "$KW_ID" ]]; then
            echo "Usage: keywords.sh delete <keyword_id>" >&2
            exit 1
        fi
        _validate_uuid "$KW_ID"
        _curl -X DELETE "${BASE_URL}/api/v1/keywords/${KW_ID}"
        echo "Deleted keyword ${KW_ID}"
        ;;

    toggle)
        KW_ID="${2:-}"
        if [[ -z "$KW_ID" ]]; then
            echo "Usage: keywords.sh toggle <keyword_id>" >&2
            exit 1
        fi
        _validate_uuid "$KW_ID"
        _curl -X PATCH "${BASE_URL}/api/v1/keywords/${KW_ID}/toggle" \
            | jq '.data | {id, keyword, enabled}'
        ;;

    export)
        _curl "${BASE_URL}/api/v1/keywords/export"
        ;;

    *)
        echo "Usage: keywords.sh <add|list|delete|toggle|export> [args]" >&2
        exit 1
        ;;
esac
