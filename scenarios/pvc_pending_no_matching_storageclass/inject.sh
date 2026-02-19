# pvc_pending_no_matching_storageclass/inject.sh
#!/usr/bin/env bash
set -euo pipefail

NS=stg-lab

kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS" >/dev/null

# Baseline app (working)
cat <<'EOF' | kubectl -n "$NS" apply -f - >/dev/null
apiVersion: v1
kind: Service
metadata:
  name: web
  labels:
    app: web
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo:1.0.0
        args:
        - "-listen=:5678"
        - "-text=ok"
        ports:
        - containerPort: 5678
EOF

kubectl -n "$NS" rollout status deploy/web --timeout=180s >/dev/null

# Inject subtle storage fault: PVC references a StorageClass that does not exist
cat <<'EOF' | kubectl -n "$NS" apply -f - >/dev/null
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-data
  labels:
    app: web
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 128Mi
  storageClassName: localpath
EOF

# Patch deployment to consume the PVC (do NOT re-apply partial Deployment YAML)
kubectl -n "$NS" patch deployment web --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[]}
]' >/dev/null 2>&1 || true

kubectl -n "$NS" patch deployment web --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/volumes/-","value":{"name":"data","persistentVolumeClaim":{"claimName":"web-data"}}}
]' >/dev/null 2>&1 || true

kubectl -n "$NS" patch deployment web --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[]}
]' >/dev/null 2>&1 || true

kubectl -n "$NS" patch deployment web --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts/-","value":{"name":"data","mountPath":"/data"}}
]' >/dev/null 2>&1 || true

exit 0

