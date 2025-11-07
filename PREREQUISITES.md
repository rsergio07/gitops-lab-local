# Prerequisites

## Overview

This training teaches **GitOps workflows and SRE practices** through hands-on exercises using a **completely local, open-source stack**. You will build a production-grade GitOps platform entirely on your machine using industry-standard tools.

## What You Will Deploy

### Core Platform (Local Kubernetes)
- **Colima**: Container runtime (Docker Engine) for macOS
- **Minikube**: Local Kubernetes cluster
- **Helm**: Kubernetes package manager for application deployment
- **ArgoCD**: GitOps continuous delivery tool for automated deployments

### Automation & Infrastructure Tools
- **Terraform**: Infrastructure as Code for Kubernetes resources
- **GitHub Actions**: CI/CD pipeline automation

### Observability Stack
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Metrics visualization and dashboards

## System Requirements

### Hardware
- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 50GB free space for Docker images and Kubernetes resources
- **macOS**: Version 11.0 (Big Sur) or later

### Why These Requirements?
Running a local Kubernetes cluster with Minikube and multiple services requires significant resources. The setup script checks your system before installation. Colima is lightweight compared to Docker Desktop, but Minikube still needs adequate CPU and RAM for reliable operation.

## Technical Prerequisites

### Required Knowledge
- Basic command-line proficiency (bash/zsh)
- Understanding of Git basics (clone, commit, push)
- Familiarity with YAML syntax
- Basic understanding of containers and Docker concepts

### Recommended Knowledge (Not Required)
- Prior Kubernetes experience helpful but not mandatory
- Basic understanding of infrastructure concepts
- Programming experience (helpful for templating and troubleshooting)

## Version Control Requirements

### GitHub Account (Free)
A GitHub account is required for:
- GitOps workflows (pushing and pulling configuration changes)
- CI/CD pipeline exercises with GitHub Actions
- Version controlling your exercise solutions

You can use GitLab or other Git hosting services for basic exercises, though GitHub Actions exercises require a GitHub account.

## Getting Started

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/gitops-lab-local.git
cd gitops-lab-local
```

### Step 2: Run the Automated Setup Script
```bash
./scripts/setup-macos.sh
```

The setup script performs the following operations:

1. Checks system requirements (CPU, RAM, disk space, macOS version)
2. Installs Homebrew if not already present
3. Installs and configures Colima (Docker Engine runtime)
4. Installs Minikube and starts a local Kubernetes cluster
5. Installs kubectl, Helm, Terraform, and supporting CLI tools
6. Enables essential Minikube addons (metrics-server, dashboard, ingress)
7. Verifies all installations completed successfully
8. Creates helpful shell aliases for common commands

The script is idempotent and safe to run multiple times. If tools are already installed, it skips installation and verifies their status.

### Step 3: Verify Installation

After the setup script completes, verify all components are working:

```bash
# Check Colima status
colima status
```

Expected output: `colima is running`

```bash
# Check Minikube cluster status
minikube status
```

Expected output shows all components running:

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

```bash
# Verify kubectl can communicate with cluster
kubectl cluster-info
kubectl get nodes
```

Expected output shows cluster URL and one node in Ready status.

```bash
# Check all system pods are running
kubectl get pods -A
```

All pods should show STATUS "Running" and READY "1/1" or appropriate numbers.

```bash
# Verify installed tool versions
docker --version
helm version
terraform version
kubectl version --client
```

All commands should display version information without errors.

### Step 4: Start the Training

Begin with Phase 0 to validate your environment:

```bash
cd exercises/phase-0-validation
cat README.md
```

Follow the Phase 0 exercises to perform comprehensive validation before starting technical training.

## Troubleshooting Setup Issues

### Colima Fails to Start

If Colima does not start, verify no other container runtimes like Docker Desktop are running:

```bash
# Stop Docker Desktop if running
# Restart Colima
colima stop
colima start --cpu 4 --memory 8 --disk 50
```

### Minikube Cluster Does Not Start

If Minikube fails to start, ensure Colima is running first:

```bash
colima status
minikube delete
minikube start --driver=docker --cpus=4 --memory=6144
```

### Insufficient System Resources

If your system does not meet minimum requirements, the setup script displays warnings. Close resource-intensive applications and retry. Consider upgrading RAM if you have less than 8GB.

### Command Not Found Errors

If tools are not found after installation, restart your terminal to reload the PATH. For Apple Silicon Macs, ensure Homebrew is in your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

## Other Operating Systems

This training is designed specifically for macOS using Colima and Minikube. For Windows or Linux users, the concepts and exercises remain identical, but you must install tools using platform-specific methods.

Refer to official documentation for installation on other platforms:

- **Minikube**: https://minikube.sigs.k8s.io/docs/start/
- **Docker Engine**: https://docs.docker.com/engine/install/
- **Colima** (Linux): https://github.com/abiosoft/colima
- **Kubernetes**: https://kubernetes.io/docs/tasks/tools/
- **Helm**: https://helm.sh/docs/intro/install/
- **Terraform**: https://developer.hashicorp.com/terraform/install

All Kubernetes commands, YAML manifests, and operational concepts work identically across operating systems.

## Cost

**Total Cost: $0**

Everything required for this training is free and open-source:

- All tools are free (Colima, Minikube, Kubernetes, Helm, Terraform, ArgoCD, Prometheus, Grafana)
- No Docker Desktop license required (using open-source Colima instead)
- No cloud resources or subscriptions needed
- No trial periods or credit card requirements
- Entire platform runs locally on your machine

## Next Steps

After completing setup and verification, proceed to the main README to understand the full learning path and begin Phase 0 validation exercises.

Return to [Main README](README.md) to continue.