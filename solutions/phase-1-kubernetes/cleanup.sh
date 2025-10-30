#!/bin/bash

###############################################################################
# Cleanup Script for Phase 1
# 
# Removes all resources created during Phase 1 exercises
###############################################################################

set -e  # Exit on any error

echo "=== Phase 1 Cleanup ==="
echo ""

echo "This will delete the demo-app namespace and all resources within it."
read -p "Continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Deleting namespace demo-app..."
kubectl delete namespace demo-app --ignore-not-found=true

echo "Waiting for namespace deletion..."
kubectl wait --for=delete namespace/demo-app --timeout=60s 2>/dev/null || true

echo ""
echo "✓ Cleanup complete!"
echo ""
echo "To verify:"
echo "  kubectl get all -n demo-app"
echo ""
echo "To redeploy:"
echo "  ./solutions/phase-1-kubernetes/exercise-1-complete-deployment.sh"