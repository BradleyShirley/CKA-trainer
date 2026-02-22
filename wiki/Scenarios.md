# Scenarios

## Active scenarios

### `bf-001-resource-quota`
- Domain: Workloads/Policy
- Namespace: `dev-team`
- Failure pattern: ResourceQuota prevents all desired Pods from running.
- Files: `inject.sh`, `verify.sh`

### `bf-001-statefulset-storage`
- Domain: Storage
- Namespace: `bf-001-lab`
- Failure pattern: StatefulSet PVC provisioning fails due to invalid StorageClass provisioner.
- Files: `inject.sh`
- Gap: no `verify.sh` yet.

### `pvc_pending_no_matching_storageclass`
- Domain: Storage
- Namespace: `stg-lab`
- Failure pattern: PVC references a StorageClass that does not exist.
- Files: `README.md`, `task.md`, `inject.sh`, `verify.sh`

### `pvc_pending_wrong_binding_mode`
- Domain: Storage
- Namespace: `pvc-pending-wrong-binding-mode`
- Failure pattern: Incorrect `volumeBindingMode` blocks binding/scheduling flow.
- Files: `task.md`, `solutions.md`, `inject.sh`, `verify.sh`

## Execution pattern

```bash
cd scenarios/<scenario-name>
bash inject.sh
# troubleshoot/fix
bash verify.sh
```
