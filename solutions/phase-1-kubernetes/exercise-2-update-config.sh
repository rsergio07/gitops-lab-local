#!/bin/bash

###############################################################################
# Exercise 2 Complete Solution Script
# 
# This script demonstrates ConfigMap updates and pod restarts
# Shows both edit and patch methods
###############################################################################

set -e  # Exit on any error

echo "=== Exercise 2: ConfigMap Updates ==="
echo ""

# Verify deployment exists
if ! kubectl get deployment demo-app -n demo-app &> /dev/null; then
    echo "Error: demo-app deployment not found. Run Exercise 1 first."
    exit 1
fi

echo "Current ConfigMap values:"
kubectl get configmap demo-app-config -n demo-app -o jsonpath='{.data}' | jq
echo ""

# Update ConfigMap using patch
echo "Updating ConfigMap..."
kubectl patch configmap demo-app-config -n demo-app --type merge -p '{
  "data": {
    "APP_ENV": "production",
    "LOG_LEVEL": "debug",
    "APP_NAME": "GitOps Demo Application (Updated)"
  }
}'
echo "✓ ConfigMap updated"
echo ""

echo "New ConfigMap values:"
kubectl get configmap demo-app-config -n demo-app -o jsonpath='{.data}' | jq
echo ""

# Restart deployment
echo "Restarting deployment to apply changes..."
kubectl rollout restart deployment/demo-app -n demo-app

# Wait for rollout to complete
echo "Waiting for rollout to complete..."
kubectl rollout status deployment/demo-app -n demo-app --timeout=120s
echo "✓ Rollout complete"
echo ""

# Verify pods restarted
echo "New pods:"
kubectl get pods -n demo-app
echo ""

# Check rollout history
echo "Rollout history:"
kubectl rollout history deployment/demo-app -n demo-app
echo ""

echo "=== Testing Updated Configuration ==="
echo "Running test to verify new config..."
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl -s http://demo-app-service:8080 || true
echo ""

echo "✓ Configuration update complete!"
echo ""
echo "To rollback if needed:"
echo "  kubectl rollout undo deployment/demo-app -n demo-app"