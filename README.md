# Typefully Skill for OpenClaw

Create, schedule, and manage [Typefully](https://typefully.com) drafts from your AI agent. Supports single tweets, threads, and multi-platform posts (X, LinkedIn, Threads, Bluesky, Mastodon).

## Setup

1. Get your Typefully API key from **Settings → API** in Typefully
2. Store it in your password manager:
   ```bash
   pass insert typefully/api-key
   ```
3. Install the skill:
   ```bash
   clawhub install typefully --dir ~/.openclaw/skills
   ```

## Usage

```bash
bash scripts/typefully.sh <command> [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `list-social-sets` | List your Typefully accounts |
| `list-drafts [status] [limit]` | List drafts (`draft`, `scheduled`, `published`) |
| `get-draft <id>` | Get draft details |
| `create-draft <text> [opts]` | Create a draft |
| `edit-draft <id> <text> [opts]` | Edit a draft |
| `schedule-draft <id> <when>` | Schedule or publish (`ISO 8601`, `next-free-slot`, `now`) |
| `delete-draft <id>` | Delete a draft |

### Examples

**Simple tweet:**
```bash
bash scripts/typefully.sh create-draft "Just shipped a new feature 🚀"
```

**Thread:**
```bash
bash scripts/typefully.sh create-draft "First tweet\n---\nSecond tweet\n---\nThird tweet" --thread
```

**Cross-platform (X + LinkedIn):**
```bash
bash scripts/typefully.sh create-draft "Big announcement!" --platform x,linkedin
```

**Schedule for later:**
```bash
bash scripts/typefully.sh create-draft "Morning thoughts ☀️" --schedule "2026-03-01T09:00:00Z"
```

**Schedule to next free slot:**
```bash
bash scripts/typefully.sh schedule-draft 123456 next-free-slot
```

## License

MIT
