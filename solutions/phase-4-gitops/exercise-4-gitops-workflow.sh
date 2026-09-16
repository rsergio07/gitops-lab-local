#!/bin/bash

set -e

APP_NAME="demo-app"
CHART_DIR="exercises/phase-4-gitops/demo-app"
VALUES_FILE="$CHART_DIR/values.yaml"

echo "[INFO] Current replica count:"
kubectl get deployment demo-app -n gitops-demo -o jsonpath='{.spec.replicas}'
echo ""

echo "[INFO] Bumping replicaCount to 3 in $VALUES_FILE"
sed -i.bak 's/^replicaCount:.*/replicaCount: 3/' "$VALUES_FILE"
rm -f "$VALUES_FILE.bak"

echo "[DONE] Now commit and push the change yourself:"
echo "  git add $VALUES_FILE"
echo "  git commit -m 'Scale demo-app to 3 replicas'"
echo "  git push origin <your-branch>"
echo ""
echo "Then watch it apply automatically with:"
echo "  argocd app get $APP_NAME --refresh"
