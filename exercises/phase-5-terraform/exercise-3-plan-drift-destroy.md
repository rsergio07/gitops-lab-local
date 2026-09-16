## Exercise 3: Plan, Drift, and Destroy

**Objective:** Observe how Terraform detects manual drift, reconcile it with `apply`, complete the lifecycle with `destroy`, and bring an existing resource under management with `import`.

## Background

Terraform's state file is only useful if it stays accurate. This exercise deliberately breaks that accuracy with a manual change, shows how Terraform reacts (differently from ArgoCD's self-heal in Phase 4), and then covers the two commands that bookend a resource's life in Terraform: `destroy` and `import`.

## Steps

### 1. Introduce drift manually

Change a value Terraform manages directly with `kubectl`:

```bash
kubectl label namespace tf-demo managed-by=manual --overwrite
```

### 2. Detect the drift

```bash
terraform plan
```

Terraform shows a change to the namespace's `labels` field, reverting it back to `managed-by = "terraform"`. Unlike ArgoCD, nothing has happened to the cluster yet — Terraform only detects drift when you explicitly ask it to.

### 3. Reconcile the drift

```bash
terraform apply
kubectl get namespace tf-demo --show-labels
```

The label is restored to match your configuration.

### 4. Import an existing resource

Create a namespace outside Terraform entirely, simulating infrastructure that existed before you adopted IaC:

```bash
kubectl create namespace legacy-ns
```

Add a matching resource block to `main.tf`, deliberately left empty of arguments for now:

```hcl
resource "kubernetes_namespace" "legacy" {
  metadata {
    name = "legacy-ns"
  }
}
```

Import the existing namespace into Terraform's state instead of letting `apply` try to create a duplicate:

```bash
terraform import kubernetes_namespace.legacy legacy-ns
```

Confirm it's now tracked without any pending changes:

```bash
terraform plan
```

### 5. Destroy a single resource

Remove just the imported namespace using a targeted destroy:

```bash
terraform destroy -target=kubernetes_namespace.legacy
```

Confirm with `yes`, then verify:

```bash
kubectl get namespace legacy-ns
```

The command should report the namespace not found.

### 6. Destroy everything

When you're done with this phase's infrastructure, tear it all down:

```bash
terraform destroy
```

Review the full plan of deletions before confirming.

## Verification

* `terraform plan` correctly reports drift after the manual label change, without modifying the cluster.
* `terraform apply` reconciles that drift.
* `terraform import` attaches `legacy-ns` to state with zero planned changes afterward.
* `terraform destroy -target=...` removes only the targeted resource.
* `terraform destroy` removes everything Terraform manages in this configuration.

## Common Issues

### Plan still shows changes after import

The resource block's arguments must actually match the imported object's real configuration. `terraform plan` after an import will show a diff for any argument you got wrong — adjust the block to match, don't fight it by re-importing.

### Destroy fails with dependent resources

If a resource elsewhere in the cluster (like a Pod using a ServiceAccount defined here) blocks deletion, remove or scale down that dependency first, or delete namespaces last since deleting a namespace cascades to everything inside it.

### Forgot to remove a resource block after `destroy -target`

A targeted destroy removes the object from the cluster and from state, but leaves the resource block in your `.tf` file. The next `terraform plan` will offer to recreate it — delete the block if you don't want that.

## Next Steps

You've completed the full Terraform lifecycle: provisioning, drift detection, reconciliation, import, and destroy. Combined with the GitOps workflow from Phase 4, you now have both layers of a real deployment pipeline under version control — infrastructure and application. The next phase automates the piece that still requires you to run commands by hand: building and publishing the application itself.

Continue to [Phase 6 – CI/CD with GitHub Actions](../phase-6-cicd/README.md).
