#!/usr/bin/env bash
# graph.sh — Microsoft Graph wrapper for the Intune skill.
#
# Usage:
#   scripts/graph.sh GET    "/deviceManagement/managedDevices?\$select=deviceName"
#   scripts/graph.sh POST   "/deviceManagement/managedDevices/{id}/syncDevice"
#   scripts/graph.sh POST   "/deviceManagement/deviceCompliancePolicies" '{"displayName":"..."}'
#   scripts/graph.sh PATCH  "/identity/conditionalAccess/policies/{id}" '{"state":"disabled"}'
#   scripts/graph.sh DELETE "/deviceManagement/managedDevices/{id}"
#
# Behaviour:
#   * Paths default to v1.0; prefix with /beta/ for the beta API.
#   * GET: follows @odata.nextLink and merges all pages into one JSON
#     document ({"value":[...], "pages":N}); non-collection GETs pass through.
#   * Retries HTTP 429 honoring Retry-After (max 5 attempts).
#   * Adds "ConsistencyLevel: eventual" (+ $count=true) automatically for
#     $filter/$search queries on /users and /groups.
#   * Refreshes the token once on 401.
#   * INTUNE_READ_ONLY=true blocks every non-GET request.
#
# Depends on: curl, jq, scripts/get_token.sh (same directory).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

METHOD="${1:-}"; RAW_PATH="${2:-}"; BODY="${3:-}"
METHOD="$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')"

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
[[ -z "$METHOD" || -z "$RAW_PATH" ]] && usage
case "$METHOD" in GET|POST|PATCH|PUT|DELETE) ;; *) usage ;; esac

# ---- read-only guard --------------------------------------------------------
if [[ "${INTUNE_READ_ONLY:-false}" == "true" && "$METHOD" != "GET" ]]; then
  echo "ERROR: INTUNE_READ_ONLY=true — refusing $METHOD $RAW_PATH" >&2
  exit 4
fi

# ---- build URL ---------------------------------------------------------------
BASE="https://graph.microsoft.com"
case "$RAW_PATH" in
  https://*) URL="$RAW_PATH" ;;                      # absolute (e.g. nextLink)
  /beta/*|/v1.0/*) URL="${BASE}${RAW_PATH}" ;;
  /*) URL="${BASE}/v1.0${RAW_PATH}" ;;
  *) URL="${BASE}/v1.0/${RAW_PATH}" ;;
esac

# ---- advanced-query headers for /users & /groups ------------------------------
# shellcheck disable=SC2016  # literal $filter/$search/$count are intentional
EXTRA_HEADERS=()
if [[ "$URL" =~ /v1\.0/(users|groups)(/|\?|$) || "$URL" =~ /beta/(users|groups)(/|\?|$) ]]; then
  if [[ "$URL" == *'$filter='* || "$URL" == *'$search='* || "$URL" == *'$count='* ]]; then
    EXTRA_HEADERS+=(-H "ConsistencyLevel: eventual")
    [[ "$URL" != *'$count='* ]] && URL="${URL}$([[ "$URL" == *\?* ]] && echo '&' || echo '?')\$count=true"
  fi
fi

TOKEN="$("$SCRIPT_DIR/get_token.sh")"

# ---- single request with 429/401 handling -------------------------------------
do_request() { # $1=url ; echoes body ; returns 0/1
  local url="$1" attempt=0 http body hdrs
  while :; do
    attempt=$((attempt+1))
    hdrs="$(mktemp)"
    body="$(curl -sS -D "$hdrs" -o - -w '' \
      -X "$METHOD" "$url" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      "${EXTRA_HEADERS[@]}" \
      ${BODY:+--data "$BODY"})" || { rm -f "$hdrs"; return 1; }
    http="$(awk 'toupper($1) ~ /^HTTP/ {code=$2} END {print code}' "$hdrs")"

    if [[ "$http" == "429" ]]; then
      local wait
      wait="$(awk 'tolower($1)=="retry-after:" {gsub(/\r/,"",$2); print $2}' "$hdrs")"
      rm -f "$hdrs"
      [[ "$wait" =~ ^[0-9]+$ ]] || wait=10
      if (( attempt >= 5 )); then
        echo "ERROR: throttled (429) after $attempt attempts" >&2; return 1
      fi
      echo "throttled, waiting ${wait}s (attempt $attempt/5)…" >&2
      sleep "$wait"; continue
    fi

    if [[ "$http" == "401" && $attempt -eq 1 ]]; then
      rm -f "$hdrs"
      TOKEN="$("$SCRIPT_DIR/get_token.sh" --force)"
      continue
    fi

    rm -f "$hdrs"
    if [[ "$http" =~ ^2 ]]; then
      echo "$body"; return 0
    fi
    echo "ERROR: HTTP $http for $METHOD $url" >&2
    echo "$body" | jq -r '.error.message // .error_description // .' >&2 2>/dev/null || echo "$body" >&2
    return 1
  done
}

# ---- GET: paginate; others: single call ---------------------------------------
if [[ "$METHOD" == "GET" ]]; then
  merged='[]'; pages=0; next="$URL"
  while [[ -n "$next" ]]; do
    resp="$(do_request "$next")" || exit 1
    pages=$((pages+1))
    if echo "$resp" | jq -e 'has("value")' >/dev/null 2>&1; then
      merged="$(jq -c --argjson acc "$merged" '$acc + .value' <<<"$resp")"
      next="$(jq -r '."@odata.nextLink" // empty' <<<"$resp")"
    else
      # non-collection response (single object) — pass through
      echo "$resp"; exit 0
    fi
  done
  jq -n --argjson v "$merged" --argjson p "$pages" \
    --argjson c "$(jq 'length' <<<"$merged")" \
    '{value:$v, count:$c, pages:$p}'
else
  resp="$(do_request "$URL")" || exit 1
  [[ -n "$resp" ]] && echo "$resp" || echo '{"status":"ok"}'
fi
