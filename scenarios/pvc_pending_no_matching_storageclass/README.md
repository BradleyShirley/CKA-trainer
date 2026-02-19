<!-- pvc_pending_no_matching_storageclass/README.md -->
# Lab: pvc_pending_no_matching_storageclass

## CKA domain
Storage

## Estimated difficulty
Medium

## Estimated time
20 minutes

## Prerequisites
- Cluster reverted to the `golden-cluster` snapshot baseline on all nodes
- `kubectl` configured and working

## How to run
1. Inject the scenario:
   ```bash
   bash inject.sh



2) Identify the issue
kubectl -n stg-lab get pods
kubectl -n stg-lab describe pod -l app=web
kubectl -n stg-lab get pvc web-data -o wide
kubectl -n stg-lab describe pvc web-data
kubectl get sc

3) Fix (create the missing StorageClass)

Create a StorageClass named localpath that uses the local-path-provisioner provisioner.

cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: localpath
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF


Wait for binding/scheduling:

kubectl -n stg-lab get pvc web-data -w

4) Confirm workload becomes Ready
kubectl -n stg-lab rollout status deploy/web --timeout=180s
kubectl -n stg-lab get pods -o wide
kubectl -n stg-lab get pvc web-data -o wide

5) Confirm service response from inside the cluster
kubectl -n stg-lab run t --image=curlimages/curl:8.7.1 --restart=Never --rm -i --quiet -- \
  sh -lc 'curl -sS http://web'

6) Verify with the provided script
bash verify.sh

Reset
kubectl delete ns stg-lab
kubectl delete sc localpath

