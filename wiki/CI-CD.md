# CI/CD

## CI workflow

File: `.github/workflows/ci.yml`

- Runs on pull requests and pushes to `main`
- Installs `shellcheck`
- Executes `bash tools/ci/validate.sh`
- Builds a smoke-test package and uploads it as a workflow artifact

## CD workflow

File: `.github/workflows/cd.yml`

- Runs on:
  - Pushes to `main`
  - Version tags matching `v*`
  - Manual `workflow_dispatch`
- Re-validates repository state
- Builds package artifacts with `tools/release/package.sh`
- Uploads artifacts for every run
- Creates or updates a GitHub Release for version tags

## Local release packaging

```bash
bash tools/release/package.sh v0.1.0
```

Output in `dist/`:

- `cka-trainer-v0.1.0.tar.gz`
- `cka-trainer-v0.1.0.tar.gz.sha256`
- `scenarios-v0.1.0.txt`
