#!/usr/bin/env bash
set -euo pipefail

TARGET="/root"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: $TARGET does not exist or is not a directory." >&2
  exit 1
fi

echo "Scanning $TARGET for largest directories (top 20)..."
sudo du -h --max-depth=1 "$TARGET" 2>/dev/null | sort -hr | head -n 20

echo
echo "Total size of $TARGET:"
sudo du -sh "$TARGET"
