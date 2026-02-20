#!/usr/bin/env bash
set -euo pipefail

NS="pvc-pending-wrong-binding-mode"
APP="web"
PVC="web-data"

echo "[1/5] Checking namespace..."
kubectl get ns "${NS}" >/dev/null 2>&1

echo "[2/5] Checking PVC phase..."
phase="$(kubectl get pvc -n "${NS}" "${PVC}" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
[[ "${phase}" == "Bound" ]]

echo "[3/5] Checking Deployment availability..."
avail="$(kubectl get deploy -n "${NS}" "${APP}" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "")"
[[ "${avail}" =~ ^[0-9]+$ ]] && [[ "${avail}" -ge 1 ]]

echo "[4/5] Checking Pod readiness..."
ready="$(kubectl get pods -n "${NS}" -l app="${APP}" -o jsonpath='{range .items[*]}{range .status.conditions[*]}{.type}={.status}{"\n"}{end}{end}' 2>/dev/null | grep -c '^Ready=True$' || true)"
[[ "${ready}" -ge 1 ]]

echo "[5/5] Functional HTTP check..."
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

echo "PASS"
exit 0
