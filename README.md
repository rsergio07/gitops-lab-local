# GitOps Lab: Local ArgoCD and Kubernetes Training

A comprehensive local training environment for learning GitOps workflows using ArgoCD, Helm, Terraform, and Kubernetes. This repository provides hands-on exercises that demonstrate deployment automation, configuration management, drift detection, and observability patterns used in production SRE environments. All exercises run locally on Minikube with Colima, eliminating external dependencies while teaching industry-standard practices.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Learning Path Overview](#learning-path-overview)
- [Contributing](#contributing)
- [License](#license)
- [Ready to Begin Your GitOps Journey?](#ready-to-begin-your-gitops-journey)

## Introduction

GitOps represents a fundamental shift in how infrastructure and applications are deployed and managed. By treating Git as the single source of truth for declarative infrastructure and applications, GitOps enables automated, auditable, and repeatable deployments. This approach reduces manual errors, improves reliability, and provides complete visibility into system changes through version control history.

This training repository implements a complete GitOps workflow on your local machine. You will build a deployment pipeline where every change flows through Git, automated CI/CD processes build and package applications, and ArgoCD continuously monitors Git repositories to keep your Kubernetes cluster synchronized with the desired state. When drift occurs—whether from manual changes, failed deployments, or configuration updates—ArgoCD automatically reconciles the cluster back to the state defined in Git.

The hands-on exercises progress from basic Kubernetes deployments to fully automated GitOps workflows. You will containerize applications, package them with Helm charts, provision infrastructure with Terraform, build CI/CD pipelines with GitHub Actions, and implement observability with Prometheus and Grafana. Each phase builds on previous concepts, reinforcing understanding through practical application.

This local environment mirrors production GitOps architectures used by SRE teams at scale. The skills you develop here transfer directly to cloud-based Kubernetes platforms like Amazon EKS, Google GKE, or Azure AKS. By mastering these patterns locally, you gain confidence to implement GitOps in production environments without risking live systems.

## Learning Objectives

By completing this training, you will be able to:

1. Deploy and manage applications on Kubernetes using declarative manifests and explain the benefits of declarative configuration over imperative commands.

2. Containerize applications with Docker using multi-stage builds, security best practices, and efficient image layering techniques.

3. Create and manage Helm charts with templating, value overrides, and environment-specific configurations for consistent deployments across multiple environments.

4. Implement GitOps workflows with ArgoCD, including application definitions, sync policies, and automated drift detection and reconciliation.

5. Provision Kubernetes infrastructure as code using Terraform, managing namespaces, resource quotas, and RBAC policies declaratively.

6. Build CI/CD pipelines with GitHub Actions that automatically build container images, update Helm charts, and trigger GitOps deployments on code commits.

7. Implement observability with Prometheus and Grafana, including metrics collection, PromQL queries, dashboard creation, and correlation of deployment events with system metrics.

8. Troubleshoot common Kubernetes, Helm, and ArgoCD issues using diagnostic commands, logs analysis, and systematic debugging approaches.

## Prerequisites

Before starting this training, ensure you have completed the environment setup, see [PREREQUISITES.md](PREREQUISITES.md).

## Learning Path Overview

The training consists of seven progressive phases designed to build GitOps expertise systematically:

**Phase 0: Environment Validation (1-2 hours)**
Verify all tools are installed correctly and the Kubernetes cluster is operational. Confirm kubectl access, test basic pod deployments, and validate Docker image building capabilities.

**Phase 1: Kubernetes Review (1-2 hours)**
Review Kubernetes fundamentals by deploying applications with raw YAML manifests. Work with Deployments, Services, ConfigMaps, and health probes. Practice troubleshooting pod failures and understanding Kubernetes resource lifecycle.

**Phase 2: Containerization Basics (2-3 hours)**
Build Docker images using multi-stage builds and security best practices. Understand Dockerfile instructions, image layering, and local registry operations. Deploy custom-built images to Kubernetes.

**Phase 3: Helm Chart Creation (3-4 hours)**
Convert raw Kubernetes manifests into reusable Helm charts with templating and parameterization. Learn Helm template functions, values hierarchy, and environment-specific configurations. Deploy applications across multiple namespaces with different configurations.

**Phase 4: GitOps with ArgoCD (4-5 hours)**
Install ArgoCD and implement GitOps workflows. Create Application manifests, configure sync policies, and observe automated drift detection. Deliberately create configuration drift and watch ArgoCD reconcile the cluster back to the desired state defined in Git.

**Phase 5: Infrastructure as Code with Terraform (3-4 hours)**
Provision Kubernetes infrastructure declaratively using Terraform. Manage namespaces, resource quotas, and RBAC policies as code. Understand Terraform state management and the plan-apply workflow.

**Phase 6: CI/CD with GitHub Actions (4-5 hours)**
Build progressive CI/CD pipelines that automate the entire deployment lifecycle. Start with basic workflows, add Docker image building, implement Helm chart updates, and complete end-to-end automation from code commit to production deployment.

**Phase 7: Observability and Metrics (3-4 hours)**
Deploy Prometheus and Grafana for comprehensive observability. Configure ServiceMonitors for application metrics scraping, write PromQL queries, create Grafana dashboards, and correlate deployment events with system metrics changes.

Total estimated time: 20-27 hours of hands-on work. Phases can be completed at your own pace, with each phase providing clear completion criteria before advancing to the next.

## Contributing

Contributions are welcome and encouraged. Whether you find errors, want to improve existing exercises, or have ideas for new content, please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.

## Ready to Begin Your GitOps Journey?

**Start your journey to SRE excellence** with [Phase 0: Environment Validation](exercises/phase-0-validation/).

**Transform from developer to Site Reliability Engineer** through systematic implementation of production-ready GitOps platforms that demonstrate enterprise-grade operational capabilities and advance your professional career in cloud-native infrastructure and reliability engineering.

---

*Master the art and science of keeping production systems running reliably, efficiently, and cost-effectively while enabling rapid business growth through robust technical foundations.*

![Kubernetes SRE Cloud-Native](https://img.shields.io/badge/Kubernetes-SRE%20Cloud--Native-blue)