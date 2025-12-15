# Phase 1: Kubernetes Review

Deploy and manage applications on Kubernetes using raw YAML manifests and kubectl commands. This phase reinforces Kubernetes fundamentals including Deployments, Services, ConfigMaps, and pod lifecycle management before introducing higher-level abstractions like Helm charts.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Kubernetes Resource Model](#kubernetes-resource-model)
  - [Deployments and ReplicaSets](#deployments-and-replicasets)
  - [Services and Networking](#services-and-networking)
  - [ConfigMaps and Configuration Management](#configmaps-and-configuration-management)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Deploy with Raw Manifests](#exercise-1-deploy-with-raw-manifests)
  - [Exercise 2: ConfigMap Changes](#exercise-2-configmap-changes)
  - [Exercise 3: Troubleshoot Pods](#exercise-3-troubleshoot-pods)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Kubernetes manages containerized applications through declarative configuration files written in YAML. These manifests describe the desired state of your applications, and Kubernetes continuously works to maintain that state. Understanding how to write, deploy, and troubleshoot raw Kubernetes manifests is fundamental to all higher-level tools and workflows.

This phase focuses on deploying a sample application using only kubectl and YAML files. You will create Deployments that manage pod replicas, Services that expose applications to network traffic, and ConfigMaps that provide configuration data. By working directly with Kubernetes primitives, you develop the mental model necessary to understand how tools like Helm and ArgoCD abstract these same resources.

The exercises progress from basic deployment to configuration management and troubleshooting. You will modify running applications, observe how Kubernetes responds to changes, and diagnose common pod failures. These skills form the foundation for GitOps workflows where understanding the underlying Kubernetes behavior is essential for resolving sync issues and deployment failures.

## Learning Objectives

By completing this phase, you will be able to:

1. Create and apply Kubernetes manifests for Deployments, Services, and ConfigMaps using kubectl.

2. Explain how Deployments manage ReplicaSets to maintain desired pod counts and handle rolling updates.

3. Expose applications using ClusterIP Services and verify pod-to-service networking functions correctly.

4. Mount ConfigMaps as environment variables and volumes to provide configuration data to applications.

5. Update ConfigMap values and trigger pod restarts to apply new configurations.

6. Diagnose pod failures using kubectl describe, logs, and events to identify root causes.

7. Understand pod lifecycle states including Pending, Running, CrashLoopBackOff, and how Kubernetes transitions between them.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phase 0** - Environment validated and all tools working correctly

2. **Kubernetes Context Set** - kubectl configured to use minikube context
```bash
   kubectl config current-context
```
   Should return: `minikube`

3. **Cluster Resources Available** - Minikube running with adequate resources
```bash
   kubectl get nodes
```
   Node should show STATUS "Ready"

4. **Basic YAML Understanding** - Familiarity with YAML syntax including maps, lists, and indentation

## Theoretical Foundation

### Kubernetes Resource Model

Kubernetes uses a declarative model where you describe the desired state of your system in YAML or JSON files. These files define objects like Pods, Deployments, and Services. You submit these definitions to the Kubernetes API server using kubectl, which stores them in etcd, the cluster's persistent data store. Controllers continuously watch for differences between desired state and actual state, taking action to reconcile any drift.

Every Kubernetes object includes several key fields in its manifest. The `apiVersion` field specifies which version of the Kubernetes API created the object. The `kind` field identifies the object type such as Pod, Deployment, or Service. The `metadata` section contains identifying information including the object's name, namespace, and labels. The `spec` section describes the desired state specific to that object type.

Labels are key-value pairs attached to objects that enable selection and grouping. Selectors use labels to identify sets of objects. For example, a Service uses a selector to determine which pods should receive traffic. A Deployment uses a selector to identify the pods it manages. Understanding labels and selectors is critical because they form the mechanism that connects Kubernetes resources together.

Namespaces provide logical isolation within a cluster. They allow multiple teams or projects to share a cluster while maintaining separation. Resource names must be unique within a namespace but can duplicate across namespaces. Most kubectl commands operate on the default namespace unless you specify otherwise with the `-n` flag.

### Deployments and ReplicaSets

A Deployment provides declarative updates for Pods and ReplicaSets. You describe the desired state in a Deployment manifest, and the Deployment controller changes the actual state to match at a controlled rate. Deployments handle creating and scaling ReplicaSets, which in turn manage Pods. This layered approach enables sophisticated update strategies like rolling updates and rollbacks.

When you create a Deployment, it generates a ReplicaSet with a unique hash in its name. The ReplicaSet creates the specified number of pod replicas. If you update the Deployment's pod template—for example by changing the container image—the Deployment creates a new ReplicaSet and gradually scales it up while scaling down the old ReplicaSet. This rolling update ensures zero downtime during deployments.

The Deployment spec includes several important fields. The `replicas` field specifies how many pod copies should run. The `selector` field identifies which pods belong to this Deployment using label matching. The `template` field contains the pod specification including containers, volumes, and other pod-level settings. The `strategy` field controls how updates roll out, with options for RollingUpdate or Recreate.

ReplicaSets ensure that a specified number of pod replicas are running at any time. If a pod fails or is deleted, the ReplicaSet creates a replacement. If you manually scale a ReplicaSet by editing it directly, the owning Deployment will reconcile back to the desired replica count defined in the Deployment spec. This demonstrates Kubernetes's self-healing capability through continuous reconciliation loops.

### Services and Networking

Pods are ephemeral and can be created or destroyed at any time. Their IP addresses change with each recreation, making direct pod-to-pod communication unreliable. Services provide stable networking endpoints that abstract the dynamic set of pods behind them. A Service monitors for pods matching its selector and automatically updates its endpoint list as pods come and go.

ClusterIP is the default Service type and exposes the Service on an internal IP address within the cluster. Only resources within the cluster can reach ClusterIP Services, making them suitable for internal communication between application components. The Service proxies traffic to backend pods using round-robin load balancing by default.

When you create a Service, Kubernetes assigns it a stable IP address from the cluster's service IP range. The Service also receives a DNS name following the pattern `service-name.namespace.svc.cluster.local`. Applications can use either the IP address or DNS name to reach the Service. CoreDNS, running in the kube-system namespace, handles DNS resolution for Services.

Services use label selectors to identify target pods. The selector in the Service spec must match labels on the pods you want to receive traffic. If no pods match the selector, the Service exists but has no endpoints and traffic sent to it will fail. You can inspect a Service's endpoints using `kubectl get endpoints service-name` to verify it found matching pods.

### ConfigMaps and Configuration Management

ConfigMaps store non-sensitive configuration data as key-value pairs. They decouple configuration from container images, allowing the same image to run with different configurations across development, staging, and production environments. ConfigMaps can be consumed by pods as environment variables, command-line arguments, or files mounted in volumes.

When you mount a ConfigMap as environment variables, each key becomes an environment variable name and its value becomes the variable's value. This approach works well for simple configuration but has limitations—environment variables are set when the container starts and cannot be updated without restarting the pod.

Mounting ConfigMaps as volumes provides more flexibility. Kubernetes projects each ConfigMap key as a file in the mount path, with the file content being the key's value. When you update the ConfigMap, Kubernetes automatically updates the files in mounted volumes, typically within 30-60 seconds. However, applications must reload their configuration to see these changes, which may require custom code or signal handling.

ConfigMap data is stored in etcd without encryption by default. Never store sensitive information like passwords or API keys in ConfigMaps. Use Secrets instead, which provide additional security features. ConfigMaps have a size limit of 1MB, suitable for configuration files but not for large data files.

**Key Resources:**
- [Kubernetes Objects Overview](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

**Video Tutorials:**
- [Kubernetes Deployments: Get Started Fast (4 min)](https://www.youtube.com/watch?v=Sulw5ndbE88) - IBM Technology
- [Kubernetes Services Explained (13 min)](https://www.youtube.com/watch?v=T4Z7visMM4E) - TechWorld with Nana

## Hands-On Exercises

### Exercise 1: Deploy with Raw Manifests

**Objective:** Deploy the demo application to Kubernetes using kubectl and raw YAML manifests, then verify all resources are created and functioning correctly.

See [exercise-1-deploy-raw-manifests.md](exercise-1-deploy-raw-manifests.md) for complete instructions.

### Exercise 2: ConfigMap Changes

**Objective:** Modify ConfigMap values and observe how Kubernetes propagates changes to running pods, understanding the difference between environment variable and volume mount approaches.

See [exercise-2-configmap-changes.md](exercise-2-configmap-changes.md) for complete instructions.

### Exercise 3: Troubleshoot Pods

**Objective:** Diagnose and resolve common pod failure scenarios using kubectl diagnostic commands, logs analysis, and systematic troubleshooting approaches.

See [exercise-3-troubleshoot-pods.md](exercise-3-troubleshoot-pods.md) for complete instructions.

## Troubleshooting

### Pods Stuck in Pending State

**Symptoms:**
Pods show STATUS "Pending" for more than 30 seconds after creation.

**Diagnosis:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

Look for events at the bottom showing why scheduling failed. Common causes include insufficient CPU or memory resources in the cluster.

**Resolution:**

Check node resources:
```bash
kubectl top node
kubectl describe node minikube
```

If resources are insufficient, increase Minikube allocations:
```bash
minikube stop
minikube start --cpus=4 --memory=8192
```

### Pods in CrashLoopBackOff State

**Symptoms:**
Pods repeatedly restart with STATUS showing "CrashLoopBackOff" and increasing RESTARTS count.

**Diagnosis:**
```bash
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
```

The `--previous` flag shows logs from the last crashed container, which often contains the error that caused the crash.

**Resolution:**

Common causes and fixes:

1. Application error on startup - Check logs for stack traces or error messages
2. Missing environment variables - Verify ConfigMap or Secret exists and is referenced correctly
3. Incorrect container command - Check the `command` field in pod spec matches what the container expects
4. Health probe failures - Adjust `livenessProbe` and `readinessProbe` timing or thresholds

### Service Not Routing Traffic to Pods

**Symptoms:**
Attempting to reach the Service times out or returns connection errors.

**Diagnosis:**
```bash
kubectl get service <service-name> -n <namespace>
kubectl get endpoints <service-name> -n <namespace>
kubectl describe service <service-name> -n <namespace>
```

Check if the endpoints list is empty. If empty, the Service selector does not match any pod labels.

**Resolution:**

Verify Service selector matches pod labels:
```bash
# View Service selector
kubectl get service <service-name> -n <namespace> -o yaml | grep -A 5 selector

# View pod labels
kubectl get pods -n <namespace> --show-labels
```

Update either the Service selector or pod labels to match. If you update the Deployment's pod template labels, the Deployment will recreate pods with new labels.

### ConfigMap Changes Not Reflected in Pods

**Symptoms:**
You updated a ConfigMap but the application still uses old values.

**Diagnosis:**

Check if ConfigMap is mounted as environment variables or volume:
```bash
kubectl get pod <pod-name> -n <namespace> -o yaml | grep -A 10 envFrom
kubectl get pod <pod-name> -n <namespace> -o yaml | grep -A 10 volumeMounts
```

**Resolution:**

Environment variables are set at container start and require pod restart:
```bash
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

Volume-mounted ConfigMaps update automatically within 30-60 seconds, but the application must reload configuration. Check if your application supports configuration reloading or requires restart.

### ImagePullBackOff Errors

**Symptoms:**
Pods show STATUS "ImagePullBackOff" and do not reach Running state.

**Diagnosis:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

Events section shows "Failed to pull image" with specific error message.

**Resolution:**

Common causes:

1. Image name typo - Verify the image name and tag are correct
2. Image does not exist - Check the registry contains the specified image
3. Private registry without credentials - Create an imagePullSecret and reference it in the pod spec
4. Network connectivity issues - Verify Minikube can reach external registries

For this training using public images, typos in the image name are the most common cause. Double-check the image field in your manifest.

## Next Steps

After successfully deploying applications with raw Kubernetes manifests, you understand the foundational resources that all Kubernetes applications use. Phase 2 introduces containerization, where you will build Docker images for the demo application and understand how container images are constructed, layered, and optimized for production use.

Continue to [Phase 2: Containerization Basics](../phase-2-containerization/README.md).

## Additional Resources

**Official Documentation:**
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Debugging Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

**Video Tutorials:**
- [Kubernetes ConfigMaps and Secrets (12 min)](https://www.youtube.com/watch?v=FAnQTgr04mU) - TechWorld with Nana