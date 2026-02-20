#!/usr/bin/env bash
set -euo pipefail

NS="pvc-pending-wrong-binding-mode"
SC_BAD="local-path-wrong-mode"
APP="web"
PVC="web-data"

kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}" >/dev/null

# Clean previous run safely
kubectl delete deploy "${APP}" -n "${NS}" --ignore-not-found >/dev/null
kubectl delete pvc "${PVC}" -n "${NS}" --ignore-not-found >/dev/null
kubectl delete sc "${SC_BAD}" --ignore-not-found >/dev/null

# Fault injection: StorageClass with incorrect binding mode
cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${SC_BAD}
provisioner: rancher.io/local-path
volumeBindingMode: Immediate
reclaimPolicy: Delete
allowVolumeExpansion: true
YAML

# Create PVC using the subtly wrong StorageClass
cat <<YAML | kubectl apply -n "${NS}" -f - >/dev/null
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${PVC}
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ${SC_BAD}
  resources:
    requests:
      storage: 1Gi
YAML

# Create Deployment that uses the PVC
cat <<YAML | kubectl apply -n "${NS}" -f - >/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP}
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
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: ${PVC}
YAML

# Allow rollout attempt to start (but remain unhealthy)
kubectl rollout status -n "${NS}" deploy/"${APP}" --timeout=15s >/dev/null 2>&1 || true

echo "Hint: inspect storage classes, PVC status, and pod events in this namespace."
