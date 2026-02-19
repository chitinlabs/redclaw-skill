#!/usr/bin/env bash
# Redclaw RSS source and Mastodon instance management
# Usage: sources.sh <add-rss|list-rss|delete-rss|add-mastodon|list-mastodon|list> [args]
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

case "${1:-}" in
    add-rss)
        # $2=name, $3=url, $4=poll_interval (optional, default 30)
        NAME="${2:-}"
        URL="${3:-}"
        POLL="${4:-30}"
        if [[ -z "$NAME" || -z "$URL" ]]; then
            echo "Usage: sources.sh add-rss <name> <url> [poll_interval_minutes]" >&2
            exit 1
        fi
        if ! [[ "$POLL" =~ ^[0-9]+$ ]]; then
            echo "Error: poll_interval must be a positive integer (minutes)" >&2
            exit 1
        fi
        _curl -X POST "${BASE_URL}/api/v1/sources/rss" \
            -H "Content-Type: application/json" \
            -d "$(jq -n \
                --arg name "$NAME" \
                --arg url "$URL" \
                --argjson poll "$POLL" \
                '{name: $name, url: $url, poll_interval_minutes: $poll}')" \
            | jq '.'
        ;;

    list-rss)
        _curl "${BASE_URL}/api/v1/sources/rss" \
            | jq '.data[] | {id, name, url, poll_interval_minutes, enabled}'
        ;;

    delete-rss)
        SOURCE_ID="${2:-}"
        if [[ -z "$SOURCE_ID" ]]; then
            echo "Usage: sources.sh delete-rss <source_id>" >&2
            exit 1
        fi
        # source_id is an integer
        if ! [[ "$SOURCE_ID" =~ ^[0-9]+$ ]]; then
            echo "Error: source_id must be a positive integer" >&2
            exit 1
        fi
        _curl -X DELETE "${BASE_URL}/api/v1/sources/rss/${SOURCE_ID}"
        echo "Deleted RSS source ${SOURCE_ID}"
        ;;

    add-mastodon)
        # $2=instance_url (e.g. https://mastodon.social)
        INSTANCE="${2:-}"
        if [[ -z "$INSTANCE" ]]; then
            echo "Usage: sources.sh add-mastodon <instance_url>" >&2
            exit 1
        fi
        _curl -X POST "${BASE_URL}/api/v1/sources/mastodon" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg url "$INSTANCE" '{instance_url: $url}')" \
            | jq '.'
        ;;

    list-mastodon)
        _curl "${BASE_URL}/api/v1/sources/mastodon" \
            | jq '.data[] | {id, instance_url, enabled}'
        ;;

    list)
        echo "=== RSS Sources ==="
        _curl "${BASE_URL}/api/v1/sources/rss" \
            | jq '.data[] | {id, name, url, enabled}'
        echo "=== Mastodon Instances ==="
        _curl "${BASE_URL}/api/v1/sources/mastodon" \
            | jq '.data[] | {id, instance_url, enabled}'
        ;;

    *)
        echo "Usage: sources.sh <add-rss|list-rss|delete-rss|add-mastodon|list-mastodon|list> [args]" >&2
        exit 1
        ;;
esac
