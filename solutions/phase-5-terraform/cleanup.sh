#!/bin/bash

set -e

WORKDIR="exercises/phase-5-terraform/terraform"

echo "[INFO] Cleaning up Phase 5 resources..."

if [ -d "$WORKDIR" ]; then
  cd "$WORKDIR"
  if [ -f "main.tf" ]; then
    terraform destroy -auto-approve || true
    echo "[SUCCESS] Terraform-managed resources destroyed"
  fi
fi

if kubectl get namespace legacy-ns &>/dev/null; then
  kubectl delete namespace legacy-ns
  echo "[SUCCESS] legacy-ns removed"
fi

echo "[DONE] Cleanup completed"
