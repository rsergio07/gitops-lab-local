# Phase 7 Solutions

Reference solutions for Phase 7 exercises. Use these to verify your work or understand correct approaches when stuck.

## Using Solutions Responsibly

Attempt each exercise independently before consulting solutions. The learning happens through problem-solving and troubleshooting, not just reading correct answers. Solutions are provided to:

1. Verify your approach matches expected patterns
2. Understand alternative methods when stuck
3. Compare your implementation with best practices
4. Learn from detailed explanations in comments

## Solution Files

### Exercise 1: Deploy the Monitoring Stack

`exercise-1-deploy-monitoring-stack.sh` adds the Helm repo, installs `kube-prometheus-stack`, and waits for it to become ready. It prints the port-forward commands for Prometheus and Grafana rather than running them, since both block the terminal.

### Exercise 2: Scrape Application Metrics

`exercise-2-scrape-application-metrics.sh` writes the stub-status ConfigMap and the ServiceMonitor, and prints the deployment/service template snippets to add to your chart (a full sidecar patch, since it touches a file you've been customizing since Phase 3 rather than one this script owns outright).

### Exercise 3: Dashboards and Deployment Correlation

`exercise-3-dashboards-and-correlation.sh` starts a background load generator, triggers a `helm upgrade` scaling the deployment, and prints the PromQL queries to paste into Grafana.

**Key verification commands:**
```bash
kubectl get pods -n monitoring
curl http://localhost:9113/metrics
helm history demo-app -n gitops-demo
```

## Common Patterns

**Checking a metric exists before building a dashboard around it:**

1. Query it directly in the Prometheus UI or with `curl` against `/api/v1/query`
2. Only then add it to a Grafana panel

**Diagnosing a missing target:**

1. `kubectl get servicemonitor -A` to confirm it exists
2. Check its `release` label against `kubectl get prometheus -n monitoring -o yaml`
3. Check Prometheus's Targets page for the actual scrape error

## Notes

These solutions represent one correct approach. Valid alternatives may exist — for example, using `kube-state-metrics` alone (already bundled in the stack) rather than adding the nginx exporter sidecar, if application-specific metrics aren't required. The important outcomes are:

- The monitoring stack runs and collects both cluster and application metrics
- The ServiceMonitor pattern is understood, not just copy-pasted
- A deployment's effect is visible in a dashboard, not just inferred from `kubectl`
- You understand why each step is necessary
