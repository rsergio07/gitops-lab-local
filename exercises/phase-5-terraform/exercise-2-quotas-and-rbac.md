## Exercise 2: Quotas and RBAC as Code

**Objective:** Extend your Terraform configuration with a resource quota and a role/role binding, parameterized with variables instead of hardcoded values.

## Background

Namespaces alone don't protect a cluster from a runaway workload or an over-privileged user. Resource quotas cap how much CPU, memory, and object count a namespace can consume. RBAC (role-based access control) restricts what actions a user or service account can perform. Both are exactly the kind of infrastructure that benefits from being defined as code: the limits are policy decisions, and policy changes deserve review, not a one-off `kubectl edit`.

## Steps

### 1. Introduce variables

Create `variables.tf`:

```hcl
variable "namespace" {
  description = "Namespace to apply quota and RBAC to"
  type        = string
  default     = "tf-demo"
}

variable "max_cpu" {
  description = "CPU limit for the namespace"
  type        = string
  default     = "2"
}

variable "max_memory" {
  description = "Memory limit for the namespace"
  type        = string
  default     = "2Gi"
}
```

Update the namespace resource in `main.tf` to use the variable:

```hcl
resource "kubernetes_namespace" "tf_demo" {
  metadata {
    name = var.namespace
    labels = {
      managed-by = "terraform"
    }
  }
}
```

### 2. Add a resource quota

Append to `main.tf`:

```hcl
resource "kubernetes_resource_quota" "tf_demo" {
  metadata {
    name      = "tf-demo-quota"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.max_cpu
      "requests.memory" = var.max_memory
      "pods"            = "10"
    }
  }
}
```

Note the reference `kubernetes_namespace.tf_demo.metadata[0].name` — Terraform automatically orders resource creation based on these dependencies, so the namespace is guaranteed to exist before the quota is applied.

### 3. Add a Role and RoleBinding

```hcl
resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "pod_reader_binding" {
  metadata {
    name      = "pod-reader-binding"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
}
```

This grants the namespace's default service account read-only access to pods — a minimal, realistic RBAC policy.

### 4. Plan and apply

```bash
terraform plan
```

Review the three pending additions (quota, role, role binding), then:

```bash
terraform apply
```

### 5. Verify

```bash
kubectl get resourcequota -n tf-demo
kubectl describe role pod-reader -n tf-demo
kubectl describe rolebinding pod-reader-binding -n tf-demo
```

### 6. Override a variable at apply time

Demonstrate reusability by tightening the quota without editing the file:

```bash
terraform plan -var="max_cpu=1"
```

Review the plan — only the quota's CPU limit should change.

## Verification

* `terraform plan` shows the quota, role, and role binding as new resources before applying.
* After `terraform apply`, all three exist in the `tf-demo` namespace.
* `terraform plan -var="max_cpu=1"` shows a targeted, minimal diff.

## Common Issues

### Resource created in the wrong order

If you see dependency errors, confirm you referenced the namespace via `kubernetes_namespace.tf_demo.metadata[0].name` rather than hardcoding the string `"tf-demo"` — the reference is what tells Terraform about the dependency.

### RBAC changes don't seem to apply

RBAC permissions take effect immediately but are only visible in behavior, not in pod state. Verify with `kubectl auth can-i list pods --namespace tf-demo --as=system:serviceaccount:tf-demo:default` rather than checking pod status.

### Quota blocks pod creation unexpectedly

If a real workload later fails to schedule with a quota-related error, check `kubectl describe resourcequota -n tf-demo` to see current usage against the hard limits.

## Next Steps

Your namespace, quota, and RBAC policy are all defined as reviewable code. The final exercise in this phase covers the parts of the Terraform lifecycle you haven't used yet: detecting drift, destroying resources, and importing something that already exists.

Continue to [Exercise 3: Plan, Drift, and Destroy](exercise-3-plan-drift-destroy.md).
