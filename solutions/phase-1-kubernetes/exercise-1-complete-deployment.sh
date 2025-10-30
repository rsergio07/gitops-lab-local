#!/bin/bash

###############################################################################
# Exercise 1 Complete Solution Script
# 
# This script automates the complete deployment from Exercise 1
# Use for reference or to quickly deploy the application
###############################################################################

set -e  # Exit on any error

echo "=== Exercise 1: Complete Deployment ==="
echo ""

# Create namespace
echo "Creating namespace..."
kubectl apply -f kubernetes/manifests/namespace.yaml

# Wait for namespace to be ready
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/demo-app --timeout=30s
echo "✓ Namespace created"
echo ""

# Apply ConfigMap
echo "Creating ConfigMap..."
kubectl apply -f kubernetes/manifests/configmap.yaml
echo "✓ ConfigMap created"
echo ""

# Apply Deployment
echo "Creating Deployment..."
kubectl apply -f kubernetes/manifests/deployment.yaml

# Wait for deployment to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/demo-app -n demo-app
echo "✓ Deployment ready"
echo ""

# Apply Service
echo "Creating Service..."
kubectl apply -f kubernetes/manifests/service.yaml
echo "✓ Service created"
echo ""

# Verify deployment
echo "=== Verification ==="
echo ""

echo "Pods:"
kubectl get pods -n demo-app
echo ""

echo "Deployment:"
kubectl get deployment demo-app -n demo-app
echo ""

echo "Service:"
kubectl get service demo-app-service -n demo-app
echo ""

echo "Endpoints:"
kubectl get endpoints demo-app-service -n demo-app
echo ""

echo "=== Testing Connectivity ==="
echo "Running test pod to verify service..."
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl -s http://demo-app-service:8080 || true
echo ""

echo "✓ Deployment complete!"
echo ""
echo "To view logs:"
echo "  kubectl logs -l app=demo-app -n demo-app"
echo ""
echo "To clean up:"
echo "  kubectl delete namespace demo-app"