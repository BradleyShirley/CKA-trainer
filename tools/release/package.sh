#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-${GITHUB_REF_NAME:-}}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

if [[ ! "$VERSION" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid version '$VERSION'. Use only letters, numbers, ., _, -"
  exit 1
fi

DIST_DIR="$ROOT_DIR/dist"
ARCHIVE="cka-trainer-${VERSION}.tar.gz"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE"
CHECKSUM_PATH="$ARCHIVE_PATH.sha256"
MANIFEST_PATH="$DIST_DIR/scenarios-${VERSION}.txt"

mkdir -p "$DIST_DIR"

# Build a distributable package of trainer assets.
tar -czf "$ARCHIVE_PATH" \
  --exclude-vcs \
  --exclude='./dist' \
  README.md \
  scenarios \
  tools/ci/validate.sh \
  tools/release/package.sh

sha256sum "$ARCHIVE_PATH" > "$CHECKSUM_PATH"
find scenarios -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort > "$MANIFEST_PATH"

echo "Created: $ARCHIVE_PATH"
echo "Created: $CHECKSUM_PATH"
echo "Created: $MANIFEST_PATH"
