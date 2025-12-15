## Exercise 2: Templating and Values

**Objective:** Convert static Kubernetes manifests into Helm templates and parameterize them using `values.yaml`. By the end of this exercise, you will understand how Helm renders templates, how values are injected, and how configuration can be overridden per environment without modifying the templates themselves.

## Background

In Phase 1, you deployed applications using static YAML manifests. While this approach works, it does not scale well across environments. Helm solves this by introducing **templating**, allowing a single chart to generate different Kubernetes manifests based on provided values.

Helm templates use the Go templating language and are rendered at install or upgrade time. The rendered output is standard Kubernetes YAML that is sent to the Kubernetes API server. Understanding this rendering process is critical before using Helm in production or GitOps workflows.

## Steps

### 1. Review the existing chart structure

Navigate into the chart you created in Exercise 1:

```bash
cd demo-app
```

Inspect the contents of the `templates/` directory. You should see files such as:

* `deployment.yaml`
* `service.yaml`
* `configmap.yaml` (if you added one)
* `_helpers.tpl`

These files already contain Helm template expressions such as `{{ .Values }}` and `{{ .Chart }}`.

### 2. Parameterize the container image

Open `values.yaml` and ensure it contains image configuration similar to the following:

```yaml
image:
  repository: demo-app
  tag: "1.0.0"
  pullPolicy: IfNotPresent
```

Now open `templates/deployment.yaml` and update the container image section to reference these values:

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
```

This change allows the image to be modified without editing the template itself.

### 3. Parameterize replica count

In `values.yaml`, add or verify the following entry:

```yaml
replicaCount: 1
```

Update the Deployment template to reference this value:

```yaml
spec:
  replicas: {{ .Values.replicaCount }}
```

This enables scaling the application by changing a single value.

### 4. Use values for Service configuration

Add Service-related values to `values.yaml`:

```yaml
service:
  type: ClusterIP
  port: 80
  targetPort: 8080
```

Update `templates/service.yaml` to use these values:

```yaml
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
```

This makes the Service reusable across different deployment scenarios.

### 5. Use template helpers for labels

Open `_helpers.tpl`. You should see helper functions for common labels. For example:

```yaml
{{- define "demo-app.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
```

Use these helpers in your templates:

```yaml
labels:
  {{- include "demo-app.labels" . | nindent 4 }}
```

This ensures consistent labeling across all rendered resources.

### 6. Render the templates locally

Before installing the chart, render the templates to inspect the output:

```bash
helm template demo-app .
```

Review the generated YAML and confirm:

* All placeholders are replaced with actual values
* No `{{ }}` blocks remain
* The output matches valid Kubernetes manifests

### 7. Override values at install time

Install the chart with custom values:

```bash
helm install demo-app-test . \
  --set replicaCount=2 \
  --set image.tag=2.0.0 \
  --namespace helm-demo \
  --create-namespace
```

Verify the changes:

```bash
kubectl get deployment demo-app-test -n helm-demo
kubectl describe deployment demo-app-test -n helm-demo
```

Confirm that the replicas and image tag match the overridden values.

### 8. Clean up the release

When finished, remove the release:

```bash
helm uninstall demo-app-test -n helm-demo
```

## Verification

* Templates reference values from `values.yaml` instead of hardcoded values
* `helm template` renders valid Kubernetes YAML
* Overriding values with `--set` changes rendered output
* The application deploys successfully with overridden values

## Common Issues

### Templates fail to render

If `helm template` fails, check for:

* Missing keys in `values.yaml`
* Incorrect indentation
* Unclosed template blocks (`{{ if }}` without `{{ end }}`)

Run:

```bash
helm lint .
```

### Values not applied

If overridden values do not take effect:

* Verify the correct value path (e.g., `image.tag`)
* Ensure the template references the same path
* Check for quoted vs unquoted values where required

### YAML formatting errors

Helm renders YAML but does not validate Kubernetes schemas. Always inspect rendered output and use:

```bash
kubectl apply --dry-run=client -f rendered.yaml
```

if you save the output for validation.

## Next Steps

You now understand how Helm templates transform static manifests into reusable, configurable deployments. In the next exercise, you will package your chart and publish it to a chart repository so it can be versioned and consumed like any other software artifact.

Continue to [Exercise 3: Packaging and Repositories](exercise-3-package-and-repo.md).
