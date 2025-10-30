# Phase 1 Solutions

Reference solutions for Phase 1 exercises. Use these to verify your work or understand correct approaches when stuck.

## Using Solutions Responsibly

Attempt each exercise independently before consulting solutions. The learning happens through problem-solving and troubleshooting, not just reading correct answers. Solutions are provided to:

1. Verify your approach matches expected patterns
2. Understand alternative methods when stuck
3. Compare your implementation with best practices
4. Learn from detailed explanations in comments

## Solution Files

### Exercise 1: Deploy with Raw Manifests

The complete solution is the manifest files in `kubernetes/manifests/`. These files are already provided and used directly in the exercise. No separate solution file needed.

**Key verification commands:**
```bash
# Verify namespace created
kubectl get namespace demo-app

# Check all resources deployed
kubectl get all -n demo-app

# Verify ConfigMap data
kubectl get configmap demo-app-config -n demo-app -o yaml

# Check service endpoints
kubectl get endpoints demo-app-service -n demo-app

# Test connectivity
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

### Exercise 2: ConfigMap Changes

**Solution approach:**

1. Edit ConfigMap using `kubectl edit configmap demo-app-config -n demo-app`
2. Change values in the data section
3. Trigger rolling restart: `kubectl rollout restart deployment/demo-app -n demo-app`
4. Verify changes applied by testing application

**Alternative solution using patch:**
```bash
# Update ConfigMap programmatically
kubectl patch configmap demo-app-config -n demo-app --type merge -p '{"data":{"LOG_LEVEL":"debug","APP_ENV":"production"}}'

# Restart deployment to apply changes
kubectl rollout restart deployment/demo-app -n demo-app

# Wait for rollout completion
kubectl rollout status deployment/demo-app -n demo-app

# Verify changes
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

### Exercise 3: Troubleshoot Pods

Solutions for each troubleshooting scenario:

**ImagePullBackOff diagnosis:**
```bash
# Identify issue
kubectl describe pod <pod-name> -n demo-app | grep -A 10 Events

# Look for "Failed to pull image" or "image not found" messages
# Fix by correcting image name and recreating pod
kubectl delete pod <pod-name> -n demo-app
kubectl run fixed-pod --image=nginx:alpine -n demo-app
```

**CrashLoopBackOff diagnosis:**
```bash
# View current logs
kubectl logs <pod-name> -n demo-app

# View previous crash logs
kubectl logs <pod-name> -n demo-app --previous

# Check events for restart pattern
kubectl describe pod <pod-name> -n demo-app

# Common fixes:
# - Correct application startup command
# - Add missing environment variables
# - Fix configuration file syntax
# - Ensure dependencies are available
```

**Resource constraint diagnosis:**
```bash
# Check why pod is pending
kubectl describe pod <pod-name> -n demo-app | grep -A 5 Events

# Check node capacity
kubectl describe node minikube | grep -A 5 "Allocated resources"

# Fix by reducing resource requests or increasing cluster resources
kubectl delete pod <pod-name> -n demo-app

# Recreate with reasonable requests
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fixed-pod
  namespace: demo-app
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
EOF
```

**Liveness probe failure diagnosis:**
```bash
# Check probe configuration
kubectl get pod <pod-name> -n demo-app -o yaml | grep -A 10 livenessProbe

# View probe failure events
kubectl describe pod <pod-name> -n demo-app | grep -A 5 Unhealthy

# Fix by correcting probe path or adjusting timing
kubectl delete pod <pod-name> -n demo-app

# Recreate with correct probe
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fixed-pod
  namespace: demo-app
spec:
  containers:
  - name: app
    image: nginx:alpine
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
EOF
```

## Common Patterns

**Debugging workflow:**

1. Check pod status: `kubectl get pods -n <namespace>`
2. View detailed info: `kubectl describe pod <pod-name> -n <namespace>`
3. Check logs: `kubectl logs <pod-name> -n <namespace>`
4. Check previous logs if crashing: `kubectl logs <pod-name> -n <namespace> --previous`
5. Verify related resources (ConfigMap, Service, etc.)
6. Check node resources if pending: `kubectl describe node`

**Configuration update pattern:**

1. Update ConfigMap/Secret
2. Restart deployment: `kubectl rollout restart deployment/<name> -n <namespace>`
3. Monitor rollout: `kubectl rollout status deployment/<name> -n <namespace>`
4. Verify changes applied

**Quick verification commands:**
```bash
# Check everything in namespace
kubectl get all -n demo-app

# Watch resources update
kubectl get pods -n demo-app --watch

# Check resource consumption
kubectl top pods -n demo-app

# View resource YAML
kubectl get <resource> <name> -n demo-app -o yaml
```

## Notes

These solutions represent one correct approach. Valid alternatives may exist. The important outcomes are:

- Resources deploy successfully
- Pods reach Running state
- Services route traffic correctly
- You understand why each step is necessary
- You can troubleshoot issues independently