# Task: Fix persistent storage so the workload becomes Ready

Namespace: pvc-pending-wrong-binding-mode

## Objective
A Deployment named `web` must become Ready and stay Ready.

## Success Criteria
- `kubectl get deploy -n pvc-pending-wrong-binding-mode web` shows AVAILABLE >= 1
- `kubectl get pvc -n pvc-pending-wrong-binding-mode web-data` is `Bound`
- `kubectl get pods -n pvc-pending-wrong-binding-mode -l app=web` shows the Pod `Ready`

## Constraints
- Do not delete and recreate the Deployment.
- Do not delete and recreate the PVC.
- Fix using Kubernetes-native operations (edit/patch/apply/create), no node SSH required.

## Allowed Tools
- kubectl (get/describe/logs/events/edit/patch/apply)

