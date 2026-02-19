# Scenario: BF-001 - Resource Quota Enforcement

## Context
You are managing a multi-tenant cluster. A development team has reported that their application deployments are failing to schedule, but they cannot understand why. The cluster appears healthy, and similar workloads run fine in other namespaces.

## Your Task
Diagnose why new Pods in the `dev-team` namespace are failing to start, and restore the ability to deploy workloads while maintaining the intended resource constraints.

## Success Criteria
- All three Pods in the `dev-team` namespace must be in `Running` state
- The namespace must have an active ResourceQuota
- No resources should be deleted or recreated
- The fix must respect the quota design intent

## Constraints
- You cannot modify PersistentVolumeClaims
- You cannot change the namespace name
- You have 15 minutes to diagnose and fix