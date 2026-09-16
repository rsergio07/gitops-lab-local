# Phase 6 Solutions

Reference solutions for Phase 6 exercises. Use these to verify your work or understand correct approaches when stuck.

## Using Solutions Responsibly

Attempt each exercise independently before consulting solutions. The learning happens through problem-solving and troubleshooting, not just reading correct answers. Solutions are provided to:

1. Verify your approach matches expected patterns
2. Understand alternative methods when stuck
3. Compare your implementation with best practices
4. Learn from detailed explanations in comments

## Solution Files

Unlike earlier phases, Phase 6's solutions run on GitHub's infrastructure, not your local machine. Each `.sh` script here **generates the workflow YAML** into `.github/workflows/ci.yml` and prints the `git` commands to commit and push it — pushing itself is left to you, since it requires your own GitHub credentials and triggers a real remote build.

### Exercise 1: A Basic Validation Workflow

`exercise-1-basic-workflow.sh` writes a `validate` job that lints the Helm chart and checks manifest YAML syntax.

### Exercise 2: Build and Push the Image

`exercise-2-build-and-push.sh` appends a `build-and-push` job using `docker/build-push-action` targeting GHCR, tagged with `github.sha`.

### Exercise 3: Automate the Helm Chart Update

`exercise-3-update-helm-chart.sh` appends an `update-chart` job that patches `values.yaml` and commits as `github-actions[bot]`, plus the `paths-ignore` guard against retriggering.

### Exercise 4: End-to-End Deployment

There's no script for Exercise 4 — it's a verification exercise exercising the pipeline built in Exercises 1–3, plus ArgoCD from Phase 4. See the exercise file for the verification commands to run at each stage.

## Common Patterns

**Progressive workflow construction:**

Each exercise appends a new job to the same `ci.yml`, chained with `needs:`, so the file always represents the complete pipeline up to that point rather than several disconnected files.

**Verifying a workflow without waiting on GitHub:**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
```

Catches YAML syntax errors before you push and wait for a run.

## Notes

These solutions represent one correct approach. Valid alternatives may exist — for example, using a marketplace action for the Helm values bump instead of `sed`. The important outcomes are:

- Every push triggers validation before anything builds or deploys
- Images are tagged uniquely and traceably
- The chart update commit is indistinguishable, from ArgoCD's perspective, from a manual one
- You understand why each step is necessary
