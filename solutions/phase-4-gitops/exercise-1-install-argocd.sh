#!/bin/bash

set -e

NAMESPACE="argocd"

echo "[INFO] Creating argocd namespace"
kubectl create namespace "$NAMESPACE" 2>/dev/null || true

echo "[INFO] Installing ArgoCD"
kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[INFO] Waiting for argocd-server to become available"
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n "$NAMESPACE"

echo "[SUCCESS] ArgoCD installed"

echo "[INFO] Initial admin password:"
kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "[DONE] Run the following in a separate terminal, then 'argocd login localhost:8080':"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
