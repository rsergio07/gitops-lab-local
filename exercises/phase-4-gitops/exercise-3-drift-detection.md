## Exercise 3: Drift Detection and Self-Healing

**Objective:** Manually change a resource ArgoCD manages, observe how it reports the drift, then enable automated self-healing and watch it revert the change on its own.

## Background

One of GitOps's biggest advantages over a one-time `kubectl apply` is that the cluster never quietly drifts away from what's declared in Git. ArgoCD continuously polls the cluster and compares it against Git, by default every three minutes. This exercise shows both halves of that promise: detection, which happens whether or not automated sync is enabled, and correction, which requires `selfHeal`.

## Steps

### 1. Introduce drift manually

Scale the deployment directly with `kubectl`, bypassing Git and Helm entirely:

```bash
kubectl scale deployment demo-app -n gitops-demo --replicas=5
```

### 2. Observe ArgoCD detect the change

```bash
argocd app get demo-app
```

Within a few minutes (or immediately if you run `argocd app get demo-app --refresh`), the sync status changes to `OutOfSync`. Inspect exactly what differs:

```bash
argocd app diff demo-app
```

The diff output shows the live replica count against the value defined in your chart.

### 3. Manually resync to confirm reconciliation works

```bash
argocd app sync demo-app
kubectl get deployment demo-app -n gitops-demo
```

The replica count returns to the value in Git. This is reconciliation on demand — you still had to trigger it.

### 4. Enable automated sync with self-healing

Edit `application.yaml` to add a sync policy:

```yaml
spec:
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
```

Apply the change:

```bash
kubectl apply -f application.yaml
argocd app get demo-app
```

### 5. Repeat the drift and watch it self-heal

```bash
kubectl scale deployment demo-app -n gitops-demo --replicas=5
```

Watch the deployment without intervening:

```bash
kubectl get deployment demo-app -n gitops-demo --watch
```

Within roughly three minutes (ArgoCD's default reconciliation interval), the replica count reverts on its own, with no `argocd app sync` or `kubectl apply` from you.

## Verification

* `argocd app diff` correctly shows the manual replica change before any sync.
* A manual `argocd app sync` reverts drift when `syncPolicy` is empty.
* After enabling `automated.selfHeal`, the same manual drift is reverted automatically without operator action.
* `argocd app get demo-app` shows `Synced` / `Healthy` after self-healing completes.

## Common Issues

### Self-heal doesn't trigger

Confirm the `syncPolicy.automated` block was actually applied — `kubectl get application demo-app -n argocd -o yaml` should show it under `spec`. A missing or misindented block silently falls back to manual sync.

### Reconciliation feels slow

Three minutes is ArgoCD's default polling interval for detecting Git and cluster changes. For faster feedback while testing, force an immediate refresh with `argocd app get demo-app --refresh` or `argocd app sync demo-app`.

### Pruning deletes something unexpected

`prune: true` removes any resource ArgoCD manages that's no longer defined in Git. Only enable it once you're confident your chart's templates fully describe what should exist — never point `prune` at a chart with unrelated pre-existing resources in the same namespace.

## Next Steps

You've now seen both halves of GitOps reconciliation: detection and automated correction. The final exercise in this phase closes the loop by deploying a change purely through Git, with no direct cluster commands at all.

Continue to [Exercise 4: The Full GitOps Workflow](exercise-4-gitops-workflow.md).
