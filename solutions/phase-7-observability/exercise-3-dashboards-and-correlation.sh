#!/bin/bash

set -e

CHART_DIR="exercises/phase-4-gitops/demo-app"
NAMESPACE="gitops-demo"

echo "[INFO] Starting background load generator (Ctrl+C to stop)"
kubectl run curl-load --restart=Never --image=curlimages/curl -n "$NAMESPACE" -- \
  sh -c "while true; do curl -s http://demo-app > /dev/null; sleep 0.2; done" &
LOAD_PID=$!

echo "[INFO] Triggering deployment: scaling to 4 replicas"
helm upgrade demo-app "$CHART_DIR" -n "$NAMESPACE" --set replicaCount=4

echo "[INFO] Deployment history:"
helm history demo-app -n "$NAMESPACE"

echo ""
echo "[INFO] Paste these into Grafana panels:"
echo '  sum(rate(nginx_http_requests_total{namespace="'"$NAMESPACE"'"}[1m])) by (pod)'
echo '  kube_deployment_status_replicas{deployment="demo-app", namespace="'"$NAMESPACE"'"}'

echo ""
echo "[DONE] Load generator running in background (PID $LOAD_PID)."
echo "Stop it with: kubectl delete pod curl-load -n $NAMESPACE"
