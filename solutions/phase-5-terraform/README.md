# Phase 5 Solutions

Reference solutions for Phase 5 exercises. Use these to verify your work or understand correct approaches when stuck.

## Using Solutions Responsibly

Attempt each exercise independently before consulting solutions. The learning happens through problem-solving and troubleshooting, not just reading correct answers. Solutions are provided to:

1. Verify your approach matches expected patterns
2. Understand alternative methods when stuck
3. Compare your implementation with best practices
4. Learn from detailed explanations in comments

## Solution Files

### Exercise 1: Provision a Namespace

`exercise-1-provision-namespace.sh` writes `main.tf` with the provider and namespace resource, then runs `init`, `plan`, and `apply`.

### Exercise 2: Quotas and RBAC as Code

`exercise-2-quotas-and-rbac.sh` writes `variables.tf` and appends the quota, role, and role binding resources to `main.tf`, then plans and applies.

### Exercise 3: Plan, Drift, and Destroy

`exercise-3-plan-drift-destroy.sh` introduces drift, applies the fix, creates and imports `legacy-ns`, then performs a targeted destroy. It stops short of the final full `terraform destroy` — run that yourself, or use `cleanup.sh`, once you're done reviewing the state.

**Key verification commands:**
```bash
terraform plan
terraform show
kubectl get namespace tf-demo --show-labels
```

## Common Patterns

**Terraform lifecycle:**

1. `terraform init` (once per working directory)
2. `terraform plan` before every change
3. `terraform apply` to execute the plan
4. `terraform destroy` when the infrastructure is no longer needed

**Bringing existing resources under management:**

1. Write a resource block matching the existing object
2. `terraform import <resource_address> <resource_id>`
3. `terraform plan` to confirm zero drift; adjust the block if it shows a diff

## Notes

These solutions represent one correct approach. Valid alternatives may exist — for example, splitting resources across multiple `.tf` files by convention. The important outcomes are:

- `terraform plan` always precedes `apply` in your workflow
- Namespace, quota, and RBAC resources exist and match your configuration
- Drift is detected accurately and reconciled deliberately, not automatically
- You understand why each step is necessary
