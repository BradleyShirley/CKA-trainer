# CKA Trainer

Hands-on CKA troubleshooting scenarios for a real Kubernetes cluster.

This repository is scenario-driven. Each scenario injects a failure and provides a verification path so you can practice diagnosis and recovery under time pressure.

## Repository layout

```text
.
├── .github/workflows/
│   ├── ci.yml
│   └── cd.yml
├── scenarios/
│   ├── bf-001-resource-quota/
│   ├── bf-001-statefulset-storage/
│   ├── pvc_pending_no_matching_storageclass/
│   └── pvc_pending_wrong_binding_mode/
├── tools/
│   ├── ci/validate.sh
│   └── release/package.sh
└── README.md
```

## Prerequisites

- Kubernetes cluster reachable from your shell
- `kubectl` configured with a working context
- Bash environment with standard Unix tools

Optional for local linting parity with CI:

- `shellcheck`

## Scenario workflow

1. Choose a scenario under `scenarios/`.
2. Inject the issue with `bash inject.sh`.
3. Troubleshoot using normal Kubernetes operations.
4. Validate your fix with `bash verify.sh` when available.
5. Clean up scenario resources or reset your cluster snapshot.

## Current scenarios

| Scenario | Domain | Primary issue | Namespace | Verification |
| --- | --- | --- | --- | --- |
| `bf-001-resource-quota` | Workloads/Policy | Pod quota blocks desired workload scale | `dev-team` | `verify.sh` present |
| `bf-001-statefulset-storage` | Storage | StatefulSet PVCs use invalid provisioner | `bf-001-lab` | No `verify.sh` yet |
| `pvc_pending_no_matching_storageclass` | Storage | PVC references missing StorageClass | `stg-lab` | `verify.sh` present |
| `pvc_pending_wrong_binding_mode` | Storage | PVC/storage class binding mode mismatch | `pvc-pending-wrong-binding-mode` | `verify.sh` present |

## Validation and packaging

Run repository validation:

```bash
bash tools/ci/validate.sh
```

Build a versioned release archive locally:

```bash
bash tools/release/package.sh v0.1.0
```

Artifacts are written to `dist/`:

- `cka-trainer-<version>.tar.gz`
- `cka-trainer-<version>.tar.gz.sha256`
- `scenarios-<version>.txt`

## CI/CD

### CI (`.github/workflows/ci.yml`)

- Triggers: pull requests, pushes to `main`
- Installs `shellcheck`
- Runs `tools/ci/validate.sh`
- Builds and uploads a smoke-test package artifact

### CD (`.github/workflows/cd.yml`)

- Triggers: pushes to `main`, tags matching `v*`, manual dispatch
- Re-runs validation and builds versioned artifacts
- Uploads artifacts for each run
- On tag pushes like `v0.1.0`, publishes a GitHub Release with artifacts

## Releasing

1. Merge changes to `main`.
2. Create and push a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

3. CD publishes the release and attached artifacts automatically.

## Notes

- `tools/ci/validate.sh` requires each top-level scenario to include `inject.sh`.
- Missing `verify.sh` is currently a warning (not a hard failure).
- Scenario-specific guidance may exist in local `README.md`, `task.md`, or `solutions.md` files.
