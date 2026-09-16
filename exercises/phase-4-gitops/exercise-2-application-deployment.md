## Exercise 2: Application Deployment

**Objective:** Commit your Phase 3 Helm chart to your Git fork, create an ArgoCD Application that tracks it, and perform your first sync.

## Background

Until now, your Helm chart has only ever existed on your local machine. GitOps requires the desired state to live in Git, so ArgoCD has something to read and reconcile against. This exercise moves your chart into version control and hands control of the deployment over to ArgoCD.

## Steps

### 1. Commit your chart to Git

If you haven't already, copy the `demo-app` chart you built in Phase 3 into your fork of this repository, for example under `exercises/phase-4-gitops/demo-app`. Commit and push it:

```bash
git add exercises/phase-4-gitops/demo-app
git commit -m "Add demo-app Helm chart for GitOps deployment"
git push origin <your-branch>
```

Note the HTTPS URL of your fork — you'll need it in the next step.

### 2. Create the Application manifest

Create a file named `application.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-username>/gitops-lab-local.git
    targetRevision: <your-branch>
    path: exercises/phase-4-gitops/demo-app
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-demo
  syncPolicy: {}
```

Leaving `syncPolicy` empty means ArgoCD will detect drift but wait for you to sync manually — useful for observing the states before automating them.

### 3. Apply the Application

```bash
kubectl apply -f application.yaml
```

### 4. Inspect the Application state

```bash
argocd app get demo-app
```

You should see `SYNC STATUS: OutOfSync` — ArgoCD has read your chart but hasn't applied it to the cluster yet — and `HEALTH STATUS: Missing`, since no resources exist yet.

### 5. Sync the Application

```bash
argocd app sync demo-app
```

Watch the sync progress in the terminal, or switch to the web UI to see the resource tree render as ArgoCD creates each object.

### 6. Verify the deployment

```bash
argocd app get demo-app
kubectl get all -n gitops-demo
```

`SYNC STATUS` should now read `Synced` and `HEALTH STATUS` should read `Healthy`.

## Verification

* `application.yaml` is applied and visible with `kubectl get application demo-app -n argocd`.
* Before syncing, the Application shows `OutOfSync` / `Missing`.
* After `argocd app sync demo-app`, it shows `Synced` / `Healthy`.
* `kubectl get all -n gitops-demo` shows the Deployment, Service, and Pods from your chart.

## Common Issues

### Application stuck Unknown or repo error

Verify `repoURL` exactly matches your fork's HTTPS clone URL and that `targetRevision` is a branch or tag that exists. Check the repository server logs if the error persists:

```bash
kubectl logs -n argocd deployment/argocd-repo-server
```

### Health shows Degraded

Degraded usually means a Deployment isn't reaching its desired replica count. Diagnose it the same way you did in Phase 1:

```bash
kubectl describe pod <pod-name> -n gitops-demo
```

### Sync succeeds but no resources appear

Double-check `spec.destination.namespace` matches where you're looking, and that `spec.source.path` points at the directory containing `Chart.yaml`, not a parent or subdirectory.

## Next Steps

Your chart is now deployed and tracked by ArgoCD. In the next exercise, you'll deliberately change the cluster outside of Git and watch ArgoCD detect and — once configured — correct that drift.

Continue to [Exercise 3: Drift Detection and Self-Healing](exercise-3-drift-detection.md).
