# CI/CD

## CI workflow

File: `.github/workflows/ci.yml`

- Runs on pull requests and pushes to `main`
- Runs a `lint` job:
  - `bash tools/ci/lint.sh`
  - Includes `shellcheck`, `shfmt`, and workflow YAML linting
- Runs a `test` job:
  - `bash tools/ci/test.sh <version>`
  - Includes structure validation and package smoke-test checks
- Uploads smoke-test artifacts from `dist/`

## CD workflow

File: `.github/workflows/cd.yml`

- Runs on:
  - Pushes to `main`
  - Version tags matching `v*`
  - Manual `workflow_dispatch`
- Re-runs lint and tests before delivery
- Builds package artifacts with `tools/release/package.sh`
- Uploads artifacts for every run
- Creates or updates a GitHub Release for version tags

## Local quality checks

```bash
bash tools/ci/lint.sh
bash tools/ci/test.sh
```

## Local release packaging

```bash
bash tools/release/package.sh v0.1.0
```

Output in `dist/`:

- `cka-trainer-v0.1.0.tar.gz`
- `cka-trainer-v0.1.0.tar.gz.sha256`
- `scenarios-v0.1.0.txt`
