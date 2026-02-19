#!/bin/bash
set -e

NAMESPACE="dev-team"
EXPECTED_PODS=3

echo "Verifying scenario: BF-001 Resource Quota"
echo ""

# Check namespace exists
if ! kubectl get namespace $NAMESPACE &>/dev/null; then
  echo "❌ FAIL: Namespace '$NAMESPACE' does not exist"
  exit 1
fi

# Check ResourceQuota exists
if ! kubectl get resourcequota -n $NAMESPACE &>/dev/null; then
  echo "❌ FAIL: No ResourceQuota found in namespace '$NAMESPACE'"
  exit 1
fi

# Count running pods
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)

echo "Running Pods in namespace: $RUNNING_PODS"

if [ "$RUNNING_PODS" -eq "$EXPECTED_PODS" ]; then
  echo "✅ PASS: All $EXPECTED_PODS pods are running"
  echo ""
  echo "ResourceQuota Status:"
  kubectl describe resourcequota -n $NAMESPACE
  exit 0
else
  echo "❌ FAIL: Expected $EXPECTED_PODS running pods, found $RUNNING_PODS"
  echo ""
  echo "Pod Status:"
  kubectl get pods -n $NAMESPACE -o wide
  echo ""
  echo "Pod Events:"
  kubectl describe pods -n $NAMESPACE
  exit 1
fi
