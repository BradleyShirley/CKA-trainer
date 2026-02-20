
=======================================================================================

STEP 1 — Confirm the failure
=======================================================================================

Run:

- NS=pvc-pending-wrong-binding-mode
- kubectl -n $NS get pods,pvc
- kubectl -n $NS describe pod -l app=web
- kubectl -n $NS describe pvc web-data
- kubectl get sc

##Expected findings:

* Pod waiting on PVC

* PVC Pending

* StorageClass uses Immediate binding



=======================================================================================

STEP 2 — Create corrected StorageClass (fast exam method)
=======================================================================================

Copy an existing StorageClass to save time:

kubectl get sc local-path-wrong-mode -o yaml > /tmp/local-path-wffc.yaml

Edit it:

- vim /tmp/local-path-wffc.yaml

Make these changes:

* metadata.name → local-path-wffc

* volumeBindingMode → WaitForFirstConsumer

IMPORTANT — remove these fields if present:

* metadata.resourceVersion

* metadata.uid

* metadata.creationTimestamp

* metadata.annotations (kubectl.kubernetes.io/last-applied-configuration)

Apply it:

- kubectl apply -f /tmp/local-path-wffc.yaml


=======================================================================================

STEP 3 — Update the PVC to use the correct StorageClass
=======================================================================================

NOTE: Edit the PVC (do not delete it).

Run:

- kubectl -n $NS edit pvc web-data

Change:

storageClassName: local-path-wrong-mode

To:

storageClassName: local-path-wffc

Save and exit.

=======================================================================================

STEP 4 — Restart the Pod to trigger rebinding
=======================================================================================

Run:

- kubectl -n $NS delete pod -l app=web

=======================================================================================

STEP 5 — Wait for recovery
=======================================================================================

Run:

- kubectl -n $NS get pvc web-data -w

Wait until status shows:

Bound

Press Ctrl+C when bound.

Then run:

- kubectl -n $NS rollout status deploy/web --timeout=120s
- kubectl -n $NS get pods -l app=web

=======================================================================================

STEP 6 — Verify
=======================================================================================

Run:

- bash verify.sh

Expected result:

PASS
