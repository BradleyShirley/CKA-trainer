# CKA Trainer Wiki

## Purpose

The CKA Trainer project provides break/fix Kubernetes scenarios for exam-style troubleshooting practice.

## Quick start

1. Clone and enter the repository.
2. Pick a scenario from `scenarios/`.
3. Run `bash inject.sh` in that scenario directory.
4. Diagnose and fix the issue.
5. Run `bash verify.sh` if the scenario provides one.

## Core links

- Scenario list: `wiki/Scenarios.md`
- Authoring guide: `wiki/Authoring-Guide.md`
- CI/CD and releases: `wiki/CI-CD.md`

## Project conventions

- Scenarios are self-contained folders under `scenarios/`.
- `inject.sh` is required for every scenario.
- `verify.sh` is strongly recommended.
- Scenario metadata/instructions can live in `task.md`, `README.md`, and `solutions.md`.
