#!/bin/bash
# Deploy custom image to Kubernetes and test connectivity (Exercise 4)

set -euo pipefail

NAMESPACE="container-demo"
MANIFEST="deployment.yaml"
IMAGE="localhost:5000/simple-app:0.2.0"

# Use Minikube's Docker environment
echo "Configuring shell for Minikube's Docker..."
eval $(minikube docker-env)

# Ensure registry is running in Minikube
if ! docker ps | grep -q "registry"; then
  echo "Starting local registry inside Minikube..."
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

# (Re)build and push the image if not present
if ! docker images | grep -q "$IMAGE"; then
  echo "Image $IMAGE not found in Minikube, please build and push it first (see Exercise 3)."
  exit 1
fi

echo "Creating namespace $NAMESPACE..."
kubectl create namespace "$NAMESPACE" 2>/dev/null || true

echo "Generating manifest..."
cat > "$MANIFEST" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-app
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simple-app
  template:
    metadata:
      labels:
        app: simple-app
    spec:
      containers:
        - name: simple-app
          image: $IMAGE
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: simple-app
  namespace: $NAMESPACE
spec:
  selector:
    app: simple-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
EOF

echo "Applying manifest..."
kubectl apply -f "$MANIFEST"

echo "Waiting for pods to become ready..."
kubectl rollout status deployment/simple-app -n "$NAMESPACE"

echo "Testing service connectivity from within the cluster..."
kubectl run curl --rm -it -n "$NAMESPACE" --image=curlimages/curl --restart=Never --command -- curl -s http://simple-app

echo "Cleaning up..."
kubectl delete namespace "$NAMESPACE"
rm -f "$MANIFEST"

echo "Deployment script completed."
