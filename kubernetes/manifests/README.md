# Kubernetes Manifests

Raw Kubernetes YAML manifests for the GitOps demo application. These files are used in Phase 1 exercises to deploy applications using kubectl.

## Files

### namespace.yaml
Creates the `demo-app` namespace to isolate application resources.

**Usage:**
```bash
kubectl apply -f kubernetes/manifests/namespace.yaml
```

### configmap.yaml
Defines application configuration as key-value pairs. Contains environment variables, logging settings, and application behavior configuration.

**Usage:**
```bash
kubectl apply -f kubernetes/manifests/configmap.yaml -n demo-app
```

### deployment.yaml
Creates a Deployment managing 2 replica pods. Includes resource limits, health probes, and rolling update strategy. Currently uses nginx:alpine as a placeholder image until Phase 2 where you build the custom application image.

**Usage:**
```bash
kubectl apply -f kubernetes/manifests/deployment.yaml -n demo-app
```

### service.yaml
Exposes the application pods through a ClusterIP Service. Routes traffic to pods matching the `app: demo-app` label.

**Usage:**
```bash
kubectl apply -f kubernetes/manifests/service.yaml -n demo-app
```

## Apply All Manifests

Deploy all resources in order:
```bash
# Create namespace first
kubectl apply -f kubernetes/manifests/namespace.yaml

# Apply ConfigMap before Deployment references it
kubectl apply -f kubernetes/manifests/configmap.yaml

# Deploy application
kubectl apply -f kubernetes/manifests/deployment.yaml

# Create service
kubectl apply -f kubernetes/manifests/service.yaml
```

Or apply all at once:
```bash
kubectl apply -f kubernetes/manifests/ --recursive
```

## Verify Deployment
```bash
# Check all resources in namespace
kubectl get all -n demo-app

# Check ConfigMap
kubectl get configmap -n demo-app

# Check pod details
kubectl get pods -n demo-app -o wide

# Check service endpoints
kubectl get endpoints demo-app-service -n demo-app
```

## Cleanup
```bash
kubectl delete namespace demo-app
```

This removes the namespace and all resources within it.