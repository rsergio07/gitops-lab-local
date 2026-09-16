## Exercise 4: End-to-End Deployment

**Objective:** Push a single code change and trace it all the way through the pipeline — CI build, automated chart update, and ArgoCD sync — to a running pod, without running a manual command anywhere in between.

## Background

This exercise doesn't introduce new tooling. It's a deliberate, observed run of everything you've built across Phases 2 through 6, confirming the pieces genuinely work together as one system rather than as isolated exercises.

## Steps

### 1. Confirm the starting state

```bash
argocd app get demo-app
kubectl get pods -n gitops-demo -o wide
```

Note the current image tag running in the cluster:

```bash
kubectl get deployment demo-app -n gitops-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### 2. Make a visible application change

Edit your application code, for example changing the response text in `examples/simple-app/main.py`:

```python
return 'Hello from the fully automated pipeline!\n'
```

### 3. Push the change

```bash
git add examples/simple-app/main.py
git commit -m "Update greeting message"
git push origin <your-branch>
```

### 4. Watch the pipeline run

On GitHub's Actions tab, watch `validate` → `build-and-push` → `update-chart` complete in sequence. Note the new commit SHA used as the image tag.

### 5. Watch ArgoCD pick it up

```bash
argocd app get demo-app --refresh
```

Sync status should briefly show `OutOfSync` as it detects the bot's commit, then return to `Synced` once it applies automatically.

### 6. Confirm the new image is running

```bash
kubectl get deployment demo-app -n gitops-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get pods -n gitops-demo
```

### 7. Verify the actual behavior changed

Port-forward to the service and confirm the new response:

```bash
kubectl port-forward svc/demo-app -n gitops-demo 8081:80
curl http://localhost:8081
```

You should see your updated greeting.

### 8. Review the full trail

```bash
git log --oneline -5
argocd app history demo-app
```

Every layer — your commit, the bot's commit, and the ArgoCD sync — is visible and traceable.

## Verification

* A single `git push` of an application code change results in a new pod running that change, with zero manual `kubectl`, `helm`, `docker`, or `argocd sync` commands.
* `git log` shows both your commit and the automated chart-update commit.
* `curl` against the running service reflects the code change.

## Common Issues

### Pipeline completes but the pod doesn't update

Confirm ArgoCD's `targetRevision` still points at the branch you pushed to, and that `automated.selfHeal` from Phase 4 is still enabled on the Application.

### New pods start but crash

Check application logs the same way you have since Phase 1:

```bash
kubectl logs -l app=demo-app -n gitops-demo
```

A code error introduced in your change will surface here, not in the pipeline, since the pipeline only validates the chart and YAML, not application logic.

### Takes longer than expected

Three delays stack up here: the Actions run itself, ArgoCD's polling interval (up to ~3 minutes), and pod rollout time. Use `--refresh` on `argocd app get` and `kubectl get pods --watch` to see progress rather than assuming something is stuck.

## Next Steps

You now have a complete, automated path from a code change to a running, observable deployment — the same shape as a real production pipeline, built entirely from open-source tools on your laptop. The final phase adds the observability layer: Prometheus and Grafana, so you can see the effect of deployments like this one on real metrics, not just pod status.

Continue to [Phase 7 – Observability and Metrics](../phase-7-observability/README.md).
