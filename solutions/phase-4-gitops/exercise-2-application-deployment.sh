#!/bin/bash

set -e

APP_NAME="demo-app"
REPO_URL="${REPO_URL:-https://github.com/<your-username>/gitops-lab-local.git}"
BRANCH="${BRANCH:-main}"
CHART_PATH="exercises/phase-4-gitops/demo-app"
NAMESPACE="gitops-demo"
MANIFEST="application.yaml"

echo "[INFO] Generating Application manifest"
cat <<EOF > "$MANIFEST"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $REPO_URL
    targetRevision: $BRANCH
    path: $CHART_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: $NAMESPACE
  syncPolicy: {}
EOF

echo "[INFO] Applying Application"
kubectl apply -f "$MANIFEST"

echo "[INFO] State before sync:"
argocd app get "$APP_NAME"

echo "[INFO] Syncing"
argocd app sync "$APP_NAME"

echo "[SUCCESS] State after sync:"
argocd app get "$APP_NAME"

echo "[DONE] Exercise 2 completed"
