#!/bin/bash

set -e

NAMESPACE="helm-demo"
RELEASE_NAME="demo-app"
REPO_NAME="demo-repo"
REPO_DIR="$HOME/helm-repo"

echo "[INFO] Cleaning up Helm releases and namespaces..."

if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
  echo "[SUCCESS] Helm release removed"
fi

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE"
  echo "[SUCCESS] Namespace deleted"
fi

if helm repo list | grep -q "$REPO_NAME"; then
  helm repo remove "$REPO_NAME"
  echo "[SUCCESS] Helm repo removed"
fi

if [ -d "$REPO_DIR" ]; then
  rm -rf "$REPO_DIR"
  echo "[SUCCESS] Local Helm repository directory removed"
fi

echo "[DONE] Cleanup completed"
