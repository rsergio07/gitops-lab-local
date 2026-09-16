## Exercise 3: Dashboards and Deployment Correlation

**Objective:** Write PromQL queries against your application's metrics, build a Grafana panel, then trigger a deployment and observe its effect on the metric in near real time.

## Background

This is the payoff of the entire course: a deployment isn't just a status you check with `kubectl get pods` — it's an event you can see happen in your metrics. This exercise ties Phase 7 back to everything before it, using a Helm upgrade (or an ArgoCD sync, if you'd rather trigger it through Git) as the deployment event you'll correlate against a live graph.

## Steps

### 1. Query request rate in Prometheus

Open the Prometheus UI (`localhost:9090`) and run:

```promql
rate(nginx_http_requests_total[1m])
```

This shows requests per second over the trailing minute, per pod. Generate some load first if the graph is flat:

```bash
kubectl run curl-load --rm -it --restart=Never --image=curlimages/curl -n gitops-demo -- sh -c "while true; do curl -s http://demo-app > /dev/null; sleep 0.2; done"
```

Let this run in a separate terminal for the rest of the exercise, and press Ctrl+C when you're done.

### 2. Query pod restarts

```promql
kube_pod_container_status_restarts_total{namespace="gitops-demo"}
```

This metric, from kube-state-metrics, is the same signal you diagnosed manually with `kubectl describe pod` back in Phase 1 — now visible as a time series instead of a point-in-time count.

### 3. Build a Grafana panel

In Grafana, create a new Dashboard, add a Panel, and set its query to:

```promql
sum(rate(nginx_http_requests_total{namespace="gitops-demo"}[1m])) by (pod)
```

Set the visualization to Time series, title it "Demo App Request Rate", and save the dashboard.

### 4. Add a second panel for replica count

```promql
kube_deployment_status_replicas{deployment="demo-app", namespace="gitops-demo"}
```

Title it "Demo App Replicas" and save.

### 5. Trigger a deployment

With your load generator from step 1 still running, trigger a visible change — scaling the deployment is the clearest signal for this exercise:

```bash
helm upgrade demo-app exercises/phase-4-gitops/demo-app -n gitops-demo --set replicaCount=4
```

Or, if you're driving this through Git and ArgoCD (Phase 4), commit the `replicaCount` change and push instead.

### 6. Watch both panels update

Return to your Grafana dashboard and set the time range to "Last 15 minutes" with auto-refresh enabled. You should see the "Demo App Replicas" panel step up to 4, and the "Demo App Request Rate" panel show a corresponding increase in aggregate throughput as more pods share the load.

### 7. Correlate with deployment history

Cross-reference the timestamp of the change with your deployment history:

```bash
helm history demo-app -n gitops-demo
```

or, if deployed through ArgoCD:

```bash
argocd app history demo-app
```

The revision timestamp should line up with the step change you saw in Grafana.

## Verification

* PromQL queries for request rate and pod restarts return real data in the Prometheus UI.
* A saved Grafana dashboard has at least two panels: request rate and replica count.
* Scaling the deployment produces a visible, timestamped step change in both panels.
* The panel's timestamp correlates with the corresponding entry in `helm history` or `argocd app history`.

## Common Issues

### Panels show "No data"

Verify the same query returns results directly in the Prometheus UI first. If Prometheus has no data, check the ServiceMonitor from Exercise 2 rather than troubleshooting Grafana.

### Replica panel doesn't step up

Confirm the `helm upgrade` (or Git push) actually completed and the new pods reached `Running`:

```bash
kubectl get pods -n gitops-demo
```

### Request rate panel is too noisy to read

Widen the `rate()` window (for example `[5m]` instead of `[1m]`) to smooth out short-term fluctuations from the load generator.

## Next Steps

You've completed the full course: from raw manifests in Phase 1 to a self-healing, automatically deployed, fully observable application. Every layer — containers, packaging, GitOps, infrastructure as code, CI/CD, and observability — is now something you've built and can explain, not just used.

Return to the [Main README](../../README.md) to review the complete learning path.
