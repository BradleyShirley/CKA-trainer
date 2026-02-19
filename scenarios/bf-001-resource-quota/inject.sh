#!/bin/bash
set -e

NAMESPACE="dev-team"

# Create namespace
kubectl create namespace $NAMESPACE

# Create ResourceQuota that limits pods to 2
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-quota
  namespace: $NAMESPACE
spec:
  hard:
    pods: "2"
EOF

# Create a ConfigMap (uses no pod quota)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: $NAMESPACE
data:
  config.yaml: |
    app:
      name: demo-app
      version: v1
EOF

# Deploy 3 pods (will exceed quota of 2)
for i in {1..3}; do
  kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-$i
  namespace: $NAMESPACE
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
EOF
done

echo "Fault injected: 3 pods deployed against quota limit of 2"