#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

mapfile -d '' scripts < <(find scenarios tools -type f -name '*.sh' -print0 | sort -z)
mapfile -d '' workflow_yamls < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 | sort -z)

if ((${#scripts[@]} == 0)); then
  echo "[lint] ERROR: no shell scripts found under scenarios/ or tools/"
  exit 1
fi

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[lint] ERROR: shellcheck is required but not installed"
  exit 1
fi

if ! command -v shfmt >/dev/null 2>&1; then
  echo "[lint] ERROR: shfmt is required but not installed"
  exit 1
fi

if ! command -v yamllint >/dev/null 2>&1; then
  echo "[lint] ERROR: yamllint is required but not installed"
  exit 1
fi

echo "[lint] Running shellcheck on ${#scripts[@]} scripts"
shellcheck -S warning -x "${scripts[@]}"

echo "[lint] Running shfmt check"
shfmt -d -i 2 -ci "${scripts[@]}"

if ((${#workflow_yamls[@]} > 0)); then
  echo "[lint] Running yamllint on GitHub workflows"
  yamllint --strict -d '{extends: default, rules: {line-length: {max: 180}, truthy: disable}}' "${workflow_yamls[@]}"
fi

echo "[lint] Completed successfully"
