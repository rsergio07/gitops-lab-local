#!/bin/bash

set -e

WORKDIR="exercises/phase-5-terraform/terraform"
cd "$WORKDIR"

echo "[INFO] Introducing manual drift"
kubectl label namespace tf-demo managed-by=manual --overwrite

echo "[INFO] Detecting drift (no changes applied yet)"
terraform plan

echo "[INFO] Reconciling drift"
terraform apply -auto-approve
kubectl get namespace tf-demo --show-labels

echo "[INFO] Creating a namespace outside Terraform"
kubectl create namespace legacy-ns 2>/dev/null || true

echo "[INFO] Adding matching resource block"
cat <<'EOF' >> main.tf

resource "kubernetes_namespace" "legacy" {
  metadata {
    name = "legacy-ns"
  }
}
EOF

echo "[INFO] Importing legacy-ns into state"
terraform import kubernetes_namespace.legacy legacy-ns || true

echo "[INFO] Confirming zero drift after import"
terraform plan

echo "[INFO] Destroying only the imported namespace"
terraform destroy -target=kubernetes_namespace.legacy -auto-approve

echo "[SUCCESS] legacy-ns removed:"
kubectl get namespace legacy-ns 2>&1 || true

echo "[DONE] Exercise 3 completed. Run cleanup.sh to destroy remaining Phase 5 resources."
