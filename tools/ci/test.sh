#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-ci-smoke}"

echo "[test] Running validation"
bash tools/ci/validate.sh

echo "[test] Building smoke package for version: ${VERSION}"
bash tools/release/package.sh "$VERSION"

archive="dist/cka-trainer-${VERSION}.tar.gz"
checksum="${archive}.sha256"
manifest="dist/scenarios-${VERSION}.txt"

for path in "$archive" "$checksum" "$manifest"; do
  if [[ ! -s "$path" ]]; then
    echo "[test] ERROR: expected artifact not found or empty: $path"
    exit 1
  fi
done

echo "[test] Completed successfully"
