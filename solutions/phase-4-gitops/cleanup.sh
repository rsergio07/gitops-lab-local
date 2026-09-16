#!/bin/bash

set -e

APP_NAME="demo-app"
NAMESPACE="gitops-demo"
ARGOCD_NAMESPACE="argocd"

echo "[INFO] Cleaning up Phase 4 resources..."

if kubectl get application "$APP_NAME" -n "$ARGOCD_NAMESPACE" &>/dev/null; then
  kubectl delete application "$APP_NAME" -n "$ARGOCD_NAMESPACE"
  echo "[SUCCESS] Application removed"
fi

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE"
  echo "[SUCCESS] Namespace $NAMESPACE deleted"
fi

read -p "Remove ArgoCD itself as well? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  kubectl delete namespace "$ARGOCD_NAMESPACE"
  echo "[SUCCESS] ArgoCD removed"
fi

rm -f application.yaml

echo "[DONE] Cleanup completed"
