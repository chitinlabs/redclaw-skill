# Redclaw Monitor — OpenClaw Skill

Monitor Reddit, HN, Lobsters, Bluesky, Mastodon, and custom RSS feeds for keywords. Get notified when your topics are mentioned. Manage your entire watchlist through natural language in Telegram, Discord, or WhatsApp.

## Prerequisites

1. A running [Redclaw](https://github.com/chitinlabs/redclaw) instance (self-hosted)
2. [OpenClaw](https://openclaw.ai/) installed locally
3. `curl` and `jq` available in your PATH

## Installation

```bash
npx clawhub@latest install redclaw
```

## Configuration

Add to your OpenClaw environment (e.g. `~/.openclaw/env`):

```bash
export REDCLAW_URL=http://localhost:8000   # or your remote URL
export REDCLAW_API_KEY=rc_your_api_key_here
```

To get your API key, run on the Redclaw server:

```bash
python -m app.scripts.create_api_key
```

Restart OpenClaw after setting the variables.

## Usage Examples

Once installed, just talk to OpenClaw naturally:

| You say | What happens |
|---------|-------------|
| "Monitor 'Rust async' on HN" | Adds keyword with `--source hn` flag |
| "Watch for Claude Sonnet everywhere" | Adds keyword across all sources |
| "What am I monitoring?" | Lists all active keywords |
| "Any recent hits?" | Shows latest 20 alerts |
| "Show Reddit alerts from the last hour" | Filters alerts by source |
| "Stop monitoring GPT-4" | Toggles or deletes the keyword |
| "Add this RSS feed: https://example.com/feed.xml" | Adds custom RSS source |
| "Is the monitor running?" | Shows system status |

## Manual script usage

The scripts in `scripts/` can also be called directly:

```bash
# Set environment
export REDCLAW_URL=http://localhost:8000
export REDCLAW_API_KEY=rc_your_key

# Add a keyword
./scripts/keywords.sh add "LLM inference" "--source hn,reddit"

# List keywords
./scripts/keywords.sh list

# View recent alerts
./scripts/alerts.sh list --limit 10 --source reddit

# Check status
./scripts/status.sh
```

## Supported sources

| Source | Identifier |
|--------|-----------|
| Reddit | `reddit` |
| Hacker News | `hn` |
| Lobsters | `lobsters` |
| Bluesky | `bluesky` |
| Mastodon instances | `mastodon` |
| Custom RSS/Atom feeds | `rss` |

## Keyword flags

Append flags to control matching behavior:

```
--source reddit,hn          Only monitor specific sources
--case-sensitive            Case-sensitive keyword matching
--whole-word                Match whole word only (not substrings)
--group <name>              Assign keyword to a named group
--no-comments               Skip comments, posts only
```

## Troubleshooting

**"Could not connect to Redclaw"** — Check that `REDCLAW_URL` points to a running Redclaw instance.

**"REDCLAW_API_KEY is not set"** — Add the variable to your OpenClaw environment configuration.

**401 Unauthorized** — Verify `REDCLAW_API_KEY` matches a key created in Redclaw.

## Links

- [Redclaw GitHub](https://github.com/chitinlabs/redclaw)
- [OpenClaw](https://openclaw.ai/)
- [ClawHub](https://clawhub.ai/)
