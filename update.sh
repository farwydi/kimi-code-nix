#!/usr/bin/env bash
# Regenerate sources.json with the latest Kimi Code version and per-system hashes.
# Pin a version with: ./update.sh 0.26.0
set -euo pipefail
cd "$(dirname "$0")"

base="https://code.kimi.com/kimi-code"
ver="${1:-$(curl -fsSL "$base/latest" | tr -d '[:space:]')}"
[ -n "$ver" ] || { echo "could not determine latest version" >&2; exit 1; }

manifest=$(curl -fsSL "$base/binaries/$ver/manifest.json")

# system -> manifest platform key
systems="x86_64-linux:linux-x64 aarch64-linux:linux-arm64 x86_64-darwin:darwin-x64 aarch64-darwin:darwin-arm64"

json=$(jq -n --arg version "$ver" '{version: $version, systems: {}}')
for entry in $systems; do
  sys="${entry%%:*}"; plat="${entry#*:}"
  filename=$(jq -er ".platforms[\"$plat\"].filename" <<<"$manifest")
  hex=$(jq -er ".platforms[\"$plat\"].checksum" <<<"$manifest")
  sri=$(nix hash convert --hash-algo sha256 "$hex")
  json=$(jq --arg s "$sys" --arg f "$filename" --arg h "$sri" \
    '.systems[$s] = {filename: $f, hash: $h}' <<<"$json")
done

printf '%s\n' "$json" > sources.json
echo "updated to $ver"
