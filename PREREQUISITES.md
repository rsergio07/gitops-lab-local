# Prerequisites

## Overview

This course teaches **SRE Automation Mastery** through hands-on exercises using a **completely local, open-source stack**. You'll build a production-grade automated platform entirely on your machine using industry-standard tools.

## What We're Deploying

### Core Platform (Local Kubernetes)
- **Colima**: Container runtime (Docker Engine) for macOS
- **Minikube**: Local Kubernetes cluster
- **Helm**: Kubernetes package manager for application deployment
- **ArgoCD**: GitOps continuous delivery tool for automated deployments

### Automation & Infrastructure Tools
- **Terraform**: Infrastructure as Code for Kubernetes resources
- **Ansible**: Configuration management and automation
- **AWX**: Open-source web-based Ansible automation platform

### Observability Stack
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Metrics visualization and dashboards
- **Alertmanager**: Alert routing and management
- **Loki** (optional): Log aggregation

## macOS Setup

### Automated Installation

All required tools are installed automatically using our setup script:

```bash
./scripts/setup-macos.sh
```

The script installs and configures:
- Homebrew (macOS package manager)
- Colima (Docker Engine runtime for macOS)
- Minikube (local Kubernetes cluster)
- kubectl, helm, terraform, ansible, and other CLI tools
- Verification of all installations
- Kubernetes cluster initialization and readiness check

### After Installation

Verify everything is working:

```bash
# Check Colima is running
colima status

# Check Minikube cluster
minikube status
kubectl cluster-info
kubectl get nodes

# Check installed tools
docker version
helm version
terraform version
ansible --version
```

## Other Operating Systems

This course is designed for macOS using Colima + Minikube. For Windows or Linux, refer to official documentation:

- **Minikube**: https://minikube.sigs.k8s.io/docs/start/
- **Docker Engine**: https://docs.docker.com/engine/install/
- **Colima** (macOS/Linux): https://github.com/abiosoft/colima
- **Kubernetes**: https://kubernetes.io/docs/tasks/tools/
- **Helm**: https://helm.sh/docs/intro/install/
- **Terraform**: https://developer.hashicorp.com/terraform/install
- **Ansible**: https://docs.ansible.com/ansible/latest/installation_guide/

All exercises use the same concepts and commands across operating systems.

## System Requirements

### Hardware
- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 50GB free space for Docker images and Kubernetes resources
- **macOS**: Version 11.0 (Big Sur) or later

### Why These Requirements?
Running a local Kubernetes cluster with Minikube and multiple services requires significant resources. The setup script will check your system before installation. Colima is lightweight compared to Docker Desktop, but Minikube still needs adequate CPU and RAM.

## Version Control

### GitHub Account (Free)
Required only for:
- GitOps workflows (pushing/pulling configuration)
- Version controlling your exercise solutions
- Optional: sharing your progress

You can also use GitLab, Gitea, or any Git hosting service.

## Technical Prerequisites

### Required Knowledge
- Basic command-line proficiency (bash/zsh)
- Understanding of Git basics (clone, commit, push)
- Familiarity with YAML syntax
- Basic understanding of containers and Docker concepts

### Recommended (Not Required)
- Prior Kubernetes experience helpful but not mandatory
- Basic understanding of infrastructure concepts
- Any programming experience (helpful for templating)

## Cost

**$0** - Everything is free and open-source:
- All tools are free (Colima, Minikube, Kubernetes, Helm, Terraform, Ansible, AWX, ArgoCD)
- No Docker Desktop license required (using open-source Colima)
- No cloud resources or subscriptions
- No trial periods or credit cards
- Runs entirely on your local machine

## Getting Started

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/sre-automation-mastery.git
   cd sre-automation-mastery
   ```

2. **Run the setup script**
   ```bash
   ./scripts/setup-macos.sh
   ```

3. **Start learning**
   ```bash
   cd exercises/module1-helm/exercise1
   cat README.md
   ```