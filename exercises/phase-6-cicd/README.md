# Phase 6: CI/CD with GitHub Actions

Automate the last manual step in your pipeline: building and shipping the application itself. This phase builds a CI/CD workflow progressively — starting with basic validation, then adding image builds, then automated Helm chart updates — until a code commit alone triggers a full deployment through the ArgoCD pipeline from Phase 4.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Continuous Integration vs Continuous Delivery](#continuous-integration-vs-continuous-delivery)
  - [GitHub Actions Concepts](#github-actions-concepts)
  - [Secrets and Authentication](#secrets-and-authentication)
  - [Closing the GitOps Loop](#closing-the-gitops-loop)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: A Basic Validation Workflow](exercise-1-basic-workflow.md)
  - [Exercise 2: Build and Push the Image](exercise-2-build-and-push.md)
  - [Exercise 3: Automate the Helm Chart Update](exercise-3-update-helm-chart.md)
  - [Exercise 4: End-to-End Deployment](exercise-4-end-to-end.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Every phase so far has involved you personally running a command at some point — `docker build`, `helm package`, `git push`. CI/CD removes the "you" from that sentence. A CI/CD pipeline is code, checked into your repository, that runs automatically whenever you push a change: it validates your work, builds artifacts, and — in a full GitOps setup — updates the Git state that ArgoCD watches.

This phase builds that pipeline in the same progressive style you've used throughout the course. You'll start with a workflow that just validates your changes, then extend it to build and push a real Docker image, then extend it again to automatically bump your Helm chart's image tag in Git. By the final exercise, a single `git push` will flow all the way through: GitHub Actions builds the image, updates the chart, and ArgoCD — still running from Phase 4 — picks up the change and deploys it, with no manual step anywhere in between.

## Learning Objectives

By completing this phase, you will be able to:

1. **Distinguish CI from CD** and explain where GitOps fits into a complete delivery pipeline.
2. **Write a GitHub Actions workflow** using triggers, jobs, and steps.
3. **Build and push a container image** to a registry from a workflow, using the built-in `GITHUB_TOKEN`.
4. **Automate a Git commit** that updates a Helm chart's image tag, triggering downstream GitOps reconciliation.
5. **Trace a change end to end**, from a code push through CI, through Git, to a running pod.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phases 0–5** – you have a working Dockerfile (Phase 2), Helm chart (Phase 3), ArgoCD Application (Phase 4), and understand the GitOps model.
2. **A GitHub account and fork** – workflows run on GitHub's infrastructure, not locally, and need a repository to live in.
3. **Actions enabled on your fork** – on GitHub, go to the **Actions** tab of your fork and enable workflows if prompted.
4. **Package write access** – no extra setup needed; the default `GITHUB_TOKEN` GitHub Actions provides can push to your fork's GitHub Container Registry (`ghcr.io`) automatically.

## Theoretical Foundation

### Continuous Integration vs Continuous Delivery

**Continuous Integration (CI)** validates every change automatically — linting, building, testing — so problems surface within minutes of a push instead of during a later manual release. **Continuous Delivery (CD)** takes validated changes and gets them into a running environment. In a GitOps setup, CD doesn't mean the pipeline deploys directly to the cluster; it means the pipeline updates the Git repository, and a separate agent — ArgoCD, from Phase 4 — handles the actual deployment. This separation keeps deployment credentials out of your CI system entirely: GitHub Actions never touches your cluster.

### GitHub Actions Concepts

A **workflow** is a YAML file in `.github/workflows/` that defines automation. A `trigger` (the `on:` key) determines when it runs — on every push, only on specific branches, or on a pull request. A workflow contains one or more `jobs`, each running on a fresh virtual machine (a `runner`). Each job contains a sequence of `steps`, which either run shell commands or invoke a reusable `action` — a packaged unit of automation like `actions/checkout` or `docker/build-push-action`. Jobs run in parallel by default; use `needs:` to make one job wait for another.

### Secrets and Authentication

Workflows often need credentials — to push a Docker image, for instance. GitHub automatically provides a short-lived `GITHUB_TOKEN` for every workflow run, scoped to that repository, which is enough to push to that repository's own GitHub Container Registry. For anything requiring longer-lived or broader credentials, you'd store them as encrypted **repository secrets** and reference them as `${{ secrets.NAME }}` — never hardcode credentials directly in a workflow file.

### Closing the GitOps Loop

The final piece connects this phase back to Phase 4. When a workflow commits an updated image tag to your chart's `values.yaml` and pushes it, that push is indistinguishable from one you made by hand in Phase 4's Exercise 4 — ArgoCD detects the new commit and syncs it the same way. This is the payoff of GitOps: your CI/CD pipeline never needs cluster credentials or kubectl access at all. It only needs to be able to write to Git.

## Hands-On Exercises

### Exercise 1: A Basic Validation Workflow

**Objective:** Create your first GitHub Actions workflow that lints your Helm chart and validates YAML on every push.

See [exercise-1-basic-workflow.md](exercise-1-basic-workflow.md) for complete instructions.

### Exercise 2: Build and Push the Image

**Objective:** Extend the workflow to build your Phase 2 Dockerfile and push the image to GitHub Container Registry, tagged with the commit SHA.

See [exercise-2-build-and-push.md](exercise-2-build-and-push.md) for complete instructions.

### Exercise 3: Automate the Helm Chart Update

**Objective:** Add a job that updates your chart's `values.yaml` with the new image tag and commits the change back to the repository.

See [exercise-3-update-helm-chart.md](exercise-3-update-helm-chart.md) for complete instructions.

### Exercise 4: End-to-End Deployment

**Objective:** Push a code change and trace it through the entire pipeline — build, chart update, and ArgoCD sync — to a running pod, with no manual commands.

See [exercise-4-end-to-end.md](exercise-4-end-to-end.md) for complete instructions.

## Troubleshooting

### Workflow doesn't trigger

Confirm the workflow file is on the branch you pushed to and lives under `.github/workflows/`. Check the **Actions** tab on GitHub for the run, or its absence, to confirm whether it fired at all.

### Permission denied pushing to the registry or repository

By default, `GITHUB_TOKEN` has read-only repository permissions. Add a `permissions:` block to your workflow (or job) granting `contents: write` for chart commits and `packages: write` for registry pushes.

### Image builds locally but fails in the workflow

Runners start from a clean environment with no local Docker cache. Confirm your Dockerfile doesn't depend on files excluded by `.dockerignore` or on local state that only exists on your machine.

### Automated commit creates a merge conflict or infinite loop

Scope the chart-update job's trigger carefully — a workflow that commits back to the same branch it's triggered by can retrigger itself. Use `paths-ignore` on the trigger, or a dedicated bot commit message you can filter on, to avoid loops.

### ArgoCD doesn't sync after the automated commit

Confirm the automated commit actually landed on the branch your Application's `targetRevision` tracks, and that automated sync with `selfHeal` is still enabled from Phase 4.

## Next Steps

Your pipeline is now fully automated: a `git push` builds, packages, and deploys your application without further intervention. The final phase adds visibility into that running system — you'll deploy Prometheus and Grafana to observe your application's health and correlate deployment events, like the ones you've been triggering all course, with real metric changes.

Continue to [Phase 7 – Observability and Metrics](../phase-7-observability/README.md).

## Additional Resources

**Official Documentation:**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Publishing Docker images to GHCR](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Authentication in a workflow](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)

**Video Tutorials:**
- [GitHub Actions Tutorial for Beginners (30 min)](https://www.youtube.com/watch?v=R8_veQiYBjI) - TechWorld with Nana
