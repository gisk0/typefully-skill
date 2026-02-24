---
name: typefully
description: Create, schedule, list, edit, and delete drafts on Typefully. Supports single tweets, threads, and multi-platform posts (X, LinkedIn, Threads, Bluesky, Mastodon). Use when user wants to draft, schedule, or manage social media posts via Typefully.
version: 1.0.0
requires:
  env:
    - TYPEFULLY_API_KEY
---

# Typefully Skill

Manage Typefully drafts via the v2 API. The API key is retrieved from `pass typefully/api-key`.

## Setup

The account's `social_set_id` is **169283** (username: chapati23). Enable "Development mode" in Typefully Settings → API to see draft IDs in the UI.

## Script Usage

```bash
bash scripts/typefully.sh <command> [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `list-drafts [status] [limit]` | List drafts. Status: `draft`, `scheduled`, `published` (default: all). Limit default: 10. |
| `create-draft <text> [--thread] [--platform x,linkedin,threads,bluesky,mastodon] [--schedule <iso8601\|next-free-slot>]` | Create a draft. For threads, separate posts with `\n---\n`. Default platform: x. |
| `get-draft <draft_id>` | Get a single draft with full details. |
| `edit-draft <draft_id> <text> [--platform x,linkedin]` | Update draft content. |
| `schedule-draft <draft_id> <iso8601\|next-free-slot\|now>` | Schedule or publish a draft. |
| `delete-draft <draft_id>` | Delete a draft. |
| `list-social-sets` | List available social sets (accounts). |

### Examples

**Create a simple tweet draft:**
```bash
bash scripts/typefully.sh create-draft "Just shipped a new feature 🚀"
```

**Create a thread:**
```bash
bash scripts/typefully.sh create-draft "First tweet of the thread\n---\nSecond tweet\n---\nThird tweet with the punchline" --thread
```

**Create cross-platform draft (X + LinkedIn):**
```bash
bash scripts/typefully.sh create-draft "Exciting update!" --platform x,linkedin
```

**Schedule a draft for a specific time:**
```bash
bash scripts/typefully.sh create-draft "Morning thoughts ☀️" --schedule "2026-03-01T09:00:00Z"
```

**Schedule to next free slot:**
```bash
bash scripts/typefully.sh schedule-draft 8196074 next-free-slot
```

**List recent drafts:**
```bash
bash scripts/typefully.sh list-drafts draft 5
```

## Notes

- `publish_at: "now"` publishes immediately — use with caution
- `publish_at: "next-free-slot"` uses the user's Typefully queue schedule
- Thread posts are separated by `\n---\n` in the text argument
- The script outputs JSON; pipe through `jq` for formatting
