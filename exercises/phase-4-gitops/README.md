# Phase 4: GitOps with ArgoCD

Automate deployments by making Git the single source of truth for your cluster. This phase introduces ArgoCD, a GitOps continuous delivery tool that continuously compares your cluster's live state against what's declared in Git and reconciles any difference automatically.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [GitOps Principles](#gitops-principles)
  - [ArgoCD Architecture](#argocd-architecture)
  - [The Application Resource](#the-application-resource)
  - [Sync Policies and Health](#sync-policies-and-health)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Install ArgoCD](exercise-1-install-argocd.md)
  - [Exercise 2: Application Deployment](exercise-2-application-deployment.md)
  - [Exercise 3: Drift Detection and Self-Healing](exercise-3-drift-detection.md)
  - [Exercise 4: The Full GitOps Workflow](exercise-4-gitops-workflow.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

So far you have deployed the demo application with `kubectl apply` and `helm install` — both imperative actions you run from your terminal. GitOps flips this model: instead of pushing changes to the cluster, you push changes to Git, and a controller running inside the cluster pulls those changes and applies them. The cluster's actual state is continuously reconciled against the state declared in Git, so any manual or accidental change gets corrected automatically.

ArgoCD implements this pattern for Kubernetes. You point it at a Git repository containing manifests or a Helm chart, and it creates an **Application** resource that tracks that source. From then on, ArgoCD compares the live cluster against Git on a regular interval, reports whether they match, and — depending on the sync policy you choose — either waits for you to approve a sync or applies changes automatically.

By the end of this phase, the Helm chart you built in Phase 3 will live in Git and be deployed exclusively through ArgoCD. You will deliberately introduce drift by changing the cluster by hand, watch ArgoCD detect it, and then watch it self-heal.

## Learning Objectives

By completing this phase, you will be able to:

1. **Explain GitOps** and how it differs from push-based deployment models like `kubectl apply` or CI-driven deploys.
2. **Install and access ArgoCD** on a local Kubernetes cluster using its CLI and web UI.
3. **Create an Application resource** that connects ArgoCD to a Git repository and a Helm chart.
4. **Configure sync policies**, including automated sync, self-healing, and pruning.
5. **Diagnose and resolve drift** between the desired state in Git and the live cluster state.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phases 0–3** – your Helm chart from Phase 3 deploys successfully to Minikube.
2. **A GitHub fork of this repository** – GitOps requires a Git remote ArgoCD can read from. Fork this repo (or push your chart to any repository you control) and be ready to push commits to it.
3. **ArgoCD CLI installed** – `brew install argocd` on macOS.
4. **Sufficient cluster resources** – ArgoCD's components need roughly an additional 1 CPU and 1 GB of memory on top of what earlier phases used.

## Theoretical Foundation

### GitOps Principles

GitOps rests on a few core ideas: the desired state of your system is described declaratively and stored in Git; changes to that state happen only through Git commits (pull requests, code review, history); and an automated agent — not a human running `kubectl` — applies those changes and continuously corrects drift. This gives you an audit trail for every production change, a single rollback mechanism (`git revert`), and a system that actively resists configuration drift instead of just tolerating it.

### ArgoCD Architecture

ArgoCD runs as a set of components inside your cluster, in the `argocd` namespace. The **API server** exposes the gRPC/REST API used by the UI, CLI, and CI systems. The **repository server** clones and caches Git repositories, rendering Helm charts or Kustomize overlays into plain manifests. The **application controller** is the reconciliation loop: it continuously compares the rendered manifests against live cluster state and reports or corrects any difference. You interact with these components through the `argocd` CLI or the web UI, both of which talk to the API server.

### The Application Resource

An `Application` is a Kubernetes custom resource that tells ArgoCD what to deploy and where. Its `spec.source` defines the Git repository, path, and revision (branch, tag, or commit) to track. Its `spec.destination` defines the target cluster and namespace. Its `spec.syncPolicy` controls whether syncing happens automatically or requires manual approval. Because the Application itself is just a Kubernetes object, you can manage ArgoCD declaratively — the same GitOps principle applied to ArgoCD's own configuration.

### Sync Policies and Health

ArgoCD reports two independent states for every Application. **Sync status** (`Synced` / `OutOfSync`) tells you whether the live state matches Git. **Health status** (`Healthy` / `Progressing` / `Degraded` / `Missing`) tells you whether the deployed resources are actually working, based on Kubernetes-native checks like Deployment replica counts and rollout status. A sync policy of `automated` tells ArgoCD to apply changes as soon as it detects them in Git, without waiting for manual approval. Adding `selfHeal: true` makes it also revert out-of-band changes made directly to the cluster. Adding `prune: true` tells it to delete resources that were removed from Git.

## Hands-On Exercises

### Exercise 1: Install ArgoCD

**Objective:** Install ArgoCD into Minikube and access it through both the CLI and the web UI.

See [exercise-1-install-argocd.md](exercise-1-install-argocd.md) for complete instructions.

### Exercise 2: Application Deployment

**Objective:** Commit your Phase 3 Helm chart to Git, create an ArgoCD Application that tracks it, and perform your first sync.

See [exercise-2-application-deployment.md](exercise-2-application-deployment.md) for complete instructions.

### Exercise 3: Drift Detection and Self-Healing

**Objective:** Manually change the cluster with `kubectl`, observe ArgoCD flag the drift, then enable automated self-healing and watch it reconcile.

See [exercise-3-drift-detection.md](exercise-3-drift-detection.md) for complete instructions.

### Exercise 4: The Full GitOps Workflow

**Objective:** Deploy a change by committing to Git alone — no `kubectl` or `helm` commands — and confirm ArgoCD picks it up automatically.

See [exercise-4-gitops-workflow.md](exercise-4-gitops-workflow.md) for complete instructions.

## Troubleshooting

### ArgoCD pods stuck in Pending

ArgoCD's components need headroom on top of everything already running in Minikube. Check node capacity with `kubectl top node` and `kubectl describe node minikube`. If resources are tight, stop Minikube and restart with more CPU/memory:

```bash
minikube stop
minikube start --cpus=4 --memory=8192
```

### Application stuck in Progressing

Progressing usually means a rollout is still in flight or a readiness probe hasn't passed yet. Use the same diagnostics from Phase 1:

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Repository connection failed

For a public GitHub repository, no credentials are required — verify the `repoURL` is correct and reachable. For a private repository, add credentials first:

```bash
argocd repo add <repo-url> --username <user> --password <token>
```

### OutOfSync never clears after enabling automated sync

Check the `syncPolicy` block in your Application manifest for indentation or key errors — `automated`, `selfHeal`, and `prune` must sit directly under `syncPolicy`. Re-apply the Application manifest and confirm with:

```bash
argocd app get demo-app
```

### Can't log in to the UI or CLI

The initial admin password is stored in a Secret and is deleted after you change it. Retrieve it again if needed:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Next Steps

You now have a working GitOps pipeline: Git commits drive cluster state, and ArgoCD keeps the two in sync automatically. The next phase steps back from application deployment to provision the underlying Kubernetes infrastructure — namespaces, quotas, and RBAC — as code using Terraform.

Continue to [Phase 5 – Infrastructure as Code with Terraform](../phase-5-terraform/README.md).

## Additional Resources

**Official Documentation:**
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Application Spec Reference](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/)
- [GitOps Principles (OpenGitOps)](https://opengitops.dev/)

**Video Tutorials:**
- [ArgoCD Tutorial for Beginners (20 min)](https://www.youtube.com/watch?v=MeU5_k9ssrs) - TechWorld with Nana
