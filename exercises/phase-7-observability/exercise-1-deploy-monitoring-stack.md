## Exercise 1: Deploy the Monitoring Stack

**Objective:** Install `kube-prometheus-stack` with Helm and explore the Prometheus and Grafana UIs it provides out of the box.

### Steps

1. **Add the Prometheus community Helm repository.**

   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

2. **Create a namespace for the monitoring stack.**

   ```bash
   kubectl create namespace monitoring
   ```

3. **Install the chart.**

   ```bash
   helm install kube-prometheus prometheus-community/kube-prometheus-stack \
     --namespace monitoring \
     --set grafana.adminPassword=admin123
   ```

   This single Helm release deploys Prometheus, the Prometheus Operator, Alertmanager, Grafana, node-exporter, and kube-state-metrics — the same building blocks you'll rely on for the rest of this phase.

4. **Wait for everything to become ready.**

   ```bash
   kubectl wait --for=condition=available --timeout=300s deployment --all -n monitoring
   kubectl get pods -n monitoring
   ```

5. **Access the Prometheus UI.**

   ```bash
   kubectl port-forward svc/kube-prometheus-kube-prome-prometheus -n monitoring 9090:9090
   ```

   Visit `http://localhost:9090`. Under **Status → Targets**, you should see several targets already being scraped, including `kubelet`, `apiserver`, and `node-exporter`.

6. **Access the Grafana UI.**

   In a new terminal:

   ```bash
   kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80
   ```

   Visit `http://localhost:3000` and log in with username `admin` and the password you set in step 3.

7. **Explore a default dashboard.**

   In Grafana, open **Dashboards** and select **Kubernetes / Compute Resources / Cluster**. You should see live CPU and memory usage for your Minikube node, populated entirely from the stack you just installed.

### Verification

* `kubectl get pods -n monitoring` shows all pods `Running`.
* The Prometheus UI at `localhost:9090` lists multiple healthy targets under Status → Targets.
* The Grafana UI at `localhost:3000` loads and shows live data on a default Kubernetes dashboard.

### Common Issues

* **Pods stuck Pending:** This is the heaviest stack installed in the course. Increase Minikube's resources (`minikube start --cpus=4 --memory=8192`) if pods don't schedule.
* **Grafana shows a login error:** Confirm you used the password set with `--set grafana.adminPassword=...` at install time. If you skipped setting it, retrieve the generated one from the `kube-prometheus-grafana` Secret.
* **Targets show as "down" in Prometheus:** Give the stack a minute or two after all pods report Running — some targets take a short time to register.

### Next Steps

You have a fully functional monitoring stack collecting cluster-level metrics. In the next exercise, you'll extend it to scrape metrics from your own demo application.

Continue to [Exercise 2: Scrape Application Metrics](exercise-2-scrape-application-metrics.md).
