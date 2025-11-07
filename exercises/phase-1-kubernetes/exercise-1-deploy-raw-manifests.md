# Exercise 1: Deploy with Raw Manifests

Deploy the demo application to Kubernetes using kubectl and raw YAML manifests. This exercise demonstrates the fundamental workflow of declarative Kubernetes deployments.

## Objective

Create and apply Kubernetes manifests for a complete application stack including Deployment, Service, and ConfigMap. Verify all resources are created correctly and the application is accessible within the cluster.

## Prerequisites

- Phase 0 completed with validated environment
- kubectl context set to minikube
- Terminal open in the repository root directory

## Steps

### Step 1: Create Application Namespace

Create a dedicated namespace to isolate the application resources.
```bash
kubectl create namespace demo-app
```

Expected output:
```
namespace/demo-app created
```

Verify the namespace exists:
```bash
kubectl get namespaces
```

You should see `demo-app` in the list with STATUS "Active".

### Step 2: Review the Kubernetes Manifests

Before applying manifests, review their contents to understand what resources will be created.
```bash
# View the ConfigMap manifest
cat kubernetes/manifests/configmap.yaml

# View the Deployment manifest
cat kubernetes/manifests/deployment.yaml

# View the Service manifest
cat kubernetes/manifests/service.yaml
```

Note the key fields in each manifest:
- ConfigMap contains application configuration as key-value pairs
- Deployment specifies 2 replicas, container image, and resource limits
- Service uses ClusterIP type with selector matching deployment pod labels

### Step 3: Apply the ConfigMap

Apply the ConfigMap first since the Deployment references it.
```bash
kubectl apply -f kubernetes/manifests/configmap.yaml -n demo-app
```

Expected output:
```
configmap/demo-app-config created
```

Verify the ConfigMap was created:
```bash
kubectl get configmap -n demo-app
kubectl describe configmap demo-app-config -n demo-app
```

The describe output shows the data fields stored in the ConfigMap.

### Step 4: Deploy the Application

Apply the Deployment manifest to create the application pods.
```bash
kubectl apply -f kubernetes/manifests/deployment.yaml -n demo-app
```

Expected output:
```
deployment.apps/demo-app created
```

Watch the pods come online:
```bash
kubectl get pods -n demo-app --watch
```

Expected progression:
```
NAME                        READY   STATUS              RESTARTS   AGE
demo-app-xxxxxxxxxx-xxxxx   0/1     ContainerCreating   0          5s
demo-app-xxxxxxxxxx-xxxxx   1/1     Running             0          15s
demo-app-xxxxxxxxxx-xxxxx   0/1     ContainerCreating   0          5s
demo-app-xxxxxxxxxx-xxxxx   1/1     Running             0          15s
```

Press Ctrl+C once both pods show STATUS "Running" and READY "1/1".

### Step 5: Verify Pod Details

Examine one of the pods to understand its configuration.
```bash
# Get pod names
kubectl get pods -n demo-app

# Describe a specific pod (replace pod-name with actual name)
kubectl describe pod <pod-name> -n demo-app
```

Look for these sections in the output:
- **Labels**: Shows labels applied to the pod from the Deployment template
- **Containers**: Shows the container image, ports, and resource limits
- **Volumes**: Shows the ConfigMap mounted as a volume
- **Events**: Shows the timeline of pod creation including image pull and container start

### Step 6: Create the Service

Apply the Service manifest to expose the application.
```bash
kubectl apply -f kubernetes/manifests/service.yaml -n demo-app
```

Expected output:
```
service/demo-app-service created
```

Verify the Service was created:
```bash
kubectl get service -n demo-app
```

Expected output shows:
```
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
demo-app-service   ClusterIP   10.xxx.xxx.xxx  <none>        8080/TCP   10s
```

Note the CLUSTER-IP assigned to the Service.

### Step 7: Check Service Endpoints

Verify the Service found the pods using its selector.
```bash
kubectl get endpoints demo-app-service -n demo-app
```

Expected output shows two IP addresses (one for each pod replica):
```
NAME               ENDPOINTS                         AGE
demo-app-service   172.17.0.x:8080,172.17.0.y:8080   2m
```

If ENDPOINTS shows `<none>`, the Service selector does not match the pod labels. Verify labels match:
```bash
# Check Service selector
kubectl get service demo-app-service -n demo-app -o yaml | grep -A 5 selector

# Check pod labels
kubectl get pods -n demo-app --show-labels
```

### Step 8: Test Application Connectivity

Create a temporary pod to test connectivity to the Service from within the cluster.
```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- sh
```

This creates an interactive shell in a temporary pod. Once inside the pod, test the Service:
```bash
# Inside the test pod
curl http://demo-app-service:8080
curl http://demo-app-service:8080/health
```

Expected output from the first curl shows JSON response with hostname and version. The health endpoint should return status 200 OK.

Exit the test pod:
```bash
exit
```

The test pod is automatically deleted due to the `--rm` flag.

### Step 9: View Application Logs

Check the logs from the application pods to see request activity.
```bash
# View logs from all pods in the deployment
kubectl logs -l app=demo-app -n demo-app

# Follow logs in real-time from a specific pod
kubectl logs <pod-name> -n demo-app --follow
```

You should see log entries for the curl requests made in the previous step. Press Ctrl+C to stop following logs.

### Step 10: Inspect Deployment Status

Check the Deployment status to confirm it successfully rolled out.
```bash
kubectl get deployment demo-app -n demo-app
kubectl rollout status deployment/demo-app -n demo-app
```

Expected output:
```
deployment "demo-app" successfully rolled out
```

View detailed Deployment information:
```bash
kubectl describe deployment demo-app -n demo-app
```

Note the Replicas section showing desired, current, and available counts should all be 2.

## Verification

Confirm successful completion by checking:

1. Namespace `demo-app` exists:
```bash
   kubectl get namespace demo-app
```

2. ConfigMap contains expected data:
```bash
   kubectl get configmap demo-app-config -n demo-app -o yaml
```

3. Deployment shows 2/2 ready replicas:
```bash
   kubectl get deployment demo-app -n demo-app
```

4. Both pods are Running with 1/1 ready:
```bash
   kubectl get pods -n demo-app
```

5. Service has two endpoints:
```bash
   kubectl get endpoints demo-app-service -n demo-app
```

6. Application responds to requests (from test pod or port-forward)

## Common Issues

**Pods stuck in ContainerCreating:**
Wait 30 seconds. If still stuck, check events with `kubectl describe pod`. Common causes are image pull delays on first download.

**Service has no endpoints:**
Service selector does not match pod labels. Verify selector matches exactly using the commands in Step 7.

**Cannot reach Service from test pod:**
Verify Service exists and has endpoints. Check that you used the correct Service name and namespace in the curl command.

## Success Criteria

You have successfully completed this exercise when:
- All pods are Running with 1/1 ready
- Service has endpoints for both pods
- curl commands from test pod return successful responses
- Logs show request activity from your tests

## Next Steps

You have successfully deployed an application to Kubernetes using raw YAML manifests. You now understand how Deployments, Services, and ConfigMaps work together to run applications in Kubernetes.

In the next exercise, you will learn how to modify application configuration through ConfigMaps and observe how Kubernetes propagates these changes to running pods.

Continue to [Exercise 2: ConfigMap Changes](exercise-2-configmap-changes.md).