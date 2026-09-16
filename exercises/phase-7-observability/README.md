# Phase 7: Observability and Metrics

Deploy Prometheus and Grafana to see what your application and pipeline are actually doing. This final phase adds metrics collection, a ServiceMonitor for your demo application, PromQL queries, and a dashboard that correlates the deployments you've been triggering all course with real metric changes.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [The Three Pillars, and Why Metrics First](#the-three-pillars-and-why-metrics-first)
  - [Prometheus Architecture](#prometheus-architecture)
  - [ServiceMonitors and the Operator Pattern](#servicemonitors-and-the-operator-pattern)
  - [PromQL and Dashboards](#promql-and-dashboards)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Deploy the Monitoring Stack](exercise-1-deploy-monitoring-stack.md)
  - [Exercise 2: Scrape Application Metrics](exercise-2-scrape-application-metrics.md)
  - [Exercise 3: Dashboards and Deployment Correlation](exercise-3-dashboards-and-correlation.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Every previous phase ended with `kubectl get pods` as your main source of truth about whether something worked. That's fine for a training exercise, but it doesn't scale to a real system, and it tells you nothing about *how well* something is working — request latency, error rates, resource usage over time. Observability closes that gap: Prometheus collects time-series metrics from your cluster and applications, and Grafana turns those metrics into dashboards you can query and visualize.

This phase deploys the same `kube-prometheus-stack` used broadly in production, installed the same way you installed your own chart in Phase 3: with Helm. You'll then expose metrics from your demo application, tell Prometheus to scrape them with a ServiceMonitor, and finally build a small dashboard that shows what a deployment — the kind you've triggered manually, through ArgoCD, and now through GitHub Actions — actually looks like in the metrics.

## Learning Objectives

By completing this phase, you will be able to:

1. **Explain what metrics-based observability adds** beyond `kubectl get`/`describe` status checks.
2. **Deploy Prometheus and Grafana** using the `kube-prometheus-stack` Helm chart.
3. **Configure a ServiceMonitor** to scrape a custom application's metrics endpoint.
4. **Write basic PromQL queries** to inspect pod restarts, resource usage, and request rates.
5. **Build a Grafana panel** and correlate a deployment event with a visible metric change.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phases 0–6** – your demo application, Helm chart, and GitOps pipeline are all working.
2. **Sufficient cluster resources** – the monitoring stack is the heaviest addition in this course; ensure Minikube has at least 4 CPUs and 8 GB memory (`minikube start --cpus=4 --memory=8192` if you need to resize).
3. **Helm and kubectl working** – no new tools to install this phase.

## Theoretical Foundation

### The Three Pillars, and Why Metrics First

Observability is commonly described through three pillars: metrics, logs, and traces. Metrics are numeric measurements sampled over time — CPU usage, request counts, error rates — cheap to store and ideal for dashboards, alerting, and spotting trends. Logs are discrete, detailed records of individual events, useful for root-causing a specific failure once you know roughly when and where it happened. Traces follow a single request across multiple services. This phase focuses on metrics because they're the foundation the other two build on: a metric tells you *something* is wrong and roughly when; logs and traces (outside this course's scope) tell you exactly why.

### Prometheus Architecture

Prometheus works by **pulling** metrics: it periodically scrapes an HTTP endpoint (conventionally `/metrics`) that an application or exporter exposes in a simple text format, and stores each sample as a time series. This differs from systems where applications push metrics to a central collector. The `kube-prometheus-stack` Helm chart bundles Prometheus itself, the **Prometheus Operator** (which manages Prometheus's configuration declaratively), Grafana, and Alertmanager, along with exporters that already scrape cluster-level metrics like node and pod resource usage — so you get a working baseline before configuring anything application-specific.

### ServiceMonitors and the Operator Pattern

Rather than manually editing Prometheus's scrape configuration, the Prometheus Operator watches for `ServiceMonitor` custom resources and generates that configuration automatically. A ServiceMonitor selects Kubernetes Services by label and tells Prometheus which port and path to scrape on the pods behind them. This is the same declarative, Kubernetes-native pattern ArgoCD's `Application` resource uses in Phase 4 — you describe what you want watched, and a controller reconciles the underlying configuration.

### PromQL and Dashboards

PromQL is Prometheus's query language. A simple query like `up` returns whether each scrape target is currently reachable. `rate(http_requests_total[5m])` computes a per-second request rate over a 5-minute window from a counter metric. `kube_pod_container_status_restarts_total` (provided by kube-state-metrics, bundled in the stack) tracks pod restarts — useful for correlating with the CrashLoopBackOff scenarios from Phase 1. Grafana panels are built by pointing a visualization at a PromQL query; a dashboard is simply a collection of panels, and like everything else in this course, can be exported as JSON and versioned.

## Hands-On Exercises

### Exercise 1: Deploy the Monitoring Stack

**Objective:** Install `kube-prometheus-stack` with Helm and explore the default Prometheus and Grafana dashboards.

See [exercise-1-deploy-monitoring-stack.md](exercise-1-deploy-monitoring-stack.md) for complete instructions.

### Exercise 2: Scrape Application Metrics

**Objective:** Add a metrics exporter sidecar to the demo application and configure a ServiceMonitor so Prometheus scrapes it.

See [exercise-2-scrape-application-metrics.md](exercise-2-scrape-application-metrics.md) for complete instructions.

### Exercise 3: Dashboards and Deployment Correlation

**Objective:** Write PromQL queries, build a Grafana panel, then trigger a deployment and observe the metric change it causes.

See [exercise-3-dashboards-and-correlation.md](exercise-3-dashboards-and-correlation.md) for complete instructions.

## Troubleshooting

### Prometheus or Grafana pods stuck Pending

This is the heaviest stack in the course. Check node resources and increase Minikube's allocation if needed:

```bash
kubectl describe node minikube | grep -A 5 "Allocated resources"
minikube stop
minikube start --cpus=4 --memory=8192
```

### ServiceMonitor exists but no target appears in Prometheus

The Prometheus Operator only watches ServiceMonitors matching its own label selector. Check the Prometheus custom resource's `serviceMonitorSelector` and ensure your ServiceMonitor's labels match, or that it was deployed to a namespace the operator watches.

### Grafana shows "No data"

Confirm the underlying PromQL query returns results directly in the Prometheus UI first — Grafana only visualizes what Prometheus already has. An empty result in Prometheus means a scrape or label problem, not a Grafana problem.

### Can't log in to Grafana

The default `kube-prometheus-stack` admin credentials are stored in a Secret:

```bash
kubectl get secret -n monitoring <release-name>-grafana -o jsonpath="{.data.admin-password}" | base64 -d
```

### Metrics endpoint returns connection refused

Confirm the exporter sidecar is actually running and listening on the port your ServiceMonitor references:

```bash
kubectl get pods -n gitops-demo
kubectl logs <pod-name> -n gitops-demo -c metrics-exporter
```

## Next Steps

You've now built every layer of a real GitOps platform: raw manifests, containerization, Helm packaging, GitOps delivery with ArgoCD, infrastructure as code with Terraform, an automated CI/CD pipeline, and observability with Prometheus and Grafana. This mirrors the shape of production platforms used by SRE teams at scale — the skills transfer directly to cloud-hosted Kubernetes.

Return to the [Main README](../../README.md) to review the full learning path, or revisit [CONTRIBUTING.md](../../CONTRIBUTING.md) if you'd like to contribute improvements back to this training.

## Additional Resources

**Official Documentation:**
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [kube-prometheus-stack Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

**Video Tutorials:**
- [Prometheus and Grafana Tutorial (18 min)](https://www.youtube.com/watch?v=9TJx7QTrTyo) - TechWorld with Nana
