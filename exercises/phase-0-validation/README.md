# Phase 0: Environment Validation

Verify your local GitOps environment is configured correctly before beginning technical exercises. This phase confirms the Kubernetes cluster is operational, container operations function correctly, and end-to-end connectivity works as expected.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Local Kubernetes Development](#local-kubernetes-development)
  - [Container Runtime Architecture](#container-runtime-architecture)
  - [kubectl Configuration](#kubectl-configuration)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Validate Kubernetes Cluster](#exercise-1-validate-kubernetes-cluster)
  - [Exercise 2: Test Container Operations](#exercise-2-test-container-operations)
  - [Exercise 3: Confirm Cluster Connectivity](#exercise-3-confirm-cluster-connectivity)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

A properly configured local development environment is essential for effective GitOps learning. Before diving into Kubernetes deployments, Helm charts, or ArgoCD configurations, you must confirm that your foundational infrastructure works correctly. This validation phase prevents hours of frustration caused by misconfigured tools or incomplete installations.

This phase walks through systematic verification of every component in your local stack. You will confirm that Colima provides a functional container runtime, Minikube runs a healthy Kubernetes cluster, kubectl communicates with the cluster API server, and container operations work end-to-end. Each verification step includes expected outputs so you can identify problems immediately.

Environment validation is not merely a checklist exercise. Understanding how these components interact—how Colima provides the Docker socket that Minikube uses, how kubectl authenticates to the API server, how containers are scheduled and run—builds the mental model necessary for troubleshooting complex issues later. The time invested in thorough validation pays dividends throughout the remaining phases.

## Learning Objectives

By completing this phase, you will be able to:

1. Confirm the Minikube Kubernetes cluster is running and all system pods are healthy.

2. Validate kubectl can communicate with the Kubernetes API server and execute basic commands.

3. Test Docker container operations including image pulls, container creation, networking, and log inspection.

4. Demonstrate basic Kubernetes operations by deploying a test pod and confirming it reaches Running state.

5. Execute commands inside running pods and retrieve their logs for debugging purposes.

6. Identify and resolve common environment setup issues using diagnostic commands and systematic troubleshooting.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Prerequisites** - All steps in [PREREQUISITES.md](../../PREREQUISITES.md) including running `./scripts/setup-macos.sh`

2. **Verified Tool Installation** - All commands from PREREQUISITES.md verification section executed successfully

3. **System Resources Available** - Minimum 8GB RAM, 4 CPU cores, 50GB disk space

4. **Colima and Minikube Running** - Both services started and operational

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

**Video Tutorials:**
- [Minikube Tutorial for Beginners (12 min)](https://www.youtube.com/watch?v=E2pP1MOfo3g) - TechWorld with Nana
- [Kubernetes Explained in 6 Minutes (6 min)](https://www.youtube.com/watch?v=TlHvYWVUZyc) - ByteByteGo

## Hands-On Exercises

### Exercise 1: Validate Kubernetes Cluster

**Objective:** Confirm the Minikube Kubernetes cluster is healthy and all system components are operational.

**Steps:**

1. Display cluster information
   ```bash
   kubectl cluster-info
   ```
   
   Expected output shows Kubernetes control plane running at a URL like `https://127.0.0.1:xxxxx` and CoreDNS running.

2. Verify the current kubectl context
   ```bash
   kubectl config current-context
   ```
   
   Expected output: `minikube`
   
   If the context is not minikube, switch to it:
   ```bash
   kubectl config use-context minikube
   ```

3. List all nodes in the cluster
   ```bash
   kubectl get nodes
   ```
   
   Expected output:
   ```
   NAME       STATUS   ROLES           AGE   VERSION
   minikube   Ready    control-plane   10m   v1.28.x
   ```
   
   The STATUS must be "Ready". AGE shows how long since the cluster started.

4. Check system pods are running
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

5. Verify cluster resource availability
   ```bash
   kubectl top node
   ```
   
   Expected output shows CPU and memory usage for the cluster node. If this command fails with "Metrics API not available", enable the metrics-server addon:
   ```bash
   minikube addons enable metrics-server
   kubectl wait --for=condition=available --timeout=60s deployment/metrics-server -n kube-system
   ```
   
   Retry the `kubectl top node` command after metrics-server is ready.

6. List all available namespaces
   ```bash
   kubectl get namespaces
   ```
   
   Expected output shows default namespaces including default, kube-system, kube-public, and kube-node-lease.

**Verification:**

All system pods should show STATUS "Running" and READY column showing "1/1" or appropriate numbers. The cluster node must show STATUS "Ready". Any pods in "Pending", "CrashLoopBackOff", or "Error" states indicate cluster problems requiring troubleshooting.

### Exercise 2: Test Container Operations

**Objective:** Validate Docker functionality by pulling images, running containers, inspecting their state, and verifying networking.

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
   
   Expected output shows nginx access logs including the curl request from step 5.

7. Inspect container details
   ```bash
   docker inspect test-nginx
   ```
   
   Expected output shows detailed JSON configuration including network settings, mounts, and environment variables.

8. Stop and remove the test container
   ```bash
   docker stop test-nginx
   docker rm test-nginx
   ```

9. Verify container removal
   ```bash
   docker ps -a | grep test-nginx
   ```
   
   Expected output is empty, confirming the container was removed.

**Verification:**

The curl command should return HTML content, confirming the container runs correctly and port mapping works. If curl fails, check `docker ps` shows the container running and the PORT column shows "0.0.0.0:8080->80/tcp".

### Exercise 3: Confirm Cluster Connectivity

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

5. View the pod's YAML definition
   ```bash
   kubectl get pod test-pod -n validation-test -o yaml
   ```
   
   This shows the complete pod specification as Kubernetes stored it, including fields Kubernetes added automatically.

6. Execute a command inside the pod
   ```bash
   kubectl exec test-pod -n validation-test -- nginx -v
   ```
   
   Expected output: `nginx version: nginx/x.xx.x`

7. Start an interactive shell inside the pod
   ```bash
   kubectl exec test-pod -n validation-test -it -- sh
   ```
   
   This opens a shell prompt inside the container. Test the environment:
   ```bash
   # Inside the pod
   hostname
   cat /etc/os-release
   exit
   ```

8. View pod logs
   ```bash
   kubectl logs test-pod -n validation-test
   ```
   
   Expected output shows nginx startup messages.

9. Test pod networking using port-forward
```bash
   kubectl port-forward test-pod -n validation-test 8081:80
```
   
   This command forwards traffic from your local port 8081 to the pod's port 80. The command will block and show forwarding status.
   
   Expected output:
```
   Forwarding from 127.0.0.1:8081 -> 80
   Forwarding from [::1]:8081 -> 80
```
   
   **Open your web browser and navigate to:**
```
   http://localhost:8081
```
   
   You should see the nginx welcome page displayed in your browser with the message "Welcome to nginx!"
   
   This confirms that Kubernetes networking functions correctly and you can access pod services from your local machine.
   
   Press Ctrl+C in the terminal to stop the port-forward when finished.

10. Delete the test resources
    ```bash
    kubectl delete pod test-pod -n validation-test
    kubectl delete namespace validation-test
    ```

**Verification:**

The pod must reach "Running" status with READY showing "1/1". If the pod stays in "Pending" or "ContainerCreating" for more than 30 seconds, check events with `kubectl describe`. If STATUS shows "ImagePullBackOff", Docker cannot pull the image from the registry, indicating network or Docker configuration issues.

**Success Criteria:**

You have successfully completed Phase 0 when:

1. Minikube cluster shows all components running
2. kubectl communicates with the cluster and lists nodes
3. All system pods in kube-system namespace are Running
4. Docker can pull images, run containers, and handle networking
5. Kubernetes can schedule pods and they reach Running state
6. You can execute commands inside pods and view their logs
7. Port-forwarding enables access to pod services

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

### Metrics Server Not Available

**Symptoms:**
`kubectl top node` fails with "Metrics API not available"

**Diagnosis:**
```bash
kubectl get deployment metrics-server -n kube-system
```

**Resolution:**
```bash
minikube addons enable metrics-server
kubectl wait --for=condition=available --timeout=60s deployment/metrics-server -n kube-system
```

### Pod Stuck in ContainerCreating

**Symptoms:**
Pod remains in ContainerCreating status for more than 60 seconds

**Diagnosis:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

Look for events indicating image pull issues or resource constraints.

**Resolution:**

For image pull issues:
```bash
# Verify Docker can pull the image
docker pull <image-name>
```

For resource constraints:
```bash
# Check node resources
kubectl describe node minikube
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

After successfully validating your environment, proceed to Phase 1 where you will deploy applications to Kubernetes using raw YAML manifests. This phase builds on your confirmed working environment to explore Kubernetes resource definitions, pod lifecycle management, and troubleshooting techniques.

Continue to [Phase 1: Kubernetes Review](../phase-1-kubernetes/README.md).

## Additional Resources

**Official Documentation:**
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl Reference Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Minikube Commands](https://minikube.sigs.k8s.io/docs/commands/)

**Video Tutorials:**
- [Kubernetes Crash Course for Absolute Beginners (1 hour)](https://www.youtube.com/watch?v=s_o8dwzRlu4) - TechWorld with Nana
