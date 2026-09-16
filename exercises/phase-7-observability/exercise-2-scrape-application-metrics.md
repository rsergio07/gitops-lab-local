## Exercise 2: Scrape Application Metrics

**Objective:** Expose metrics from the demo application using an `nginx-prometheus-exporter` sidecar, then configure a ServiceMonitor so Prometheus scrapes them.

## Background

The cluster-level metrics from Exercise 1 tell you about nodes and pods in general, but nothing about your specific application's behavior. Since the demo app has used the `nginx:alpine` image since Phase 1, the simplest way to expose meaningful metrics is a sidecar container: `nginx-prometheus-exporter` reads nginx's built-in stub status page and re-exposes it in Prometheus's format on its own port.

## Steps

### 1. Add the exporter sidecar to your chart

In your Helm chart's deployment template (`exercises/phase-4-gitops/demo-app/templates/deployment.yaml`), add a second container alongside the existing one:

```yaml
        - name: metrics-exporter
          image: nginx/nginx-prometheus-exporter:1.1.0
          args:
            - "--nginx.scrape-uri=http://localhost:80/stub_status"
          ports:
            - name: metrics
              containerPort: 9113
```

### 2. Enable nginx's stub status endpoint

Add a `/stub_status` location so the exporter has something to scrape. Don't add a second `server {}` block in `conf.d/` for this — nginx only routes unmatched requests to one default server per port, so a separate block with no distinguishing `server_name` is unreachable in practice. Instead, override nginx's own `default.conf` with a ConfigMap that includes both the app's root location and `/stub_status` in the same server block:

```yaml
server {
  listen 80;
  server_name _;

  location /stub_status {
    stub_status on;
    allow 127.0.0.1;
    deny all;
  }

  location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
  }
}
```

Mount this ConfigMap into the `nginx` container at `/etc/nginx/conf.d/default.conf`, using `subPath: default.conf` so it replaces just that one file rather than the whole directory:

```yaml
          volumeMounts:
            - name: nginx-default-conf
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
      volumes:
        - name: nginx-default-conf
          configMap:
            name: nginx-default-conf
```

### 3. Expose the metrics port on the Service

Add the exporter's port to your chart's Service template. The container listens on port 80 (see your Phase 1 Deployment), so `targetPort` for `http` must be `80`:

```yaml
  ports:
    - name: http
      port: 8080
      targetPort: 80
    - name: metrics
      port: 9113
      targetPort: 9113
```

### 4. Upgrade the release

```bash
helm upgrade demo-app exercises/phase-4-gitops/demo-app -n gitops-demo
```

If you're managing this through ArgoCD from Phase 4, commit and push instead, and let it sync automatically.

### 5. Verify the metrics endpoint directly

```bash
kubectl port-forward svc/demo-app -n gitops-demo 9113:9113
curl http://localhost:9113/metrics
```

You should see Prometheus-format text output, including metrics like `nginx_http_requests_total`.

### 6. Create a ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-app
  namespace: monitoring
  labels:
    release: kube-prometheus
spec:
  selector:
    matchLabels:
      app: demo-app
  namespaceSelector:
    matchNames:
      - gitops-demo
  endpoints:
    - port: metrics
      interval: 15s
```

The `release: kube-prometheus` label matches the selector the Helm chart configured for its own Prometheus instance — without it, the Operator ignores this ServiceMonitor.

```bash
kubectl apply -f servicemonitor.yaml
```

### 7. Confirm Prometheus is scraping it

In the Prometheus UI (`localhost:9090`), go to **Status → Targets** and look for a target under `gitops-demo/demo-app`. It should show as `UP`.

## Verification

* `curl` against port 9113 on the demo-app Service returns Prometheus-format metrics.
* The ServiceMonitor is created without errors.
* Prometheus's Targets page shows the demo-app target as `UP`.

## Common Issues

### Target never appears in Prometheus

Confirm the ServiceMonitor's `release` label matches the label your `kube-prometheus-stack` release expects — check with `kubectl get prometheus -n monitoring -o yaml | grep -A 5 serviceMonitorSelector`.

### Exporter container fails to start

Check its logs directly:

```bash
kubectl logs <pod-name> -n gitops-demo -c metrics-exporter
```

A connection refused error usually means the `default.conf` ConfigMap isn't mounted correctly. Confirm the `subPath` matches the ConfigMap key exactly (`default.conf`) and that the mount path is `/etc/nginx/conf.d/default.conf`, not the directory.

### Metrics show but all values are zero

Generate some traffic before checking — an idle nginx has nothing to report beyond connection counts:

```bash
kubectl run curl-load --rm -it --restart=Never --image=curlimages/curl -n gitops-demo -- sh -c "for i in $(seq 1 20); do curl -s http://demo-app > /dev/null; done"
```

## Next Steps

Prometheus now collects metrics specific to your application, not just the cluster. In the final exercise, you'll query those metrics with PromQL, build a Grafana panel, and correlate a live deployment with the metric change it causes.

Continue to [Exercise 3: Dashboards and Deployment Correlation](exercise-3-dashboards-and-correlation.md).
