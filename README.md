# CKA Trainer Lab

A reproducible, CKA-aligned Kubernetes training environment built for high-volume hands-on practice.

This project provides a structured scenario pack designed to run against a real kubeadm-based cluster hosted on Proxmox.

---

## 🎯 Purpose

The goal of this lab is to simulate the **Certified Kubernetes Administrator (CKA)** exam experience as closely as possible by using:

- Real Kubernetes cluster behavior
- Deterministic break/fix scenarios
- Golden snapshot discipline
- Proctor-style training workflow

This is **not** a simulated environment — all failures and fixes occur on a live cluster.

---

## 🧱 Lab Architecture

### Cluster

- Platform: Proxmox VMs  
- Topology:  
  - `cp1` → 192.168.1.40  
  - `w1` → 192.168.1.41  
  - `w2` → 192.168.1.42  
- Kubernetes: v1.34.x  
- Runtime: containerd  
- CNI: Calico  
- Ingress: ingress-nginx  
- Metrics: metrics-server  
- Storage: local-path (default)

---

## 🔒 Golden Snapshot Rule (CRITICAL)

Before starting **any** scenario:

👉 All nodes must be reverted to the `golden-cluster` snapshot.

Golden means:

- Control plane Ready  
- All worker nodes Ready  
- CNI healthy  
- CoreDNS healthy  
- metrics-server healthy  
- Default StorageClass present  
- No test workloads deployed  
- Clean `kube-system` namespace  

**Do not skip this step.**

---

## 📁 Repository Structure

cka-trainer/
├── scenario-pack.yaml # Scenario index and metadata
├── scenarios/
│ ├── TS-001-service-endpoints/
│ │ ├── setup.yaml # Creates lab resources
│ │ ├── break.sh # Injects failure
│ │ ├── verify.sh # Confirms fix
│ │ └── rubric.yaml # Scoring guidance
│ └── ...
├── tools/ # Helper utilities (optional)
└── README.md



## 🔄 Standard Scenario Workflow

### 0. Reset cluster (outside VM)

In Proxmox:

Revert cp1, w1, w2 → golden-cluster

qm rollback 400 golden-cluster
qm rollback 401 golden-cluster
qm rollback 402 golden-cluster

## 🔄 After Snapshot Revert (IMPORTANT)

Because the CKA lab uses VM snapshots, reverting to the `golden-cluster` snapshot also rewinds the local git repository to whatever commit existed at snapshot time.

This is expected behavior.

After every snapshot revert, run:

```bash
cd ~/cka-trainer
git pull --rebase

### 1. Enter scenario directory

cd ~/cka-trainer/scenarios/<SCENARIO_ID>
Example:

cd ~/cka-trainer/scenarios/TS-001-service-endpoints
2. Stage the lab
kubectl apply -f setup.yaml
./break.sh
Cluster is now intentionally misconfigured.

3. Troubleshoot and fix
Use only standard tools:

kubectl

bash

ssh

systemctl

journalctl

crictl

Match CKA exam behavior.

4. Verify the fix
./verify.sh
Scenario passes when verification succeeds.

5. Cleanup (recommended)
kubectl delete ns <scenario-namespace>
Or revert to golden snapshot.

🧠 Training Modes (when used with GPT proctor)
This repo is designed to pair with a custom GPT trainer.

Supported modes:

Proctor Mode → minimal hints, exam style

Coach Mode → guided learning

Exam Mode → timed multi-task simulation

Build Mode → generate new scenarios

The GPT never modifies the cluster directly — it only instructs the user.

🚫 What This Repo Does NOT Do
No fake kubectl output

No simulated clusters

No heavy automation

No production hardening

This lab prioritizes exam realism and repetition speed.

🧹 Repo Hygiene
If the working tree becomes dirty:

git reset --hard
git clean -fd
🚀 Future Enhancements
Planned improvements:

cka-run scenario launcher

weighted exam simulator

additional troubleshooting packs

cluster upgrade scenarios

etcd failure scenarios

📜 License
Personal training use. Modify freely for your own lab.

💪 Philosophy
Train like the exam.

Break real things

Fix under time pressure

Verify explicitly

Repeat until fast

Speed and pattern recognition win the CKA.


---

## ✅ Next step (recommended)

After adding this:

```bash
git add README.md
git commit -m "Add trainer README"
git push
