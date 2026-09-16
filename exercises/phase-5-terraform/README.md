# Phase 5: Infrastructure as Code with Terraform

Provision the Kubernetes infrastructure your applications run on — namespaces, resource quotas, and RBAC — declaratively with Terraform, instead of `kubectl apply`. This phase teaches the plan-apply-destroy workflow and how Terraform tracks state.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Infrastructure as Code](#infrastructure-as-code)
  - [The Terraform Workflow](#the-terraform-workflow)
  - [Providers and Resources](#providers-and-resources)
  - [State Management](#state-management)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Provision a Namespace](exercise-1-provision-namespace.md)
  - [Exercise 2: Quotas and RBAC as Code](exercise-2-quotas-and-rbac.md)
  - [Exercise 3: Plan, Drift, and Destroy](exercise-3-plan-drift-destroy.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Every phase so far has treated the Kubernetes cluster itself as a given — Minikube provides it, and you deploy applications into it. In real environments, someone has to provision the namespaces, resource quotas, and access controls those applications depend on, and do it in a way that's reviewable, repeatable, and auditable. Terraform is the industry-standard tool for this: you describe infrastructure in declarative configuration files, and Terraform figures out what needs to change to make reality match.

This phase uses Terraform's Kubernetes provider to manage the same kind of primitives you've been creating by hand since Phase 1 — namespaces, and now resource quotas and role-based access control — but as versioned, reviewable code with a proper plan-before-apply workflow. You'll also deliberately cause drift and see how Terraform, unlike ArgoCD, requires you to explicitly run `apply` to correct it — a useful contrast that sharpens your understanding of both tools.

## Learning Objectives

By completing this phase, you will be able to:

1. **Explain infrastructure as code** and why declarative provisioning is preferred over manual `kubectl` commands.
2. **Configure the Terraform Kubernetes provider** to target your Minikube cluster.
3. **Define namespaces, resource quotas, and RBAC resources** as Terraform configuration.
4. **Run the plan-apply-destroy workflow** and interpret Terraform's plan output before applying changes.
5. **Understand Terraform state**, including how drift is detected and how `import` brings existing resources under management.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phases 0–4** – comfortable with Kubernetes primitives and the GitOps mental model.
2. **Terraform installed** – already installed by `scripts/setup-macos.sh` in the Prerequisites phase. Confirm with `terraform version` (v1.5+ expected).
3. **kubectl configured for Minikube** – `kubectl config current-context` returns `minikube`.

## Theoretical Foundation

### Infrastructure as Code

Infrastructure as code (IaC) means describing infrastructure — servers, networks, or in this case Kubernetes objects — in text files that live in version control, rather than creating them through one-off commands or clicking through a UI. The benefits mirror GitOps: changes are reviewable before they happen, every change has a history, and the same configuration can be applied consistently across environments. Terraform is a general-purpose IaC tool that manages resources across many providers — cloud infrastructure, SaaS platforms, and, as you'll use it here, Kubernetes itself.

### The Terraform Workflow

Terraform's core loop has three commands. `terraform init` downloads the providers your configuration references and sets up the working directory. `terraform plan` compares your configuration against the current state and shows exactly what it would create, change, or destroy — without touching anything. `terraform apply` executes that plan. This plan-before-apply separation is Terraform's central safety mechanism: you always see the blast radius of a change before it happens.

### Providers and Resources

A **provider** is a plugin that teaches Terraform how to manage a particular system's API. The `kubernetes` provider translates Terraform resource blocks into calls against the Kubernetes API server, the same API `kubectl` talks to. Each **resource** block declares one object you want Terraform to manage — a `kubernetes_namespace`, a `kubernetes_resource_quota`, a `kubernetes_role_binding` — with arguments describing its desired configuration. Terraform resources map closely to the YAML manifests you've already written; the syntax differs, but the underlying Kubernetes objects are identical.

### State Management

Terraform records what it created in a **state file** (`terraform.tfstate`), which maps your configuration's resources to real infrastructure. Every `plan` and `apply` reads this file to know what already exists. If someone changes a Terraform-managed resource outside of Terraform — with `kubectl edit`, for instance — the state file no longer matches reality. Terraform detects this as drift the next time you run `plan`, but unlike ArgoCD's self-heal, it never corrects drift automatically; you must review the plan and explicitly `apply` it. For resources that already exist but weren't created by Terraform, `terraform import` brings them under management without recreating them.

## Hands-On Exercises

### Exercise 1: Provision a Namespace

**Objective:** Set up a Terraform project with the Kubernetes provider and manage a namespace through the plan-apply workflow.

See [exercise-1-provision-namespace.md](exercise-1-provision-namespace.md) for complete instructions.

### Exercise 2: Quotas and RBAC as Code

**Objective:** Add a resource quota and a role/role binding to your namespace, parameterized with Terraform variables.

See [exercise-2-quotas-and-rbac.md](exercise-2-quotas-and-rbac.md) for complete instructions.

### Exercise 3: Plan, Drift, and Destroy

**Objective:** Introduce manual drift and watch Terraform detect it, then complete the resource lifecycle with `destroy` and a brief `import` of an existing resource.

See [exercise-3-plan-drift-destroy.md](exercise-3-plan-drift-destroy.md) for complete instructions.

## Troubleshooting

### Provider fails to initialize

If `terraform init` can't download the `kubernetes` provider, check your internet connection and retry. Corporate proxies or DNS issues are the most common cause locally.

### Provider can't connect to the cluster

Confirm `kubectl cluster-info` works before running Terraform — the provider typically reads the same kubeconfig and context as `kubectl`. Explicitly setting `config_context = "minikube"` in the provider block avoids ambiguity if you have multiple contexts.

### Plan shows unexpected changes on every run

This usually means a field's default value differs between what you specified and what Kubernetes returns (for example, an omitted field Kubernetes fills in). Set the field explicitly in your resource block to match, or check the provider's documentation for known "perpetual diff" fields.

### Apply fails with "already exists"

The resource exists in the cluster but isn't in Terraform's state — likely created by hand or by a manifest earlier in the course. Use `terraform import` to bring it under management, or delete it with `kubectl` first if you'd rather Terraform create it fresh.

### State file out of sync after manual deletion

If you delete a Terraform-managed resource with `kubectl` instead of `terraform destroy`, the next `plan` will show it needs to be recreated. Run `terraform apply` to restore it, or `terraform state rm` if you genuinely want Terraform to forget about it.

## Next Steps

You've now provisioned Kubernetes infrastructure as versioned, reviewable code. The next phase automates the last manual step remaining in your workflow: building and shipping the application itself. You'll build a CI/CD pipeline with GitHub Actions that builds your Docker image, pushes it to a registry, and updates your Helm chart in Git — triggering the ArgoCD sync you set up in Phase 4.

Continue to [Phase 6 – CI/CD with GitHub Actions](../phase-6-cicd/README.md).

## Additional Resources

**Official Documentation:**
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)

**Video Tutorials:**
- [Terraform Course for Beginners (Kubernetes section) (20 min)](https://www.youtube.com/watch?v=SLB_c_ayRMo) - TechWorld with Nana
