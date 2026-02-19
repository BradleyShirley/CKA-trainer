#!/usr/bin/env bash
set -euo pipefail

NS="pvc-pending-wrong-binding-mode"
APP="web"
PVC="web-data"

# Namespace must exist
kubectl get ns "${NS}" >/dev/null 2>&1

# PVC must be Bound
phase="$(kubectl get pvc -n "${NS}" "${PVC}" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
[[ "${phase}" == "Bound" ]]

# Deployment must have at least 1 available replica
avail="$(kubectl get deploy -n "${NS}" "${APP}" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "")"
[[ "${avail}" =~ ^[0-9]+$ ]] && [[ "${avail}" -ge 1 ]]

# Pod must be Ready
ready="$(kubectl get pods -n "${NS}" -l app="${APP}" -o jsonpath='{range .items[*]}{range .status.conditions[*]}{.type}={.status}{"\n"}{end}{end}' 2>/dev/null | grep -c '^Ready=True$' || true)"
[[ "${ready}" -ge 1 ]]

# Functional check: nginx should serve content (port-forward to the pod)
pod="$(kubectl get pods -n "${NS}" -l app="${APP}" -o jsonpath='{.items[0].metadata.name}')"
pf_pid=""
cleanup() {
  if [[ -n "${pf_pid}" ]]; then kill "${pf_pid}" >/dev/null 2>&1 || true; fi
}
trap cleanup EXIT

kubectl port-forward -n "${NS}" "pod/${pod}" 18080:80 >/dev/null 2>&1 &
pf_pid="$!"
sleep 1

curl -fsS "http://127.0.0.1:18080/" >/dev/null
exit 0

