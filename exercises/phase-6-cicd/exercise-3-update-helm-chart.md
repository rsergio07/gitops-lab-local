## Exercise 3: Automate the Helm Chart Update

**Objective:** Add a job that updates your Helm chart's `values.yaml` with the newly built image tag and commits the change back to the repository.

## Background

This is the step that connects CI to GitOps. Your pipeline already builds and publishes a uniquely tagged image. Now it needs to record that tag in the one place ArgoCD is watching: your chart's `values.yaml` in Git. Once this job commits and pushes, the change looks identical — to ArgoCD and to Git history — to the manual edit you made in Phase 4's Exercise 4.

## Steps

### 1. Add a chart-update job

Extend `permissions` to allow writing to the repository, and add a third job that depends on `build-and-push`:

```yaml
permissions:
  contents: write
  packages: write

jobs:
  validate:
    # ... unchanged ...

  build-and-push:
    # ... unchanged ...

  update-chart:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref_name }}

      - name: Update image tag in values.yaml
        run: |
          sed -i "s/^  tag:.*/  tag: \"${{ github.sha }}\"/" exercises/phase-4-gitops/demo-app/values.yaml

      - name: Commit and push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add exercises/phase-4-gitops/demo-app/values.yaml
          git diff --cached --quiet && echo "No changes to commit" || git commit -m "ci: bump demo-app image to ${{ github.sha }}"
          git push
```

The `git diff --cached --quiet` check avoids a failing, empty commit when the tag hasn't actually changed.

### 2. Prevent an infinite trigger loop

Since this job pushes back to the same branch the workflow runs on, guard the trigger so the bot's own commits don't retrigger the whole pipeline:

```yaml
on:
  push:
    branches: ["**"]
    paths-ignore:
      - "exercises/phase-4-gitops/demo-app/values.yaml"
```

### 3. Commit and push your workflow changes

```bash
git add .github/workflows/ci.yml
git commit -m "Automate Helm chart image tag updates"
git push origin <your-branch>
```

### 4. Verify the automated commit

Watch the Actions tab for all three jobs to succeed, then check your repository's commit history:

```bash
git pull origin <your-branch>
git log --oneline -3
```

You should see a new commit authored by `github-actions[bot]` bumping the image tag.

### 5. Confirm the chart reflects it

```bash
cat exercises/phase-4-gitops/demo-app/values.yaml
```

The `tag` field should match the commit SHA from your original push, not the bot's own commit.

## Verification

* The `update-chart` job runs after `build-and-push` succeeds.
* A new commit from `github-actions[bot]` appears in your repository history.
* `values.yaml` contains the correct image tag.
* Pushing the bot's own commit does not retrigger the workflow (thanks to `paths-ignore`).

## Common Issues

### Push rejected (non-fast-forward)

If another commit landed on the branch between checkout and push, `git push` fails. Add a `git pull --rebase` before the push step, or accept the rare failure and re-run the workflow.

### Workflow retriggers itself in a loop

Double-check the `paths-ignore` pattern matches the exact file path you're modifying. A mismatched path silently fails to prevent the loop.

### `github-actions[bot]` commits are rejected by branch protection

If your fork has branch protection rules requiring reviews, the bot can't push directly. Relax protection on your working branch for this training, or route the update through a pull request instead.

## Next Steps

Your pipeline now builds, publishes, and records every change in Git automatically. The final exercise traces a single push through the entire system — CI, Git, and ArgoCD — to confirm the loop is fully closed.

Continue to [Exercise 4: End-to-End Deployment](exercise-4-end-to-end.md).
