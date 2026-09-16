#!/bin/bash

set -e

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus"
APP_NAMESPACE="gitops-demo"

echo "[INFO] Cleaning up Phase 7 resources..."

kubectl delete pod curl-load -n "$APP_NAMESPACE" --ignore-not-found

if kubectl get servicemonitor demo-app -n "$NAMESPACE" &>/dev/null; then
  kubectl delete servicemonitor demo-app -n "$NAMESPACE"
  echo "[SUCCESS] ServiceMonitor removed"
fi

if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
  echo "[SUCCESS] Monitoring stack uninstalled"
fi

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE"
  echo "[SUCCESS] Namespace $NAMESPACE deleted"
fi

rm -f servicemonitor.yaml

echo "[DONE] Cleanup completed"
