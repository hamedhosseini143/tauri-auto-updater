#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$ROOT_DIR/.." && pwd)"
TAURI_CONF="$PROJECT_DIR/src-tauri/tauri.conf.json"
ENV_FILE="$PROJECT_DIR/.env"

require_cmd() {
if ! command -v "$1" >/dev/null 2>&1; then
echo "Missing dependency: $1" >&2
exit 1
fi
}

require_cmd jq
require_cmd npx

echo "Generating Tauri signing keys (private/public) via tauri signer..."
# Prefer local @tauri-apps/cli; fallback to tauri if globally resolvable.
if output=$(cd "$PROJECT_DIR" && npx @tauri-apps/cli signer generate --ci 2>/dev/null); then
true
else
output=$(cd "$PROJECT_DIR" && npx tauri signer generate --ci)
fi

private_key=$(printf '%s\n' "$output" | sed -n 's/^Private key (base64): //p')
public_key=$(printf '%s\n' "$output" | sed -n 's/^Public key (base64): //p')
password=$(printf '%s\n' "$output" | sed -n 's/^Password: //p')

if [[ -z "$private_key" || -z "$public_key" ]]; then
echo "Could not parse keys from tauri signer output." >&2
exit 1
fi

echo "Updating updater pubkey in tauri.conf.json..."
tmp_file="$(mktemp)"
jq --arg pub "$public_key" '.plugins.updater.pubkey = $pub' "$TAURI_CONF" > "$tmp_file"
mv "$tmp_file" "$TAURI_CONF"

echo "Writing .env with signing secrets..."
cat > "$ENV_FILE" <<EOF
  TAURI_SIGNING_PRIVATE_KEY=$private_key
  TAURI_SIGNING_PRIVATE_KEY_PASSWORD=$password
  EOF

  echo "Done. Details:"
  echo "- Public key set in: $TAURI_CONF"
  echo "- Private key & password written to: $ENV_FILE (keep it secret, do not commit)"
  echo "Next: add the same values to GitHub Secrets (TAURI_SIGNING_PRIVATE_KEY / TAURI_SIGNING_PRIVATE_KEY_PASSWORD)."