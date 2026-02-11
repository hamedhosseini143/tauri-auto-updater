#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TAURI_CONF="$ROOT_DIR/src-tauri/tauri.conf.json"

if ! command -v jq >/dev/null 2>&1; then
echo "jq is required. Install with: brew install jq" >&2
exit 1
fi

cd "$ROOT_DIR"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "main" ]]; then
echo "You must be on main. Current branch: $current_branch" >&2
exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
echo "Working directory is not clean. Commit or stash changes first." >&2
exit 1
fi

echo "Pulling latest from origin/main..."
git pull origin main --ff-only

latest_tag="$(git describe --tags --match "v[0-9]*.[0-9]*.[0-9]*" --abbrev=0 2>/dev/null || true)"
if [[ -z "$latest_tag" ]]; then
latest_tag="v0.0.0"
fi

current_version="${latest_tag#v}"
IFS='.' read -r major minor patch <<< "$current_version"

  next_patch="$major.$minor.$((patch + 1))"
  next_minor="$major.$((minor + 1)).0"
  next_major="$((major + 1)).0.0"

  echo "Current production tag: $latest_tag"
  echo "Select version bump:"
  echo "  1) Patch  ($next_patch) - bug fixes"
  echo "  2) Minor  ($next_minor) - new features"
  echo "  3) Major  ($next_major) - breaking changes"
  read -rp "Choice [1/2/3, default 1]: " choice

  case "${choice:-1}" in
  1) new_version="$next_patch" ;;
  2) new_version="$next_minor" ;;
  3) new_version="$next_major" ;;
  *) echo "Invalid choice.">&2; exit 1 ;;
  esac

  echo "About to create PRODUCTION release v$new_version"
  read -rp "Proceed? [y/N]: " confirm
  if [[ "${confirm,,}" != "y" ]]; then
  echo "Aborted."
  exit 1
  fi

  echo "Updating $TAURI_CONF..."
  tmp_file="$(mktemp)"
  jq --arg v "$new_version" '.version = $v' "$TAURI_CONF" > "$tmp_file"
  mv "$tmp_file" "$TAURI_CONF"

  git add "$TAURI_CONF"
  git commit -m "chore: release v$new_version"
  git push origin main

  echo "Tagging v$new_version..."
  git tag "v$new_version"
  git push origin "v$new_version"

  echo "Release v$new_version completed."