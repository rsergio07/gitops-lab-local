# Phase 3: Helm Chart Creation

Package and manage your Kubernetes manifests with Helm charts to enable reuse, customization and versioning. This phase teaches you how to convert raw manifests into parameterised charts, package and publish them, and install and manage chart releases on your cluster.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)

  - [Helm Overview](#helm-overview)
  - [Chart Structure](#chart-structure)
  - [Templating and Values](#templating-and-values)
  - [Packaging and Repositories](#packaging-and-repositories)
  - [Release Management](#release-management)
  - [Best Practices](#best-practices)
- [Hands‑On Exercises](#hands-on-exercises)

  - [Exercise 1: Initialise a Helm Chart](exercise-1-init-chart.md)
  - [Exercise 2: Templating and Values](exercise-2-templating.md)
  - [Exercise 3: Packaging and Repositories](exercise-3-package-and-repo.md)
  - [Exercise 4: Release Management](exercise-4-release-management.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Helm is the de‑facto package manager for Kubernetes. It bundles your Kubernetes resources into versioned **charts** that can be parameterised and reused across environments. Charts make it easy to share applications, enforce standards and automate complex deployments. In this phase you will learn the anatomy of a Helm chart, how templating works with `values.yaml`, how to package and publish charts, and how to install, upgrade and rollback releases.

## Learning Objectives

By completing this phase, you will be able to:

1. **Explain what Helm is** and why it simplifies application deployment on Kubernetes.
2. **Create a Helm chart** from existing Kubernetes manifests using `helm create`.
3. **Use Helm’s templating language** to parameterise manifests via `values.yaml`.
4. **Package and version charts**, and publish them to a chart repository.
5. **Install, upgrade and rollback releases** using Helm commands.
6. **Apply best practices** for chart structure, naming conventions and dependency management.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phases 0–2** – your environment is validated, and you’re comfortable with Kubernetes basics and containerisation.
2. **Helm installed** – install Helm v3.7+ on your local machine (`brew install helm` on macOS, or see the official install guide).
3. **Access to a Kubernetes cluster** – Minikube or another cluster with sufficient resources.
4. **Basic understanding of YAML and templating syntax**.

## Theoretical Foundation

### Helm Overview

Helm packages Kubernetes resources into **charts**. A chart is a collection of files that describe a set of Kubernetes resources related to a single application. Helm charts can be installed, upgraded, rolled back and shared via chart repositories, enabling consistent and repeatable deployments.

### Chart Structure

A chart directory contains:

* `Chart.yaml` – chart metadata (name, version, description).
* `values.yaml` – default configuration values.
* `templates/` – YAML files and templates that render into Kubernetes manifests.
* Optional folders for **dependencies** and **hooks**.
  Understanding this structure is essential when creating or modifying charts.

### Templating and Values

Helm uses the Go template language to inject values from `values.yaml` into your manifests. You can define variables, use conditionals and iterate over lists. Values are overridden at install time with `--set` flags or custom values files, allowing the same chart to deploy differently across environments.

### Packaging and Repositories

Charts are versioned and packaged into `.tgz` archives using `helm package`. You can host these packages in a chart repository – a web server with an `index.yaml` listing available charts – or push them to an OCI registry. Consumers add your repository with `helm repo add` and install charts by name and version.

### Release Management

A **release** is an instance of a chart running in a cluster. Helm manages release lifecycle with:

* `helm install` – create a new release.
* `helm upgrade` – modify an existing release with new templates or values.
* `helm rollback` – revert to a previous release version.
* `helm uninstall` – remove a release and its resources.
  Helm tracks release history in the cluster so you can audit changes.

### Best Practices

Follow these guidelines when authoring charts:

* **Use semantic versioning** (`Chart.yaml` version field) to track breaking changes.
* **Keep templates simple** and use helpers in `_helpers.tpl` to reduce duplication.
* **Set sensible defaults** in `values.yaml` and validate inputs using the `required` function.
* **Document all configurable values** with comments in `values.yaml` and a README.
* **Manage dependencies** in `Chart.yaml` and lock versions with `Chart.lock`.

## Hands‑On Exercises

### Exercise 1: Initialise a Helm Chart

**Objective:** Scaffold a new Helm chart using `helm create`, explore its directory structure and identify key files like `Chart.yaml`, `values.yaml` and the `templates/` folder.

See [exercise-1-init-chart.md](exercise-1-init-chart.md) for complete instructions.

### Exercise 2: Templating and Values

**Objective:** Convert your raw Kubernetes manifests into Helm templates, using variables and conditionals. Populate `values.yaml` with sensible defaults and override them at install time.

See [exercise-2-templating.md](exercise-2-templating.md) for complete instructions.

### Exercise 3: Packaging and Repositories

**Objective:** Package your chart with `helm package`, version it appropriately, and publish it to a local chart repository. Add the repository and install the chart on your cluster.

See [exercise-3-package-and-repo.md](exercise-3-package-and-repo.md) for complete instructions.

### Exercise 4: Release Management

**Objective:** Install, upgrade and rollback your chart. Experiment with changing values, performing dry‑runs, viewing release history and rolling back to a previous version.

See [exercise-4-release-management.md](exercise-4-release-management.md) for complete instructions.

## Troubleshooting

### Template rendering errors

If `helm template` or `helm install` fails, check your template syntax. Go templates are whitespace‑sensitive. Use `helm lint` to catch common mistakes and `helm template` to preview rendered manifests before installing.

### Missing values

Helm fails when a template references a value not provided. Ensure all referenced keys exist in `values.yaml` or supply them via `--set`/`-f` flags. Use the `required` function to produce clear error messages for missing inputs.

### Chart version conflicts

When upgrading a chart, `helm upgrade` compares the new version against the existing release. Increment the version in `Chart.yaml` and `appVersion` to reflect application changes. Clear old builds if Helm complains about incompatible chart versions.

### Repository issues

If `helm repo add` or `helm install` can’t fetch your chart, verify the repository URL and ensure `index.yaml` lists the correct chart name and version. For OCI registries, login with `helm registry login` and use `helm push oci://...`.

### Uninstall doesn’t remove resources

Helm tracks only the resources it created. If you manually create additional resources (e.g. ConfigMaps or PVCs) outside the chart, `helm uninstall` will not remove them. Use labels and `kubectl delete` to clean up any stray resources.

## Next Steps

After mastering Helm chart creation and release management, you’ll be ready to integrate Helm into GitOps workflows and continuous delivery pipelines. The next phase will introduce tools like Argo CD to automate deployments and reconcile your Helm releases with git repositories.

Continue to [Phase 4 – GitOps and Continuous Delivery](../phase-4-gitops/README.md).

## Additional Resources

**Official Documentation:**
- [Helm Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices Guide](https://helm.sh/docs/topics/chart_best_practices/)
- [Kubernetes Helm Tutorial](https://kubernetes.io/docs/helm/)

**Video Tutorials:**
- [What is Helm? | Helm Concepts Explained](https://www.youtube.com/watch?v=kJscDZfHXrQ) – KodeKloud
