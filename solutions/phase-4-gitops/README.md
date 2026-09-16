# Phase 4 Solutions

Reference solutions for Phase 4 exercises. Use these to verify your work or understand correct approaches when stuck.

## Using Solutions Responsibly

Attempt each exercise independently before consulting solutions. The learning happens through problem-solving and troubleshooting, not just reading correct answers. Solutions are provided to:

1. Verify your approach matches expected patterns
2. Understand alternative methods when stuck
3. Compare your implementation with best practices
4. Learn from detailed explanations in comments

## Solution Files

### Exercise 1: Install ArgoCD

`exercise-1-install-argocd.sh` installs ArgoCD, waits for it to become ready, and prints the initial admin password. It does not start the port-forward or log in for you — those steps are interactive and belong in their own terminal, as described in the exercise.

### Exercise 2: Application Deployment

`exercise-2-application-deployment.sh` generates `application.yaml` with a manual sync policy, applies it, and syncs the Application once so you can see the before/after state.

**Key verification commands:**
```bash
argocd app get demo-app
kubectl get all -n gitops-demo
```

### Exercise 3: Drift Detection and Self-Healing

`exercise-3-drift-detection.sh` scales the deployment out of band, shows the resulting diff, resyncs manually, then patches the Application with `automated.selfHeal` and repeats the drift to demonstrate automatic correction.

### Exercise 4: The Full GitOps Workflow

`exercise-4-gitops-workflow.sh` patches `values.yaml` in your local chart copy and prints the `git add`/`commit`/`push` commands to run — pushing on your behalf isn't automated, since it requires your own Git credentials and branch.

## Common Patterns

**Application lifecycle:**

1. Define `Application` with `source`, `destination`, and `syncPolicy`
2. `kubectl apply -f application.yaml`
3. `argocd app get <name>` to inspect sync/health status
4. `argocd app sync <name>` for a manual sync, or rely on `automated` for hands-off syncing

**Drift diagnosis:**

1. `argocd app get <name>` to see `OutOfSync`
2. `argocd app diff <name>` to see exactly what differs
3. `argocd app sync <name>` to reconcile manually, or wait for self-heal if enabled

## Notes

These solutions represent one correct approach. Valid alternatives may exist — for example, using `argocd app create` instead of a declarative `Application` manifest. The important outcomes are:

- ArgoCD tracks your chart and reports accurate sync/health status
- Drift is detected reliably, whether corrected manually or automatically
- A Git commit alone is sufficient to deploy a change
- You understand why each step is necessary
