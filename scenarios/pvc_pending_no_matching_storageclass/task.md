<!-- pvc_pending_no_matching_storageclass/task.md -->
# Task: Fix Storage Provisioning

## Domain
Storage

## Namespace
`stg-lab`

## Objective
A web workload in the `stg-lab` namespace is not becoming Ready due to a storage provisioning issue.

## Success criteria
- The PVC `web-data` is **Bound**
- Deployment `web` has **2/2 Ready** pods
- Service `web` responds with HTTP 200 and body contains `ok` from within the cluster

## Constraints
- Do not delete and recreate the namespace
- Do not delete the Deployment `web`
- Do not delete the PVC `web-data`
- You may edit Kubernetes resources and create additional Kubernetes resources as needed

## Allowed tools
- `kubectl`

