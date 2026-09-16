#!/bin/bash

set -e

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus"

echo "[INFO] Adding prometheus-community Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

echo "[INFO] Creating monitoring namespace"
kubectl create namespace "$NAMESPACE" 2>/dev/null || true

echo "[INFO] Installing kube-prometheus-stack"
helm install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  --set grafana.adminPassword=admin123

echo "[INFO] Waiting for deployments to become available"
kubectl wait --for=condition=available --timeout=300s deployment --all -n "$NAMESPACE"

echo "[SUCCESS] Monitoring stack installed:"
kubectl get pods -n "$NAMESPACE"

echo "[DONE] Run these in separate terminals to access the UIs:"
echo "  kubectl port-forward svc/${RELEASE_NAME}-kube-prome-prometheus -n $NAMESPACE 9090:9090"
echo "  kubectl port-forward svc/${RELEASE_NAME}-grafana -n $NAMESPACE 3000:80"
echo "Grafana login: admin / admin123"
