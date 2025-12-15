#!/bin/bash

set -e

RELEASE_NAME="demo-app"
REPO_NAME="demo-repo"
NAMESPACE="helm-demo"

echo "[INFO] Adding Helm repository"
helm repo add "$REPO_NAME" http://localhost:8080 || true
helm repo update

echo "[INFO] Installing Helm release"
helm install "$RELEASE_NAME" "$REPO_NAME/$RELEASE_NAME" \
  --namespace "$NAMESPACE" \
  --create-namespace

echo "[SUCCESS] Release installed"

echo "[INFO] Scaling deployment"
helm upgrade "$RELEASE_NAME" "$REPO_NAME/$RELEASE_NAME" \
  --set replicaCount=2 \
  -n "$NAMESPACE"

echo "[INFO] Simulating faulty upgrade"
helm upgrade "$RELEASE_NAME" "$REPO_NAME/$RELEASE_NAME" \
  --set image.tag=nonexistent \
  -n "$NAMESPACE" || true

echo "[INFO] Rolling back to previous revision"
helm rollback "$RELEASE_NAME" 1 -n "$NAMESPACE"

echo "[SUCCESS] Rollback completed"

echo "[INFO] Helm history:"
helm history "$RELEASE_NAME" -n "$NAMESPACE"

echo "[DONE] Exercise 4 completed"
