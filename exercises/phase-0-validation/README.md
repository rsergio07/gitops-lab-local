# Phase 0: Environment Validation

Verify your local GitOps environment is configured correctly before beginning technical exercises. This phase confirms all required tools are installed, the Kubernetes cluster is operational, and basic functionality works as expected.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Local Kubernetes Development](#local-kubernetes-development)
  - [Container Runtime Architecture](#container-runtime-architecture)
  - [kubectl Configuration](#kubectl-configuration)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Verify Tool Installations](#exercise-1-verify-tool-installations)
  - [Exercise 2: Validate Kubernetes Cluster](#exercise-2-validate-kubernetes-cluster)
  - [Exercise 3: Test Container Operations](#exercise-3-test-container-operations)
  - [Exercise 4: Confirm Cluster Connectivity](#exercise-4-confirm-cluster-connectivity)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

A properly configured local development environment is essential for effective GitOps learning. Before diving into Kubernetes deployments, Helm charts, or ArgoCD configurations, you must confirm that your foundational infrastructure works correctly. This validation phase prevents hours of frustration caused by misconfigured tools or incomplete installations.

This phase walks through systematic verification of every component in your local stack. You will confirm that Colima provides a functional container runtime, Minikube runs a healthy Kubernetes cluster, kubectl communicates with the cluster API server, and all supporting tools are accessible. Each verification step includes expected outputs so you can identify problems immediately.

Environment validation is not merely a checklist exercise. Understanding how these components interact—how Colima provides the Docker socket that Minikube uses, how kubectl authenticates to the API server, how Helm communicates with Kubernetes—builds the mental model necessary for troubleshooting complex issues later. The time invested in thorough validation pays dividends throughout the remaining phases.

## Learning Objectives

By completing this phase, you will be able to:

1. Verify all required CLI tools are installed and accessible in your system PATH.

2. Confirm the Minikube Kubernetes cluster is running and all system pods are healthy.

3. Validate kubectl can communicate with the Kubernetes API server and execute basic commands.

4. Test Docker container operations including image pulls, container creation, and log inspection.

5. Demonstrate basic Kubernetes operations by deploying a test pod and confirming it reaches Running state.

6. Identify and resolve common environment setup issues using diagnostic commands and log analysis.

## Prerequisites

Before starting this phase, ensure you have:

1. **macOS 11.0 or later** - Required for Colima compatibility

2. **Setup Script Execution** - You must have run `./scripts/setup-macos.sh` successfully

3. **System Resources Available** - Minimum 8GB RAM, 4 CPU cores, 50GB disk space

4. **Terminal Access** - Familiarity with command-line operations

## Theoretical Foundation

### Local Kubernetes Development

Kubernetes in production typically runs across multiple physical or virtual machines in a data center or cloud environment. Local development environments simulate this distributed system on a single machine using tools like Minikube. Minikube creates a virtual machine or container that runs all Kubernetes components—the API server, scheduler, controller manager, and kubelet—in one place.

This approach allows developers and SRE practitioners to test Kubernetes configurations, deployments, and operational procedures without requiring expensive cloud resources or complex multi-node setups. The Kubernetes API remains identical whether running locally or in production, meaning configurations tested locally work in production clusters without modification.

Minikube supports multiple drivers that provide the underlying virtualization. This training uses the Docker driver, which runs Kubernetes inside Docker containers rather than full virtual machines. This approach is lighter weight and integrates well with Colima as the container runtime. Understanding this architecture helps troubleshoot issues when components fail to communicate.

### Container Runtime Architecture

Colima provides a Docker-compatible container runtime on macOS without requiring Docker Desktop. It runs a minimal Linux virtual machine using macOS's native virtualization framework, then runs the Docker daemon inside that VM. Applications on macOS communicate with this Docker daemon through a Unix socket, making it transparent to tools like Minikube or docker CLI.

When you run docker commands, they send requests to the Docker daemon running in Colima's VM. The daemon manages container lifecycles, image storage, and networking. Minikube uses this same Docker daemon to create containers that run Kubernetes components. This shared infrastructure means both regular Docker containers and Minikube's Kubernetes cluster coexist on the same runtime.

The layered architecture—macOS host, Colima VM, Docker daemon, Kubernetes containers—creates dependencies that must all function correctly. If Colima stops, Docker commands fail. If Docker is unavailable, Minikube cannot start. Understanding these relationships helps diagnose where failures occur in the stack.

### kubectl Configuration

The kubectl command-line tool communicates with Kubernetes clusters through their API servers. Configuration for kubectl lives in a kubeconfig file, typically at `~/.kube/config`, which contains cluster connection details, authentication credentials, and context definitions. A context combines a cluster, user, and namespace into a named configuration that kubectl uses for commands.

When Minikube starts, it automatically updates your kubeconfig file with connection information for the local cluster. This includes the API server URL, certificate authority data for secure communication, and client certificates for authentication. The `kubectl config` commands allow you to view and modify this configuration, switch between multiple clusters, and troubleshoot connection issues.

Understanding kubeconfig structure is essential for multi-cluster management. In production environments, SRE teams manage configurations for development, staging, and production clusters. The same kubectl tool accesses all clusters by switching contexts. Validating your local kubeconfig ensures you understand this mechanism before managing multiple environments.

**Key Resources:**
- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Configuration](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

**Video Tutorials:**
- [Minikube Tutorial for Beginners (12 min)](https://www.youtube.com/watch?v=E2pP1MOfo3g) - TechWorld with Nana
- [Kubernetes Architecture Explained (15 min)](https://www.youtube.com/watch?v=8C_SCDbUJTg) - IBM Technology

## Hands-On Exercises

### Exercise 1: Verify Tool Installations

**Objective:** Confirm all required command-line tools are installed and report their versions.

**Steps:**

1. Check Colima installation and status
```bash
   colima version
   colima status
```
   
   Expected output shows Colima version and status "Running". If status shows "Stopped", start Colima:
```bash
   colima start
```

2. Verify Docker CLI is accessible
```bash
   docker --version
   docker ps
```
   
   Expected output shows Docker version and running containers list (may be empty). If you see "Cannot connect to the Docker daemon", Colima is not running.

3. Check Minikube installation
```bash
   minikube version
   minikube status
```
   
   Expected output shows Minikube version and cluster status. All components should show "Running" or "Configured".

4. Verify kubectl installation
```bash
   kubectl version --client
```
   
   Expected output shows kubectl client version. Server version check comes in the next exercise.

5. Check Helm installation
```bash
   helm version
```
   
   Expected output shows Helm version information.

6. Verify Terraform installation
```bash
   terraform version
```
   
   Expected output shows Terraform version.

**Verification:**

All commands should execute without errors and display version information. If any command fails with "command not found", the tool is not installed or not in your PATH. Re-run the setup script:
```bash
./scripts/setup-macos.sh
```

### Exercise 2: Validate Kubernetes Cluster

**Objective:** Confirm the Minikube Kubernetes cluster is healthy and all system components are operational.

**Steps:**

1. Display cluster information
```bash
   kubectl cluster-info
```
   
   Expected output shows Kubernetes control plane running at a URL like `https://127.0.0.1:xxxxx` and CoreDNS running.

2. List all nodes in the cluster
```bash
   kubectl get nodes
```
   
   Expected output:
```
   NAME       STATUS   ROLES           AGE   VERSION
   minikube   Ready    control-plane   10m   v1.28.x
```
   
   The STATUS must be "Ready". AGE shows how long since the cluster started.

3. Check system pods are running
```bash
   kubectl get pods -n kube-system
```
   
   Expected output shows multiple pods with STATUS "Running". Key pods include:
   - coredns (DNS service)
   - etcd (cluster state storage)
   - kube-apiserver (API endpoint)
   - kube-controller-manager (resource controller)
   - kube-scheduler (pod placement)
   - kube-proxy (network proxy)

4. Verify cluster resource availability
```bash
   kubectl top node
```
   
   Expected output shows CPU and memory usage for the cluster node. If this command fails with "Metrics API not available", enable the metrics-server addon:
```bash
   minikube addons enable metrics-server
```

**Verification:**

All system pods should show STATUS "Running" and READY column showing "1/1" or appropriate numbers. The cluster node must show STATUS "Ready". Any pods in "Pending", "CrashLoopBackOff", or "Error" states indicate cluster problems requiring troubleshooting.

### Exercise 3: Test Container Operations

**Objective:** Validate Docker functionality by pulling images, running containers, and inspecting their state.

**Steps:**

1. Pull a test container image
```bash
   docker pull nginx:alpine
```
   
   Expected output shows download progress for image layers. This confirms Docker can reach container registries and store images locally.

2. List downloaded images
```bash
   docker images nginx
```
   
   Expected output:
```
   REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
   nginx        alpine    xxxxx          2 days ago    40MB
```

3. Run a container from the image
```bash
   docker run -d --name test-nginx -p 8080:80 nginx:alpine
```
   
   Expected output shows a long container ID. The `-d` flag runs the container in background, `--name` assigns a friendly name, and `-p` maps port 8080 on your host to port 80 in the container.

4. Verify the container is running
```bash
   docker ps
```
   
   Expected output shows the test-nginx container with STATUS "Up".

5. Test the running container
```bash
   curl http://localhost:8080
```
   
   Expected output shows HTML from the nginx welcome page.

6. View container logs
```bash
   docker logs test-nginx
```
   
   Expected output shows nginx access logs including the curl request.

7. Stop and remove the test container
```bash
   docker stop test-nginx
   docker rm test-nginx
```

**Verification:**

The curl command should return HTML content, confirming the container runs correctly and port mapping works. If curl fails, check `docker ps` shows the container running and the PORT column shows "0.0.0.0:8080->80/tcp".

### Exercise 4: Confirm Cluster Connectivity

**Objective:** Deploy a test pod to Kubernetes and verify it runs successfully, demonstrating end-to-end cluster functionality.

**Steps:**

1. Create a test namespace
```bash
   kubectl create namespace validation-test
```
   
   Expected output: `namespace/validation-test created`

2. Deploy a test pod
```bash
   kubectl run test-pod --image=nginx:alpine --namespace=validation-test
```
   
   Expected output: `pod/test-pod created`

3. Watch the pod until it reaches Running state
```bash
   kubectl get pod test-pod -n validation-test --watch
```
   
   Expected progression:
```
   NAME       READY   STATUS              RESTARTS   AGE
   test-pod   0/1     ContainerCreating   0          5s
   test-pod   1/1     Running             0          10s
```
   
   Press Ctrl+C once STATUS shows "Running".

4. Describe the pod to view detailed information
```bash
   kubectl describe pod test-pod -n validation-test
```
   
   Expected output shows events including image pull, container creation, and pod start. The Events section at the bottom should show "Successfully pulled image" and "Started container".

5. Execute a command inside the pod
```bash
   kubectl exec test-pod -n validation-test -- nginx -v
```
   
   Expected output: `nginx version: nginx/x.xx.x`

6. View pod logs
```bash
   kubectl logs test-pod -n validation-test
```
   
   Expected output shows nginx startup messages.

7. Delete the test resources
```bash
   kubectl delete pod test-pod -n validation-test
   kubectl delete namespace validation-test
```

**Verification:**

The pod must reach "Running" status with READY showing "1/1". If the pod stays in "Pending" or "ContainerCreating" for more than 30 seconds, check events with `kubectl describe`. If STATUS shows "ImagePullBackOff", Docker cannot pull the image from the registry, indicating network or Docker configuration issues.

**Success Criteria:**

You have successfully completed Phase 0 when:

1. All tool version commands execute without errors
2. Minikube status shows all components running
3. kubectl can communicate with the cluster and list nodes
4. Docker can pull images, run containers, and handle networking
5. Kubernetes can schedule pods and they reach Running state
6. You can execute commands inside pods and view their logs

## Troubleshooting

### Colima Not Running

**Symptoms:**
Docker commands fail with "Cannot connect to the Docker daemon at unix:///var/run/docker.sock"

**Diagnosis:**
```bash
colima status
```

**Resolution:**
```bash
colima start --cpu 4 --memory 8 --disk 50
```

Wait 30-60 seconds for Colima to fully start, then verify:
```bash
docker ps
```

### Minikube Cluster Unhealthy

**Symptoms:**
kubectl commands timeout or system pods show CrashLoopBackOff status

**Diagnosis:**
```bash
minikube status
minikube logs
```

**Resolution:**
Delete and recreate the cluster:
```bash
minikube delete
minikube start --driver=docker --cpus=4 --memory=6144
```

This process takes 2-3 minutes. Verify with:
```bash
kubectl get nodes
kubectl get pods -n kube-system
```

### kubectl Context Incorrect

**Symptoms:**
kubectl commands fail with "The connection to the server localhost:8080 was refused"

**Diagnosis:**
```bash
kubectl config current-context
```

**Resolution:**
```bash
kubectl config use-context minikube
kubectl cluster-info
```

### Insufficient System Resources

**Symptoms:**
Colima or Minikube fails to start, or pods remain in Pending state

**Diagnosis:**
```bash
# Check available RAM
top -l 1 | grep PhysMem

# Check disk space
df -h
```

**Resolution:**
Close unnecessary applications to free RAM. If disk space is low, clean up Docker images:
```bash
docker system prune -a
```

Restart Colima with adjusted resources:
```bash
colima stop
colima start --cpu 4 --memory 6 --disk 40
```

## Next Steps

After successfully validating your environment, proceed to Phase 1 where you will deploy applications to Kubernetes using raw YAML manifests. This phase builds on your confirmed working environment to explore Kubernetes resource definitions, pod lifecycle management, and basic troubleshooting techniques.

Continue to [Phase 1: Kubernetes Review](../phase-1-kubernetes/README.md).

## Additional Resources

**Official Documentation:**
- [Colima GitHub Repository](https://github.com/abiosoft/colima)
- [Minikube Getting Started](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

**Video Tutorials:**
- [Docker for Beginners (13 min)](https://www.youtube.com/watch?v=pg19Z8LL06w) - TechWorld with Nana
- [kubectl Command Basics (11 min)](https://www.youtube.com/watch?v=o-K7HcG5v7w) - KodeKloud