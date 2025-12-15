## Phase 2 Solutions

This directory contains helper scripts and guidance for completing the exercises in **Phase 2 – Containerization Basics**. These scripts automate common tasks such as building images, pushing to a local registry, deploying to Kubernetes and cleaning up resources. You can run them directly or examine them for inspiration while performing the exercises manually.

### Contents

| Script                      | Purpose                                               |
| --------------------------- | ----------------------------------------------------- |
| `cleanup.sh`                | Stop and remove containers, images and registries.    |
| `exercise-1-build-image.sh` | Build and run the simple application container.       |
| `exercise-2-multi-stage.sh` | Build the multi‑stage image and compare sizes.        |
| `exercise-3-registry.sh`    | Start a local registry, tag, push and pull the image. |
| `exercise-4-kubernetes.sh`  | Deploy the image to Kubernetes and test connectivity. |

Use `chmod +x <script>` to make a script executable before running it. You may need to adjust file paths relative to your working directory.