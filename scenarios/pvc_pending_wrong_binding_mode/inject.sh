#!/usr/bin/env bash
set -euo pipefail

NS="pvc-pending-wrong-binding-mode"
SC="local-path-immediate"
APP="web"
PVC="web-data"

kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}" >/dev/null

# Baseline: nginx Deployment (no PVC yet) becomes Ready
cat <<'YAML' | kubectl apply -n "${NS}" -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
YAML

kubectl rollout status -n "${NS}" deploy/"${APP}" --timeout=120s >/dev/null

# Fault injection: create a StorageClass that looks legit but uses Immediate binding
# (subtle for local PV provisioners on multi-node clusters).
cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${SC}
provisioner: rancher.io/local-path
volumeBindingMode: Immediate
reclaimPolicy: Delete
allowVolumeExpansion: true
YAML

# Create a PVC that uses the subtly wrong StorageClass
cat <<YAML | kubectl apply -n "${NS}" -f - >/dev/null
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC}
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ${SC}
  resources:
    requests:
      storage: 1Gi
YAML

# Patch the existing Deployment to mount the PVC (using patch to avoid partial-apply pitfalls)
kubectl patch -n "${NS}" deploy/"${APP}" --type='strategic' -p "{
  \"spec\": {
    \"template\": {
      \"spec\": {
        \"volumes\": [
          {\"name\": \"data\", \"persistentVolumeClaim\": {\"claimName\": \"${PVC}\"}}
        ],
        \"containers\": [
          {
            \"name\": \"nginx\",
            \"volumeMounts\": [
              {\"name\": \"data\", \"mountPath\": \"/usr/share/nginx/html\"}
            ]
          }
        ]
      }
    }
  }
}" >/dev/null

# Wait briefly for the rollout attempt to begin, but do not wait for success.
kubectl rollout status -n "${NS}" deploy/"${APP}" --timeout=15s >/dev/null 2>&1 || true

echo "Hint: inspect storage classes, PVC status, and pod events in this namespace."

