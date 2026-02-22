#!/bin/bash
set -e
NAMESPACE="bf-001-lab"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: non-existent-provisioner
EOF

cat <<'EOF' | kubectl apply -n "$NAMESPACE" -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: data-processor
spec:
  serviceName: data-processor
  replicas: 3
  selector:
    matchLabels:
      app: data-processor
  template:
    metadata:
      labels:
        app: data-processor
    spec:
      containers:
      - name: processor
        image: busybox:1.35
        command: ["sleep", "3600"]
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 1Gi
EOF
