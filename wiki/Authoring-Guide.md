# Scenario Authoring Guide

## Goal

Create deterministic, exam-style break/fix labs that are fast to run and easy to reset.

## Required structure

Each top-level scenario folder should include:

- `inject.sh` (required)
- `verify.sh` (recommended)

Optional:

- `task.md` (student-facing objective/constraints)
- `README.md` (detailed walk-through)
- `solutions.md` (instructor notes)

## Inject script standards

- Use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Ensure scripts are idempotent where practical.
- Keep scope isolated to one namespace unless cluster-scoped behavior is part of the task.
- Print clear hint text only if intended by training mode.

## Verify script standards

- Exit `0` only when all success criteria are met.
- Exit non-zero on any failed check.
- Prefer explicit checks (PVC phase, ready replicas, service response).
- Keep verification deterministic and fast.

## Quality checks

Run before committing:

```bash
bash tools/ci/validate.sh
```

This checks scenario structure, shebang presence, Bash syntax, and `shellcheck` errors when available.
