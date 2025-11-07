# Exercise 3: Troubleshoot Pods

Diagnose and resolve common pod failure scenarios using kubectl diagnostic commands. This exercise builds troubleshooting skills essential for operating Kubernetes in production.

## Objective

Identify root causes of pod failures using kubectl describe, logs, and events. Practice systematic debugging approaches that apply to real-world operational issues.

## Prerequisites

- Exercise 1 and 2 completed
- demo-app namespace with running application
- Basic understanding of YAML syntax

## Steps

### Step 1: Create a Broken Deployment - Missing Image

Deploy a pod with an incorrect image name to simulate ImagePullBackOff errors.
```bash
kubectl run broken-image --image=nginx:nonexistent-tag -n demo-app
```

Expected output:
```
pod/broken-image created
```

Wait 10 seconds, then check the pod status:
```bash
kubectl get pod broken-image -n demo-app
```

Expected output shows STATUS "ImagePullBackOff" or "ErrImagePull":
```
NAME           READY   STATUS             RESTARTS   AGE
broken-image   0/1     ImagePullBackOff   0          15s
```

### Step 2: Diagnose Image Pull Failure

Use kubectl describe to identify why the image pull failed.
```bash
kubectl describe pod broken-image -n demo-app
```

Scroll to the Events section at the bottom. You should see messages like:
```
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  30s                default-scheduler  Successfully assigned demo-app/broken-image to minikube
  Normal   Pulling    15s (x2 over 30s)  kubelet            Pulling image "nginx:nonexistent-tag"
  Warning  Failed     15s (x2 over 30s)  kubelet            Failed to pull image "nginx:nonexistent-tag": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:nonexistent-tag": failed to resolve reference "docker.io/library/nginx:nonexistent-tag": docker.io/library/nginx:nonexistent-tag: not found
  Warning  Failed     15s (x2 over 30s)  kubelet            Error: ErrImagePull
```

The error clearly indicates the image tag does not exist in the registry.

### Step 3: Fix the Image Issue

Delete the broken pod and recreate with a valid image:
```bash
kubectl delete pod broken-image -n demo-app
kubectl run fixed-image --image=nginx:alpine -n demo-app
```

Verify the pod reaches Running state:
```bash
kubectl get pod fixed-image -n demo-app --watch
```

Press Ctrl+C once STATUS shows "Running".

### Step 4: Create a Crashing Container

Deploy a pod that crashes immediately on startup.
```bash
kubectl run crashing-pod --image=busybox --command -n demo-app -- sh -c "echo 'Starting...'; sleep 2; exit 1"
```

This pod runs a command that sleeps for 2 seconds then exits with error code 1.

Wait 30 seconds and check the pod status:
```bash
kubectl get pod crashing-pod -n demo-app
```

Expected output shows STATUS "CrashLoopBackOff" with increasing RESTARTS:
```
NAME            READY   STATUS             RESTARTS      AGE
crashing-pod    0/1     CrashLoopBackOff   3 (20s ago)   2m
```

### Step 5: Diagnose Crash Loop

View the current logs:
```bash
kubectl logs crashing-pod -n demo-app
```

Expected output:
```
Starting...
```

View logs from the previous crashed container:
```bash
kubectl logs crashing-pod -n demo-app --previous
```

This shows the same "Starting..." message, confirming the container crashes after printing this message.

Describe the pod to see restart events:
```bash
kubectl describe pod crashing-pod -n demo-app
```

Events section shows multiple "Back-off restarting failed container" messages with increasing backoff delays.

### Step 6: Understand CrashLoopBackOff Behavior

CrashLoopBackOff means Kubernetes repeatedly tries to restart a container that keeps failing. The backoff delay increases exponentially: 10 seconds, 20 seconds, 40 seconds, up to 5 minutes maximum. This prevents excessive resource consumption from containers that cannot start.

Common causes of CrashLoopBackOff:
- Application code errors that cause immediate exit
- Missing required environment variables
- Configuration file syntax errors
- Dependencies not available (database connection failures)
- Incorrect container command or entrypoint

Delete the crashing pod:
```bash
kubectl delete pod crashing-pod -n demo-app
```

### Step 7: Create a Pod with Resource Constraint Issues

Create a pod that requests more resources than the cluster can provide.
```bash
cat <<EOF | kubectl apply -n demo-app -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-constrained
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        memory: "64Gi"
        cpu: "32"
EOF
```

Check the pod status:
```bash
kubectl get pod resource-constrained -n demo-app
```

Expected output shows STATUS "Pending":
```
NAME                   READY   STATUS    RESTARTS   AGE
resource-constrained   0/1     Pending   0          10s
```

### Step 8: Diagnose Resource Scheduling Failure

Describe the pod to see why it cannot be scheduled:
```bash
kubectl describe pod resource-constrained -n demo-app
```

Events section shows:
```
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  15s   default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
```

This clearly indicates the cluster nodes do not have sufficient CPU or memory to satisfy the pod's resource requests.

Check node capacity:
```bash
kubectl describe node minikube | grep -A 5 "Allocated resources"
```

This shows the node's total capacity and how much is already allocated.

### Step 9: Fix Resource Constraints

Delete the pod with unrealistic resource requests:
```bash
kubectl delete pod resource-constrained -n demo-app
```

Create a pod with reasonable resource requests:
```bash
cat <<EOF | kubectl apply -n demo-app -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-fixed
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

Verify the pod starts successfully:
```bash
kubectl get pod resource-fixed -n demo-app --watch
```

Press Ctrl+C once STATUS shows "Running".

### Step 10: Create a Liveness Probe Failure

Deploy a pod with a liveness probe that always fails, causing Kubernetes to repeatedly restart the container.
```bash
cat <<EOF | kubectl apply -n demo-app -f -
apiVersion: v1
kind: Pod
metadata:
  name: failing-liveness
spec:
  containers:
  - name: app
    image: nginx:alpine
    livenessProbe:
      httpGet:
        path: /nonexistent
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
EOF
```

Wait 30 seconds and check the pod:
```bash
kubectl get pod failing-liveness -n demo-app
```

Expected output shows increasing RESTARTS:
```
NAME               READY   STATUS    RESTARTS      AGE
failing-liveness   1/1     Running   3 (10s ago)   1m
```

### Step 11: Diagnose Liveness Probe Failures

View pod events to see liveness probe failures:
```bash
kubectl describe pod failing-liveness -n demo-app
```

Events section shows:
```
Events:
  Warning  Unhealthy  30s (x6 over 1m)  kubelet  Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    30s (x2 over 50s) kubelet  Container app failed liveness probe, will be restarted
```

This indicates the liveness probe cannot reach the specified path, causing Kubernetes to restart the container assuming it is unhealthy.

Delete the failing pod:
```bash
kubectl delete pod failing-liveness -n demo-app
```

## Verification

Confirm understanding by explaining:

1. How to identify the root cause of ImagePullBackOff errors using kubectl describe

2. Why CrashLoopBackOff occurs and how the backoff delay increases over time

3. How to check if resource constraints prevent pod scheduling

4. The difference between current logs and previous logs when debugging crashes

5. How liveness probe failures cause container restarts

## Summary of Troubleshooting Commands

Key commands for pod debugging:
```bash
# Check pod status and recent events
kubectl get pods -n <namespace>
kubectl get pod <pod-name> -n <namespace> --watch

# View detailed pod information and events
kubectl describe pod <pod-name> -n <namespace>

# View container logs
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl logs <pod-name> -n <namespace> -c <container-name>  # For multi-container pods

# Check resource availability
kubectl top node
kubectl describe node <node-name>

# Interactive debugging
kubectl exec <pod-name> -n <namespace> -it -- sh
```

## Common Issues

**Cannot see events in kubectl describe:**
Events expire after 1 hour by default. If the pod has been running longer, events may not show the initial failure. Delete and recreate the pod to see fresh events.

**Logs command shows "previous terminated container not found":**
This occurs if the container never successfully started before crashing. Use `kubectl logs` without `--previous` flag to see current attempt logs.

**Unable to delete stuck pods:**
Use force delete if pods remain in Terminating state:
```bash
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0
```

## Success Criteria

You have successfully completed this exercise when you can:
- Identify ImagePullBackOff root causes from kubectl describe output
- Explain why CrashLoopBackOff occurs and view relevant logs
- Recognize resource constraint symptoms and check node capacity
- Use kubectl logs with --previous flag to debug crashed containers
- Understand how health probe failures cause restarts

## Next Steps

You have successfully diagnosed and resolved common Kubernetes pod failures. You now have the troubleshooting skills necessary to identify and fix issues in production environments.

You have completed Phase 1 and understand the foundational Kubernetes resources that all applications use. Phase 2 introduces containerization, where you will build Docker images for the demo application and understand how container images are constructed, layered, and optimized for production use.

Continue to [Phase 2: Containerization Basics](../phase-2-docker/README.md).