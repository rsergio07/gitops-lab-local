# Phase 3: Helm Chart Creation – Solutions

This directory contains **reference implementations and helper scripts** for Phase 3 of the training. These solutions demonstrate one possible way to complete each exercise and are intended to support learning, validation, and troubleshooting.

The scripts provided here automate common tasks performed during the Helm exercises, such as chart initialization, templating updates, packaging, repository setup, and release management.

## Purpose of This Directory

The files in this directory are designed to:

* Serve as **reference solutions** after you attempt each exercise on your own
* Help validate your understanding of Helm chart structure and workflows
* Provide **repeatable automation** for testing and cleanup
* Reduce time spent on manual setup during experimentation

You are strongly encouraged to **attempt each exercise first** using the instructions in the `exercises/phase-3-helm` directory before reviewing or running these scripts.

## Contents

This directory includes the following files:

* `cleanup.sh`
  Cleans up Helm releases, namespaces, and any local artifacts created during the exercises.

* `exercise-1-init-chart.sh`
  Automates creation of a Helm chart skeleton and basic metadata updates.

* `exercise-2-templating.sh`
  Applies example templating changes to Deployment and Service templates using values from `values.yaml`.

* `exercise-3-package-and-repo.sh`
  Packages the Helm chart, creates or updates a local chart repository, and serves it locally.

* `exercise-4-release-management.sh`
  Demonstrates Helm release lifecycle operations including install, upgrade, rollback, and uninstall.

## Usage Guidelines

All scripts are written for **macOS** and assume:

* Helm is installed and available in your `PATH`
* A local Kubernetes cluster (Minikube) is running
* You are executing scripts from the repository root or the `solutions/phase-3-helm` directory

Before running any script, make it executable:

```bash
chmod +x *.sh
```

Then execute the desired script:

```bash
./exercise-1-init-chart.sh
```

Scripts are designed to be **idempotent** where possible, but running cleanup between exercises is recommended to avoid conflicts.

## Cleanup

To remove all Helm releases, namespaces, and temporary files created during Phase 3 exercises, run:

```bash
./cleanup.sh
```

This ensures a clean environment before repeating exercises or moving on to subsequent phases.

## Next Steps

Once you are comfortable with the Helm solutions provided here, proceed back to the exercise documentation to reinforce the concepts manually.

When ready, continue to the next phase where Helm will be integrated into **GitOps workflows** and automated deployment pipelines.

Return to [Phase 3: Helm Chart Creation](../../exercises/phase-3-helm/README.md) to continue learning.