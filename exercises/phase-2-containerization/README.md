## Phase 2 – Containerization Basics

Phase 2 introduces you to containers and teaches you how to build, run and manage container images.  Containers package an application and its dependencies into a single unit, making deployments predictable and portable across environments.  Mastering container fundamentals is essential before moving on to Helm charts, GitOps and continuous delivery.

### Learning Objectives

By completing this phase you will:

1. Understand the differences between containers and virtual machines and why containers are preferred for microservices.
2. Learn the architecture of Docker, including the engine, CLI and layered image format.
3. Write efficient Dockerfiles using slim base images, ordering instructions for optimal caching and multi‑stage builds.
4. Build, tag and run container images on your local machine and troubleshoot common issues.
5. Operate a local container registry, push and pull images and manage tags.
6. Update Kubernetes manifests to use your own images and verify that pods can pull them from a registry.

### Prerequisites

* Completion of Phase 0 (environment validation) and Phase 1 (Kubernetes review).  Your local Minikube cluster and Docker runtime should be running correctly.
* At least 8 GB of RAM, 4 CPU cores and 50 GB of free disk space.
* Basic familiarity with the command line and editing YAML files.

### Overview

This phase contains four hands‑on exercises:

* **Exercise 1 – Container Basics:** Build and run a simple Python web application inside a container.
* **Exercise 2 – Dockerfile Best Practices:** Optimise your image using multi‑stage builds and `.dockerignore` files.
* **Exercise 3 – Local Registry:** Start a local registry, tag your image and push/pull it.
* **Exercise 4 – Kubernetes Integration:** Deploy your custom image to Kubernetes and expose it via a Service.

Each exercise file provides detailed step‑by‑step instructions, verification criteria and troubleshooting tips.  The corresponding solution scripts in the `solutions/phase-2-containerization` directory automate common tasks and cleanup.

### Theoretical Background

Before you start, review the following concepts:

* **Containers vs VMs:** Containers share the host kernel via namespaces and cgroups, whereas VMs run a full guest OS with a separate kernel.  Containers are lightweight and start quickly, making them ideal for microservices.
* **Docker Architecture:** The Docker Engine runs as a daemon (`dockerd`) and exposes a REST API.  The Docker CLI sends commands to this API.  Images consist of read‑only layers stacked on top of each other; each line in a Dockerfile creates a new layer.
* **Dockerfile Best Practices:** Use minimal base images (`alpine`, `slim`), leverage multi‑stage builds to separate build dependencies from runtime, order instructions to maximise cache reuse, minimise the number of layers, use `.dockerignore` and run processes as non‑root.
* **Container Registries:** Registries store and distribute images.  Docker Hub is the default public registry, but you can run a private registry locally for development.

### Next Steps

After mastering container basics in this phase, you will proceed to **[Phase 3 – Helm chart creation](../phase-3-helm/README.md)** where you convert raw Kubernetes manifests into reusable, parameterised charts for easier deployment and configuration.