## Exercise 3: Packaging and Repositories

**Objective:** Package your Helm chart into a versioned artifact and publish it to a chart repository. By the end of this exercise, you will understand how Helm charts are versioned, packaged, indexed, and consumed from repositories, enabling reuse and distribution.

## Background

Helm charts are distributed as versioned `.tgz` packages through **chart repositories**. A chart repository is simply a web-accessible location that hosts packaged charts along with an `index.yaml` file describing available versions.

Packaging charts enables:

* Versioned releases
* Rollbacks to known-good versions
* Sharing charts across teams and environments
* Automation through CI/CD pipelines

In this exercise, you will package your chart, create a local chart repository, and install your chart from that repository instead of from the local filesystem.

## Steps

### 1. Update chart metadata

Open `Chart.yaml` in your chart directory and ensure the metadata is accurate and versioned correctly:

```yaml
apiVersion: v2
name: demo-app
description: A demo application packaged with Helm
version: 0.1.0
appVersion: "1.0.0"
```

* **version** refers to the chart version (used by Helm)
* **appVersion** refers to the application version (informational)

Increment the chart version whenever templates or defaults change.

### 2. Package the chart

From the directory **above** your chart folder, package it:

```bash
helm package demo-app
```

This creates a file similar to:

```text
demo-app-0.1.0.tgz
```

This file is the distributable Helm chart artifact.

### 3. Create a local chart repository directory

Create a directory to act as a local Helm repository:

```bash
mkdir -p ~/helm-repo
mv demo-app-0.1.0.tgz ~/helm-repo
cd ~/helm-repo
```

Generate an index file:

```bash
helm repo index .
```

You should now have:

* `demo-app-0.1.0.tgz`
* `index.yaml`

The `index.yaml` file contains metadata Helm uses to locate chart versions.

### 4. Serve the repository locally

Start a simple HTTP server to expose the repository:

```bash
python3 -m http.server 8080
```

Leave this terminal open. The repository is now available at:

```
http://localhost:8080
```

### 5. Add the repository to Helm

In a new terminal, add the repository:

```bash
helm repo add demo-repo http://localhost:8080
helm repo update
```

Verify the repository:

```bash
helm search repo demo-repo
```

You should see `demo-repo/demo-app` listed.

### 6. Install the chart from the repository

Install the chart using the repository reference:

```bash
helm install demo-app demo-repo/demo-app \
  --namespace helm-demo \
  --create-namespace
```

Verify the deployment:

```bash
kubectl get all -n helm-demo
```

Confirm that the resources were created successfully.

### 7. Upgrade the chart version

Make a small change to the chart (for example, update `values.yaml` or a label in a template), then increment the chart version in `Chart.yaml`:

```yaml
version: 0.1.1
```

Repackage and update the repository index:

```bash
helm package demo-app
mv demo-app-0.1.1.tgz ~/helm-repo
cd ~/helm-repo
helm repo index . --merge index.yaml
```

Update your Helm repositories:

```bash
helm repo update
```

Upgrade the release:

```bash
helm upgrade demo-app demo-repo/demo-app -n helm-demo
```

Verify the upgrade:

```bash
helm list -n helm-demo
helm history demo-app -n helm-demo
```

## Verification

* Chart is packaged as a `.tgz` file
* Repository contains a valid `index.yaml`
* Chart is installable via `helm repo add`
* Chart upgrades work using versioned packages
* Helm history shows multiple revisions

## Common Issues

### Repository not found

If `helm repo add` fails:

* Confirm the HTTP server is running
* Verify the correct port and URL
* Ensure `index.yaml` exists at the repository root

### Chart not listed

If `helm search repo` returns nothing:

* Run `helm repo update`
* Confirm the chart name in `Chart.yaml` matches expectations
* Inspect `index.yaml` for formatting errors

### Upgrade does not apply changes

If `helm upgrade` succeeds but nothing changes:

* Confirm the chart version was incremented
* Check that templates reference updated values
* Review rendered output with `helm template`

### Index overwrite

If multiple chart versions disappear:

* Use `helm repo index --merge index.yaml` instead of regenerating the index
* Ensure old `.tgz` files remain in the repository directory

## Next Steps

You now understand how Helm charts are packaged, versioned, and distributed. In the final exercise, you will focus on **release management**, learning how to inspect releases, perform rollbacks, and safely manage application lifecycle changes in Kubernetes.

Continue to [Exercise 4: Release Management](exercise-4-release-management.md).
