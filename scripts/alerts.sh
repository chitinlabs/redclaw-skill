#!/usr/bin/env bash
# Redclaw alerts query
# Usage: alerts.sh list [--source <source>] [--limit <n>] [--page <n>]
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

# Valid source identifiers
VALID_SOURCES="reddit hn lobsters bluesky rss mastodon"

# Defaults
LIMIT=20
PAGE=1
SOURCE=""

# Validate and skip subcommand (support "alerts.sh list ..." or "alerts.sh ...")
SUBCMD="${1:-list}"
if [[ "$SUBCMD" != "list" ]]; then
    echo "Usage: alerts.sh list [--source <source>] [--limit N] [--page N]" >&2
    exit 1
fi
shift || true

# Parse remaining arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --limit)
            LIMIT="${2:-20}"
            if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
                echo "Error: --limit must be a positive integer" >&2
                exit 1
            fi
            shift 2
            ;;
        --page)
            PAGE="${2:-1}"
            if ! [[ "$PAGE" =~ ^[0-9]+$ ]]; then
                echo "Error: --page must be a positive integer" >&2
                exit 1
            fi
            shift 2
            ;;
        --source)
            SOURCE="${2:-}"
            if [[ -n "$SOURCE" ]] && ! echo "$VALID_SOURCES" | grep -qw "$SOURCE"; then
                echo "Error: --source must be one of: ${VALID_SOURCES}" >&2
                exit 1
            fi
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: alerts.sh list [--source reddit|hn|lobsters|bluesky|rss|mastodon] [--limit N] [--page N]" >&2
            exit 1
            ;;
    esac
done

QUERY="limit=${LIMIT}&page=${PAGE}"
[[ -n "$SOURCE" ]] && QUERY="${QUERY}&source=${SOURCE}"

RESPONSE=$(_curl "${BASE_URL}/api/v1/alerts?${QUERY}")
echo "$RESPONSE" | jq '.data[] | {source, title, url, matched_keyword, created_at}'
