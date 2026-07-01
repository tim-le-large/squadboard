#!/usr/bin/env bash
# Generates web/firebase-messaging-sw.js from template + dart_defines.json (local)
# or environment variables (CI). Never commit the output file.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/web/firebase-messaging-sw.template.js"
OUTPUT="$ROOT/web/firebase-messaging-sw.js"
DEFINES="${1:-$ROOT/dart_defines.json}"

read_define() {
  local key="$1"
  if [[ -n "${!key:-}" ]]; then
    printf '%s' "${!key}"
    return
  fi
  if [[ -f "$DEFINES" ]] && command -v jq >/dev/null 2>&1; then
    jq -r --arg k "$key" '.[$k] // empty' "$DEFINES"
    return
  fi
  echo "Missing $key — set env var or add to $DEFINES" >&2
  exit 1
}

API_KEY="$(read_define FIREBASE_API_KEY)"
AUTH_DOMAIN="$(read_define FIREBASE_AUTH_DOMAIN)"
PROJECT_ID="$(read_define FIREBASE_PROJECT_ID)"
STORAGE_BUCKET="$(read_define FIREBASE_STORAGE_BUCKET)"
MESSAGING_SENDER_ID="$(read_define FIREBASE_MESSAGING_SENDER_ID)"
APP_ID="$(read_define FIREBASE_APP_ID)"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[&/\]/\\&/g'
}

sed \
  -e "s|__FIREBASE_API_KEY__|$(escape_sed "$API_KEY")|g" \
  -e "s|__FIREBASE_AUTH_DOMAIN__|$(escape_sed "$AUTH_DOMAIN")|g" \
  -e "s|__FIREBASE_PROJECT_ID__|$(escape_sed "$PROJECT_ID")|g" \
  -e "s|__FIREBASE_STORAGE_BUCKET__|$(escape_sed "$STORAGE_BUCKET")|g" \
  -e "s|__FIREBASE_MESSAGING_SENDER_ID__|$(escape_sed "$MESSAGING_SENDER_ID")|g" \
  -e "s|__FIREBASE_APP_ID__|$(escape_sed "$APP_ID")|g" \
  "$TEMPLATE" > "$OUTPUT"

echo "Wrote $OUTPUT"
