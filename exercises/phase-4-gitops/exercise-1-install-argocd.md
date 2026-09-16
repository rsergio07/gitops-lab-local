## Exercise 1: Install ArgoCD

**Objective:** Install ArgoCD into your Minikube cluster and confirm you can reach it through both the `argocd` CLI and the web UI.

### Steps

1. **Verify the ArgoCD CLI is installed.**

   ```bash
   argocd version --client
   ```

   You should see a client version string. If the command isn't found, install it with `brew install argocd`.

2. **Create the `argocd` namespace and install the components.**

   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

   This applies ArgoCD's official install manifest, which creates the API server, repository server, application controller, and supporting resources.

3. **Wait for the components to become ready.**

   ```bash
   kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
   kubectl get pods -n argocd
   ```

   All pods should show STATUS `Running`.

4. **Retrieve the initial admin password.**

   ArgoCD generates a random admin password on install and stores it in a Secret:

   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

   Copy the output — you'll use it to log in.

5. **Port-forward the ArgoCD API server.**

   In a dedicated terminal, forward local port 8080 to the ArgoCD server:

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

   Leave this running. ArgoCD is now reachable at `https://localhost:8080`.

6. **Log in with the CLI.**

   In a new terminal:

   ```bash
   argocd login localhost:8080 --username admin --password <password-from-step-4> --insecure
   ```

   The `--insecure` flag skips TLS verification, acceptable for this local, self-signed setup.

7. **Change the admin password.**

   ```bash
   argocd account update-password
   ```

   Follow the prompts to set a password you'll remember.

8. **Open the web UI.**

   Visit `https://localhost:8080` in your browser (accept the self-signed certificate warning) and log in with the `admin` account. You should see an empty Applications dashboard.

### Verification

* `kubectl get pods -n argocd` shows all pods `Running`.
* `argocd login localhost:8080` succeeds.
* The web UI loads and shows an empty Applications list.

### Common Issues

* **Pods stuck Pending:** ArgoCD needs extra cluster resources on top of earlier phases. Increase Minikube's CPU/memory allocation if needed (see the phase README's Troubleshooting section).
* **`argocd login` times out:** Confirm the `kubectl port-forward` command from step 5 is still running in its own terminal.
* **Password rejected:** Secrets can take a few seconds to populate after install. Re-run the `get secret` command from step 4 if the value looks empty.

### Next Steps

ArgoCD is installed and reachable, but it isn't managing anything yet. In the next exercise you'll commit your Helm chart to Git and create an Application that tells ArgoCD to deploy it.

Continue to [Exercise 2: Application Deployment](exercise-2-application-deployment.md).
