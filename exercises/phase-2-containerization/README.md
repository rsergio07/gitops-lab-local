# Phase 2: Containerization Basics

Build, optimise and manage container images using Docker and prepare them for deployment into Kubernetes clusters. This phase teaches you how to create efficient images, use a local registry and run your images in Minikube. Mastering containerisation forms the bridge between raw Kubernetes manifests and higher‑level package managers like Helm.

## Table of Contents

- [Introduction](#introduction)
- [Learning Objectives](#learning-objectives)
- [Prerequisites](#prerequisites)
- [Theoretical Foundation](#theoretical-foundation)
  - [Containers vs Virtual Machines](#containers-vs-virtual-machines)
  - [Docker Architecture](#docker-architecture)
  - [Dockerfile Best Practices](#dockerfile-best-practices)
  - [Multi‑Stage Builds](#multi-stage-builds)
  - [Container Registries](#container-registries)
  - [Security Considerations](#security-considerations)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Container Basics](exercise-1-container-basics.md)
  - [Exercise 2: Dockerfile Best Practices](exercise-2-dockerfile-best-practices.md)
  - [Exercise 3: Local Registry](exercise-3-local-registry.md)
  - [Exercise 4: Kubernetes Integration](exercise-4-kubernetes-integration.md)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

## Introduction

Containers encapsulate an application and its runtime dependencies into a single, portable image. By running the same image in development, testing and production, you eliminate the “works on my machine” problem and ensure consistency across environments. This phase focuses on **building Docker images**, **optimising them**, **pushing to a registry** and **deploying them into Kubernetes**. You will learn how images are layered, how to write efficient Dockerfiles, how registries store and distribute images and how to run your custom image inside a cluster.

## Learning Objectives

By completing this phase, you will be able to:

1. **Explain containers vs virtual machines** and why containers are preferred for microservices.
2. **Describe Docker’s architecture** (daemon, CLI, image format) and how it manages containers.
3. **Author efficient Dockerfiles** using slim base images, ordering instructions for optimal caching and multi‑stage builds.
4. **Build, tag and run container images** locally and troubleshoot build/run failures.
5. **Operate a container registry**, tag images with repository addresses and push/pull images.
6. **Deploy your custom image to Kubernetes**, creating a Deployment and Service, and verify that pods can pull from the registry.

## Prerequisites

Before starting this phase, ensure you have:

1. **Completed Phase 0 and Phase 1** – your environment is validated and you are comfortable deploying raw manifests in Minikube.
2. **Colima & Minikube running** – confirm Docker commands work and `kubectl` is configured for the `minikube` context.
3. **Adequate resources** – at least 8 GB RAM, 4 CPU cores and 50 GB free disk space for building images and running clusters concurrently.
4. **Basic YAML & CLI familiarity** – know how to edit YAML manifests and run shell commands.

## Theoretical Foundation

### Containers vs Virtual Machines

Virtual machines emulate hardware and run a full guest operating system with its own kernel. Containers, by contrast, share the host kernel and isolate processes using namespaces and cgroups. This makes containers lightweight (megabytes instead of gigabytes) and fast to start (seconds instead of minutes). Because they share the kernel, containers are ideal for microservices that need to scale quickly and run on dense hosts.

### Docker Architecture

Docker consists of the **Docker Engine** (a daemon called `dockerd`), the **Docker CLI** (`docker`), and an **image format** built from read‑only layers. The daemon exposes a REST API that the CLI calls to build, run, tag and push images. Each line in a Dockerfile creates a new layer; layers are cached and shared between images to save time and disk space. Understanding this layering helps you write efficient Dockerfiles and debug caching issues.

### Dockerfile Best Practices

Your Dockerfile defines how to build the image. Follow these guidelines to keep images small, secure and maintainable:

* **Use minimal base images** such as `alpine` or `python:3.11-slim`. Avoid full OS images unless necessary.
* **Order instructions from least to most frequently changing.** Install system packages and dependencies early; copy application code later to maximise cache hits.
* **Leverage `.dockerignore`** to exclude files like `.git`, test data and build artifacts from the build context.
* **Combine related commands** using `&&` to reduce the number of layers, but avoid overly long commands that hinder readability.
* **Use multi‑stage builds** to separate build tools from runtime (see next section).
* **Run as a non‑root user** wherever possible to improve security.

### Multi‑Stage Builds

Multi‑stage builds let you use one image for compilation and another for runtime. In the first stage, you compile or package the application and install build tools. In the final stage, you copy only the built artifacts into a slim base image. This results in a much smaller runtime image. For example, when building a Go binary, use `golang` as the builder stage and `alpine` or `distroless` for the runtime stage.

### Container Registries

Registries store and distribute images. Public registries like Docker Hub host official images; private registries allow organisations to control access. You will run a local registry (`registry:2` image) to push and pull your images offline. Tag images with the registry address (`localhost:5000/myimage:tag`) before pushing. Kubernetes pulls images at pod creation time; if the registry is not reachable or authentication is missing, pods will enter `ImagePullBackOff`.

### Security Considerations

Containers are not inherently secure. Follow these practices to reduce risk:

* **Keep images up to date** – rebuild regularly to include base image security patches.
* **Scan images** with tools like Trivy or `docker scan` to identify vulnerabilities.
* **Use minimal runtime images** (`alpine`, `distroless`) to reduce the attack surface.
* **Store secrets outside images**, using Kubernetes Secrets or external managers instead of environment variables.
* **Run containers as non‑root** and set appropriate file permissions.

## Hands‑On Exercises

### Exercise 1: Container Basics

**Objective:** Build and run a simple Python web application inside a container to understand the fundamentals of containerization.

See [exercise-1-container-basics.md](exercise-1-container-basics.md) for complete instructions.

### Exercise 2: Dockerfile Best Practices

**Objective:** Optimize your container image by applying Dockerfile best practices, including the use of `.dockerignore` and multi‑stage builds.

See [exercise-2-dockerfile-best-practices.md](exercise-2-dockerfile-best-practices.md) for complete instructions.

### Exercise 3: Local Registry

**Objective:** Set up a local container registry, tag and push your image to it, then pull the image back to validate the workflow.

See [exercise-3-local-registry.md](exercise-3-local-registry.md) for complete instructions.

### Exercise 4: Kubernetes Integration

**Objective:** Deploy your custom image to Kubernetes and expose it via a Service, integrating container workflows with cluster orchestration.

See [exercise-4-kubernetes-integration.md](exercise-4-kubernetes-integration.md) for complete instructions.

## Troubleshooting

When working with containers and registries, you may encounter these common issues:

### Build failures

If `docker build` fails, read the error messages carefully. Verify that file paths are correct, base images exist and dependencies install successfully. Use `--progress=plain` for more verbose output. Check your `.dockerignore` to ensure required files are not excluded.

### Large images

If your images are unexpectedly large, ensure you are using slim base images and multi‑stage builds. Remove unnecessary files from the build context via `.dockerignore` and avoid installing build tools in the final stage.

### Registry connectivity

If `docker push` or `pull` fails to connect, verify that the registry container is running (`docker ps`) and listening on the correct port. Confirm your image tags reference the correct host and port (e.g. `localhost:5000`). For remote registries, ensure network connectivity and authentication credentials are configured.

### Kubernetes image pull errors

Pods stuck in `ImagePullBackOff` usually indicate that the cluster cannot reach the registry or the image tag is incorrect. When using Minikube’s Docker daemon, run `eval $(minikube docker-env)` before building and pushing images so that the images are stored in the same environment Minikube uses.

### Application does not respond

If your container starts but the application is unreachable, verify that the container is listening on the expected port and that you mapped it correctly (`-p` flag). Use `docker logs` to check for runtime errors. When running in Kubernetes, ensure the Service selector matches the pod labels.

## Next Steps

After mastering container basics and deploying your own image to Kubernetes, you’re ready to package your Kubernetes manifests into reusable charts. In **Phase 3 – Helm chart creation** you will convert the raw manifests from this phase into Helm charts, learn about templating and parameterisation, and publish your charts for others to use.

Continue to [Phase 3 – Helm chart creation](../phase-3-helm/README.md).

## Additional Resources

**Official Documentation:**
- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Kubernetes: Working with Images](https://kubernetes.io/docs/concepts/containers/images/)
- [OCI Registry](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)

**Video Tutorials**
- [Docker Crash Course for Absolute Beginners (60 min)](https://www.youtube.com/watch?v=pg19Z8LL06w) - TechWorld with Nana