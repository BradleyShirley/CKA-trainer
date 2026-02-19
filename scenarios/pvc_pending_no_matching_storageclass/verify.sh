# pvc_pending_no_matching_storageclass/verify.sh
#!/usr/bin/env bash
set -euo pipefail

NS=stg-lab

# Namespace must exist
kubectl get ns "$NS" >/dev/null 2>&1

# PVC must be Bound
phase="$(kubectl -n "$NS" get pvc web-data -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [[ "$phase" != "Bound" ]]; then
  exit 1
fi

# Deployment must have 2 ready replicas
ready="$(kubectl -n "$NS" get deploy web -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "")"
if [[ "$ready" != "2" ]]; then
  exit 1
fi

# In-cluster HTTP check
kubectl -n "$NS" run verify-curl --image=curlimages/curl:8.7.1 --restart=Never --rm -i --quiet -- \
  sh -lc 'set -e; out="$(curl -sS -m 3 http://web)"; echo "$out" | grep -q ok' >/dev/null

exit 0

