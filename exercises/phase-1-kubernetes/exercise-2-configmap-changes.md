# Exercise 2: ConfigMap Changes

Modify ConfigMap values and observe how Kubernetes propagates changes to running pods. This exercise demonstrates the difference between ConfigMaps mounted as environment variables versus volume mounts.

## Objective

Update ConfigMap data and trigger pod restarts to apply new configurations. Understand when pods automatically pick up changes versus when manual intervention is required.

## Prerequisites

- Exercise 1 completed with demo-app deployed and running
- Application pods in Running state in demo-app namespace

## Steps

### Step 1: Review Current Configuration

Check the current ConfigMap values.
```bash
kubectl get configmap demo-app-config -n demo-app -o yaml
```

Note the values under the `data` section. These provide configuration to the application pods.

### Step 2: Test Current Application Behavior

Access the application and observe its current configuration.
```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

Note the response which includes configuration values from the ConfigMap. Keep this output for comparison after making changes.

### Step 3: Update the ConfigMap

Edit the ConfigMap to change a configuration value.
```bash
kubectl edit configmap demo-app-config -n demo-app
```

This opens the ConfigMap in your default editor (usually vi or nano). Locate the data section and modify one or more values. For example, change:
```yaml
data:
  APP_ENV: "development"
  LOG_LEVEL: "info"
```

To:
```yaml
data:
  APP_ENV: "development-updated"
  LOG_LEVEL: "debug"
```

Save and exit the editor. You should see:
```
configmap/demo-app-config edited
```

### Step 4: Check Pod Configuration Without Restart

Immediately check if pods picked up the changes without restart.
```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

Compare this response to Step 2. The configuration values are still the old ones because the pods have not restarted yet.
```bash
# Check pod age to confirm they haven't restarted
kubectl get pods -n demo-app
```

The AGE column shows pods are still running from their original creation time.

### Step 5: Understand Environment Variable Behavior

ConfigMaps referenced as environment variables are set when the container starts. Changes to the ConfigMap do not automatically propagate to running containers. This is a fundamental limitation of environment variables in Kubernetes.

Verify this by examining how the ConfigMap is consumed:
```bash
kubectl get deployment demo-app -n demo-app -o yaml | grep -A 10 envFrom
```

The `envFrom` section shows the ConfigMap is loaded as environment variables, which explains why changes require a restart.

### Step 6: Restart Pods to Apply Changes

Trigger a rolling restart of the Deployment to apply the new configuration.
```bash
kubectl rollout restart deployment/demo-app -n demo-app
```

Expected output:
```
deployment.apps/demo-app restarted
```

Watch the rolling update process:
```bash
kubectl get pods -n demo-app --watch
```

You will see new pods created while old pods terminate:
```
NAME                        READY   STATUS              RESTARTS   AGE
demo-app-xxxxxxxxxx-xxxxx   1/1     Running             0          5m
demo-app-xxxxxxxxxx-xxxxx   1/1     Running             0          5m
demo-app-yyyyyyyyyy-yyyyy   0/1     ContainerCreating   0          2s
demo-app-yyyyyyyyyy-yyyyy   1/1     Running             0          8s
demo-app-xxxxxxxxxx-xxxxx   1/1     Terminating         0          5m
```

Press Ctrl+C once all pods are Running with new names and the old pods are terminated.

### Step 7: Verify Configuration Changes Applied

Test the application again to confirm it now uses the updated configuration.
```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

The response should now show the updated configuration values from Step 3.

### Step 8: Check Rollout History

View the Deployment's rollout history to see the restart recorded.
```bash
kubectl rollout history deployment/demo-app -n demo-app
```

Expected output shows multiple revisions:
```
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

Revision 2 corresponds to the restart triggered by the ConfigMap change.

View details of a specific revision:
```bash
kubectl rollout history deployment/demo-app -n demo-app --revision=2
```

### Step 9: Alternative Update Method

You can also update ConfigMaps using kubectl patch for programmatic changes:
```bash
kubectl patch configmap demo-app-config -n demo-app --type merge -p '{"data":{"LOG_LEVEL":"error"}}'
```

Expected output:
```
configmap/demo-app-config patched
```

This approach is useful in automation scripts or CI/CD pipelines where interactive editing is not possible.

### Step 10: Trigger Another Rolling Restart

After patching the ConfigMap, restart pods again to apply the change.
```bash
kubectl rollout restart deployment/demo-app -n demo-app
kubectl rollout status deployment/demo-app -n demo-app
```

Wait for the rollout to complete:
```
deployment "demo-app" successfully rolled out
```

Verify the new configuration:
```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -n demo-app -- curl http://demo-app-service:8080
```

## Verification

Confirm successful completion by checking:

1. ConfigMap shows updated values:
```bash
   kubectl get configmap demo-app-config -n demo-app -o yaml
```

2. Pods were restarted (AGE shows recent creation time):
```bash
   kubectl get pods -n demo-app
```

3. Application responds with new configuration values

4. Rollout history shows multiple revisions:
```bash
   kubectl rollout history deployment/demo-app -n demo-app
```

## Understanding Volume-Mounted ConfigMaps

If the ConfigMap were mounted as a volume instead of environment variables, Kubernetes would automatically update the files in the volume within 30-60 seconds of the ConfigMap change. However, the application would still need to reload its configuration to use the new values.

To see how ConfigMaps can be mounted as volumes, examine the volume mount section:
```bash
kubectl get deployment demo-app -n demo-app -o yaml | grep -A 20 volumeMounts
```

Note that environment variables provide simpler consumption but require restarts for updates, while volume mounts enable automatic updates but require application-level reload logic.

## Common Issues

**ConfigMap edit saved but values unchanged:**
Verify you saved the file correctly in the editor. Check the ConfigMap again with `kubectl get configmap -o yaml` to confirm your changes persisted.

**Pods not restarting after rollout restart:**
Wait 10-15 seconds for the rolling update to begin. If no activity after 30 seconds, check Deployment status with `kubectl describe deployment`.

**Application still shows old config after restart:**
Verify all pods have new names and recent AGE values. If some pods are still old, the rolling update may not have completed fully.

## Success Criteria

You have successfully completed this exercise when:
- ConfigMap contains updated values
- All pods have been recreated with new names
- Application responses reflect the new configuration
- You understand when pod restarts are required for ConfigMap changes

## Next Steps

You have successfully updated application configuration and observed how Kubernetes handles ConfigMap changes. You now understand the difference between environment variable and volume mount approaches, and when pod restarts are required.

In the next exercise, you will build troubleshooting skills by diagnosing and resolving common pod failure scenarios using kubectl diagnostic commands.

Continue to [Exercise 3: Troubleshoot Pods](exercise-3-troubleshoot-pods.md).