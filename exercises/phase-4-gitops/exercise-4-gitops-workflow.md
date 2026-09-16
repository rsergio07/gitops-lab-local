## Exercise 4: The Full GitOps Workflow

**Objective:** Deploy a change to the cluster using nothing but a Git commit, and confirm ArgoCD applies it automatically end to end.

## Background

The previous exercises installed ArgoCD, connected it to your chart, and proved it corrects drift. This exercise puts the whole loop together the way it's meant to be used day to day: you never run `kubectl apply` or `helm upgrade` against this cluster again. Every change goes through Git.

## Steps

### 1. Confirm your starting state

```bash
argocd app get demo-app
kubectl get deployment demo-app -n gitops-demo -o jsonpath='{.spec.replicas}'
```

Note the current replica count and confirm the Application shows `Synced` / `Healthy`.

### 2. Make a change in your local chart copy

Edit `values.yaml` in your chart directory. For example, bump the replica count:

```yaml
replicaCount: 3
```

You could equally change a value consumed by your ConfigMap template, or update the image tag — any change your chart's templates render into the cluster works for this exercise.

### 3. Commit and push the change

```bash
git add exercises/phase-4-gitops/demo-app/values.yaml
git commit -m "Scale demo-app to 3 replicas"
git push origin <your-branch>
```

### 4. Watch ArgoCD pick up the change

Without running any `kubectl` or `helm` command yourself, watch the Application:

```bash
argocd app get demo-app --refresh
```

You'll briefly see `OutOfSync` as ArgoCD detects the new commit, then `Synced` again once it applies automatically (assuming `automated` sync is still enabled from Exercise 3).

### 5. Confirm the change landed

```bash
kubectl get deployment demo-app -n gitops-demo
kubectl get pods -n gitops-demo
```

The replica count matches what you committed to `values.yaml`.

### 6. Review the audit trail

```bash
argocd app history demo-app
git log --oneline -5
```

Every deployment ArgoCD performed corresponds to a commit in your Git history. To roll back, you'd revert the commit and push — ArgoCD applies the reversion the same way it applied the original change.

## Verification

* The only commands you ran to deploy the change were `git add`, `git commit`, and `git push`.
* `argocd app get demo-app` shows `Synced` / `Healthy` with the new value applied.
* `argocd app history demo-app` shows a new revision corresponding to your commit.
* Reverting the commit (optional) and pushing again triggers ArgoCD to roll the cluster back.

## Common Issues

### Change doesn't appear after pushing

Confirm you pushed to the exact branch referenced in `application.yaml`'s `targetRevision`. If you pushed to a different branch, ArgoCD has nothing to detect.

### Sync happens but the value looks unchanged

Run `helm template` locally against your chart with the same values to confirm the template actually reads the value you changed — a typo in the values key name will silently render the old default instead.

### Want faster feedback while testing

Rather than waiting for the polling interval, trigger an immediate check with `argocd app get demo-app --refresh` after pushing.

## Next Steps

You've completed the GitOps loop: a Git commit is now the only interface between you and production. The next phase steps down a layer, provisioning the Kubernetes infrastructure itself — namespaces, quotas, and RBAC — as code using Terraform, instead of the manifests you've relied on so far.

Continue to [Phase 5 – Infrastructure as Code with Terraform](../phase-5-terraform/README.md).
