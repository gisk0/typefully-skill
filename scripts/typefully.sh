#!/usr/bin/env bash
set -euo pipefail

API_BASE="https://api.typefully.com/v2"
SOCIAL_SET_ID="169283"
API_KEY=""

get_api_key() {
  API_KEY=$(pass typefully/api-key 2>/dev/null) || {
    echo "Error: Could not retrieve API key from pass typefully/api-key" >&2
    exit 1
  }
}

api() {
  local method="$1" endpoint="$2"
  shift 2
  curl -sf -X "$method" "${API_BASE}${endpoint}" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    "$@"
}

cmd_list_social_sets() {
  api GET "/social-sets"
}

cmd_list_drafts() {
  local status="${1:-}" limit="${2:-10}"
  local url="/social-sets/${SOCIAL_SET_ID}/drafts?limit=${limit}"
  if [[ -n "$status" ]]; then
    url="${url}&status=${status}"
  fi
  api GET "$url"
}

cmd_get_draft() {
  local draft_id="$1"
  api GET "/social-sets/${SOCIAL_SET_ID}/drafts/${draft_id}"
}

cmd_create_draft() {
  local text="$1"
  shift
  local platforms="x" schedule="" is_thread=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform) platforms="$2"; shift 2 ;;
      --schedule) schedule="$2"; shift 2 ;;
      --thread) is_thread=true; shift ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  # Build platform JSON
  local platform_json=""
  IFS=',' read -ra plats <<< "$platforms"
  for p in "${plats[@]}"; do
    local posts_json
    if [[ "$is_thread" == true ]]; then
      # Split on \n---\n
      posts_json="["
      local first=true
      while IFS= read -r post; do
        if [[ "$first" == true ]]; then
          first=false
        else
          posts_json+=","
        fi
        # Escape for JSON
        local escaped
        escaped=$(printf '%s' "$post" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
        posts_json+="{\"text\":${escaped}}"
      done <<< "$(printf '%b' "$text" | sed 's/\\n---\\n/\n/g')"
      posts_json+="]"
    else
      local escaped
      escaped=$(printf '%s' "$text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
      posts_json="[{\"text\":${escaped}}]"
    fi

    if [[ -n "$platform_json" ]]; then
      platform_json+=","
    fi
    platform_json+="\"${p}\":{\"enabled\":true,\"posts\":${posts_json}}"
  done

  local body="{\"platforms\":{${platform_json}}"
  if [[ -n "$schedule" ]]; then
    body+=",\"publish_at\":\"${schedule}\""
  fi
  body+="}"

  api POST "/social-sets/${SOCIAL_SET_ID}/drafts" -d "$body"
}

cmd_edit_draft() {
  local draft_id="$1" text="$2"
  shift 2
  local platforms="x"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform) platforms="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  local platform_json=""
  IFS=',' read -ra plats <<< "$platforms"
  for p in "${plats[@]}"; do
    local escaped
    escaped=$(printf '%s' "$text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
    if [[ -n "$platform_json" ]]; then
      platform_json+=","
    fi
    platform_json+="\"${p}\":{\"enabled\":true,\"posts\":[{\"text\":${escaped}}]}"
  done

  api PUT "/social-sets/${SOCIAL_SET_ID}/drafts/${draft_id}" \
    -d "{\"platforms\":{${platform_json}}}"
}

cmd_schedule_draft() {
  local draft_id="$1" when="$2"
  api PUT "/social-sets/${SOCIAL_SET_ID}/drafts/${draft_id}" \
    -d "{\"publish_at\":\"${when}\"}"
}

cmd_delete_draft() {
  local draft_id="$1"
  api DELETE "/social-sets/${SOCIAL_SET_ID}/drafts/${draft_id}"
  echo '{"status":"deleted","draft_id":"'"${draft_id}"'"}'
}

usage() {
  cat <<'EOF'
Usage: typefully.sh <command> [args]

Commands:
  list-social-sets                         List social sets (accounts)
  list-drafts [status] [limit]             List drafts (status: draft|scheduled|published)
  get-draft <draft_id>                     Get draft details
  create-draft <text> [options]            Create a draft
    --thread                               Treat text as thread (split on \n---\n)
    --platform <x,linkedin,...>            Platforms (default: x)
    --schedule <iso8601|next-free-slot>    Schedule the draft
  edit-draft <draft_id> <text> [options]   Edit a draft
    --platform <x,linkedin,...>            Platforms (default: x)
  schedule-draft <draft_id> <when>         Schedule/publish (iso8601|next-free-slot|now)
  delete-draft <draft_id>                  Delete a draft
EOF
  exit 1
}

main() {
  [[ $# -lt 1 ]] && usage
  get_api_key

  local cmd="$1"
  shift

  case "$cmd" in
    list-social-sets) cmd_list_social_sets ;;
    list-drafts) cmd_list_drafts "$@" ;;
    get-draft) [[ $# -lt 1 ]] && usage; cmd_get_draft "$@" ;;
    create-draft) [[ $# -lt 1 ]] && usage; cmd_create_draft "$@" ;;
    edit-draft) [[ $# -lt 2 ]] && usage; cmd_edit_draft "$@" ;;
    schedule-draft) [[ $# -lt 2 ]] && usage; cmd_schedule_draft "$@" ;;
    delete-draft) [[ $# -lt 1 ]] && usage; cmd_delete_draft "$@" ;;
    *) echo "Unknown command: $cmd" >&2; usage ;;
  esac
}

main "$@"
