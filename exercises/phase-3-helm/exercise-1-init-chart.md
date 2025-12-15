## Exercise 1: Initialise a Helm Chart

**Objective:** Scaffold a new Helm chart from your Phase 1 Kubernetes manifests and explore its structure. By the end of this exercise you will have a basic chart that packages your application’s Deployment, Service and ConfigMap into a single, reusable unit.

### Steps

1. **Set up a working directory.**
   Navigate to a suitable location within your repository (e.g. `exercises/phase-3-helm`) where you want to create your chart. Make sure Helm is installed and in your `PATH`:

   ```bash
   helm version
   ```

   You should see a version string like `v3.x.x`.

2. **Create the chart skeleton.**
   Use Helm to scaffold a new chart called `demo-app` (or another name of your choosing):

   ```bash
   helm create demo-app
   ```

   This command creates a folder named `demo-app` with several files and subdirectories. Take note of:

   * `Chart.yaml` – contains chart metadata like name, version and description.
   * `values.yaml` – holds default configuration values.
   * `templates/` – contains template files for Kubernetes resources (deployment, service, etc.).
   * `_helpers.tpl` – defines reusable template functions.

3. **Inspect `Chart.yaml`.**
   Open `Chart.yaml` and update the `description`, `appVersion` and `version` fields to reflect your application. For example:

   ```yaml
   apiVersion: v2
   name: demo-app
   description: A demo application packaged with Helm
   version: 0.1.0
   appVersion: "1.0.0"
   ```

4. **Review `values.yaml`.**
   Examine the default values provided. They correspond to placeholders in the template files. Adjust the values to suit your application (e.g. set the container image name and tag).

5. **Replace default templates with your own.**
   The scaffolded chart includes a Deployment, Service and ingress template. Open the files in `templates/` and modify them to match the manifests you used in Phase 1. Remove templates you don’t need (for example, if you’re not using an ingress). Replace the `image.repository` and `image.tag` placeholders with values from `values.yaml`, using the templating syntax:

   ```yaml
   image:
     repository: "{{ .Values.image.repository }}"
     tag: "{{ .Values.image.tag }}"
     pullPolicy: IfNotPresent
   ```

6. **Render the chart locally.**
   Use `helm template` to render the chart into plain YAML without applying it to the cluster:

   ```bash
   helm template demo-app ./demo-app
   ```

   Inspect the output to ensure your Deployment, Service and ConfigMap render correctly.

7. **Lint the chart.**
   Run `helm lint` to check for common chart issues:

   ```bash
   helm lint ./demo-app
   ```

   Address any warnings or errors reported.

8. **(Optional) Install the chart.**
   Once you are satisfied with the chart structure, install it into your local cluster to verify it deploys properly:

   ```bash
   helm install demo-app ./demo-app --namespace helm-demo --create-namespace
   kubectl get all -n helm-demo
   ```

   When finished, you can remove the release with `helm uninstall demo-app -n helm-demo`.

### Verification

* The chart directory contains `Chart.yaml`, `values.yaml` and a `templates/` folder.
* `helm template` renders the expected Deployment, Service and ConfigMap without errors.
* `helm lint` reports no errors or critical warnings.
* (Optional) Installing the chart creates the expected resources in Kubernetes.

### Common Issues

* **Helm not installed:** If `helm version` fails, install Helm v3 from [helm.sh](https://helm.sh/docs/intro/install/).
* **Unused templates:** If you’re not using ingress or service templates, delete or comment them out to prevent Helm from rendering unwanted resources.
* **Incorrect image values:** Ensure `image.repository` and `image.tag` in `values.yaml` correspond to a valid container image that your cluster can pull.

### Next Steps

You’ve created the foundation of your Helm chart and learned how its structure maps to Kubernetes resources. In the next exercise you’ll dive into Helm’s templating language, adding variables and conditionals to make your chart configurable via `values.yaml`.

Continue to [Exercise 2: Templating and Values](exercise-2-templating.md).