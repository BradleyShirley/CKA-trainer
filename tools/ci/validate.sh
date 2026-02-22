#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "[validate] Checking repository structure"

# Every top-level scenario should include an inject script.
structure_failed=0
while IFS= read -r -d '' scenario_dir; do
  if [[ ! -f "$scenario_dir/inject.sh" ]]; then
    echo "[validate] ERROR: missing inject.sh in $scenario_dir"
    structure_failed=1
  fi

  if [[ ! -f "$scenario_dir/verify.sh" ]]; then
    echo "[validate] WARN: missing verify.sh in $scenario_dir"
  fi
done < <(find scenarios -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if ((structure_failed)); then
  exit 1
fi

mapfile -d '' scripts < <(find scenarios tools -type f -name '*.sh' -print0 | sort -z)

if (( ${#scripts[@]} == 0 )); then
  echo "[validate] ERROR: no shell scripts found under scenarios/ or tools/"
  exit 1
fi

echo "[validate] Running shebang + bash syntax checks (${#scripts[@]} scripts)"
for script in "${scripts[@]}"; do
  first_line=""
  if IFS= read -r first_line < "$script"; then
    :
  fi

  if [[ "$first_line" != '#!'* ]]; then
    echo "[validate] ERROR: missing shebang in $script"
    exit 1
  fi

  bash -n "$script"
done

if command -v shellcheck >/dev/null 2>&1; then
  echo "[validate] Running shellcheck (error-level only)"
  shellcheck -S error -x "${scripts[@]}"
else
  echo "[validate] shellcheck not installed; skipping"
fi

echo "[validate] Completed successfully"
