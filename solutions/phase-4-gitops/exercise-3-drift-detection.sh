#!/bin/bash

set -e

APP_NAME="demo-app"
NAMESPACE="gitops-demo"
MANIFEST="application.yaml"

echo "[INFO] Introducing manual drift (scaling to 5 replicas)"
kubectl scale deployment demo-app -n "$NAMESPACE" --replicas=5

echo "[INFO] Refreshing and diffing Application state"
argocd app get "$APP_NAME" --refresh
argocd app diff "$APP_NAME" || true

echo "[INFO] Manually resyncing"
argocd app sync "$APP_NAME"
kubectl get deployment demo-app -n "$NAMESPACE"

echo "[INFO] Enabling automated sync with self-heal and prune"
python3 - "$MANIFEST" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
content = content.replace(
    "  syncPolicy: {}",
    "  syncPolicy:\n    automated:\n      selfHeal: true\n      prune: true\n    syncOptions:\n      - CreateNamespace=true",
)
with open(path, "w") as f:
    f.write(content)
PYEOF
kubectl apply -f "$MANIFEST"

echo "[INFO] Re-introducing drift to demonstrate self-heal"
kubectl scale deployment demo-app -n "$NAMESPACE" --replicas=5

echo "[INFO] Waiting for self-heal to revert the change (up to ~3 minutes)..."
for i in $(seq 1 18); do
  CURRENT=$(kubectl get deployment demo-app -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
  echo "  replicas: $CURRENT (attempt $i/18)"
  if argocd app get "$APP_NAME" | grep -q "Synced"; then
    break
  fi
  sleep 10
done

echo "[SUCCESS] Final state:"
argocd app get "$APP_NAME"
kubectl get deployment demo-app -n "$NAMESPACE"

echo "[DONE] Exercise 3 completed"
