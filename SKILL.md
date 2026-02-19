---
name: redclaw
version: 1.0.0
description: >
  Monitor Reddit, HN (Hacker News), Lobsters, Bluesky, Mastodon, and custom RSS
  feeds for keywords. Get alerts when keyword mentions appear. Manage your keyword
  watchlist with natural language.
author: chitinlabs
license: MIT
tags:
  - monitoring
  - reddit
  - hackernews
  - rss
  - alerts
  - keywords
  - bluesky
  - mastodon
metadata:
  openclaw:
    requires:
      env:
        - REDCLAW_URL       # e.g. http://localhost:8000
        - REDCLAW_API_KEY   # X-API-Key for Redclaw authentication
      bins:
        - curl
        - jq
---

# Redclaw Monitor Skill

This skill connects OpenClaw to a self-hosted [Redclaw](https://github.com/chitinlabs/redclaw) backend to monitor keywords across Reddit, Hacker News, Lobsters, Bluesky, Mastodon, and custom RSS feeds.

## When to use this skill

Activate this skill when the user wants to:
- **Monitor / watch / track keywords** — detect new mentions on social platforms
- **View alerts** — check recent keyword matches
- **Manage their watchlist** — add, remove, list, or disable monitored keywords
- **Add RSS sources** — subscribe to custom feeds for monitoring
- **Check system status** — verify the monitoring service is running

Trigger phrases (English and Chinese):
- `monitor`, `watch`, `track`, `alert`, `keyword`, `hits`, `mentions`
- `监控`, `告警`, `关键词`, `命中`, `订阅`, `提醒`

## Capabilities and commands

### Add a keyword to monitor
```
scripts/keywords.sh add "<keyword>" ["<flags>"]
```
Call this when the user says things like:
- "Monitor 'LLM inference' on Hacker News"
- "Watch for mentions of Rust async on Reddit"
- "Track 'Claude Sonnet' everywhere"
- "帮我监控 HN 上的 LLM inference"

The `flags` argument is optional. Supported flags:
- `--source reddit,hn,lobsters,bluesky,rss` — limit to specific platforms
- `--case-sensitive` — case-sensitive matching
- `--whole-word` — match whole word only
- `--group <name>` — assign to a named group

### List all monitored keywords
```
scripts/keywords.sh list
```
Call this when the user asks:
- "What keywords am I monitoring?"
- "Show my watchlist"
- "我在监控什么关键词"

### Delete a keyword
```
scripts/keywords.sh delete "<keyword_id>"
```
Use when user says "stop monitoring X" or "remove keyword X". First list keywords to get the ID.

### Enable/disable a keyword
```
scripts/keywords.sh toggle "<keyword_id>"
```
Use when user wants to temporarily pause monitoring without deleting the keyword.

### Export keywords as CSV
```
scripts/keywords.sh export
```
Use when user asks to "export" or "download" their keyword list.

### View recent alerts
```
scripts/alerts.sh list [--limit 20] [--source reddit]
```
Call this when the user says:
- "What's new?" / "Any recent hits?"
- "Show alerts from Reddit"
- "最近有什么命中" / "有没有 HN 上的告警"

Source options: `reddit`, `hn`, `lobsters`, `bluesky`, `rss`, `mastodon`

### Add an RSS source
```
scripts/sources.sh add-rss "<name>" "<url>" [<poll_interval_minutes>]
```
Use when user wants to monitor a specific RSS/Atom feed.

### List RSS sources
```
scripts/sources.sh list-rss
```

### Check system status
```
scripts/status.sh
```
Call this when the user asks:
- "Is the monitor running?"
- "System status"
- "监控服务正常吗"

Returns: total keywords, 24h alert count, per-source last run time.

## Response formatting guidelines

When displaying alerts, format them clearly:
```
📌 [SOURCE] matched keyword: "KEYWORD"
   Title: POST_TITLE
   URL: POST_URL
   Time: CREATED_AT
```

When displaying keyword list, group by enabled/disabled status.

When the Redclaw service is unreachable (curl returns non-zero exit code), tell the user:
> "Could not connect to Redclaw at $REDCLAW_URL. Please check your REDCLAW_URL environment variable and ensure the service is running."

## Setup reminder

If `REDCLAW_URL` or `REDCLAW_API_KEY` is not set, remind the user:
> "This skill requires REDCLAW_URL and REDCLAW_API_KEY to be set. Add them to your OpenClaw environment configuration."
