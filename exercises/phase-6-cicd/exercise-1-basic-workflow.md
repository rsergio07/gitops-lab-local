## Exercise 1: A Basic Validation Workflow

**Objective:** Create your first GitHub Actions workflow: one that lints your Helm chart and validates YAML syntax on every push.

### Steps

1. **Create the workflows directory.**

   ```bash
   mkdir -p .github/workflows
   ```

2. **Write a minimal workflow.**

   Create `.github/workflows/ci.yml`:

   ```yaml
   name: CI

   on:
     push:
       branches: ["**"]
     pull_request:
       branches: [main]

   jobs:
     validate:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout code
           uses: actions/checkout@v4

         - name: Set up Helm
           uses: azure/setup-helm@v4
           with:
             version: "v3.14.0"

         - name: Lint Helm chart
           run: helm lint exercises/phase-4-gitops/demo-app

         - name: Validate Kubernetes manifests
           run: |
             for f in kubernetes/manifests/*.yaml; do
               echo "Validating $f"
               python3 -c "import yaml, sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$f"
             done
   ```

   This workflow has one job, `validate`, with four steps: checking out your code, installing Helm on the runner, linting your chart, and confirming every manifest is syntactically valid YAML.

3. **Commit and push.**

   ```bash
   git add .github/workflows/ci.yml
   git commit -m "Add basic CI validation workflow"
   git push origin <your-branch>
   ```

4. **Watch it run.**

   On GitHub, open your fork's **Actions** tab. You should see a new workflow run triggered by your push. Click into it to watch each step execute.

5. **Break it on purpose.**

   Introduce a deliberate error — for example, remove a required field from your chart's `Chart.yaml` — commit, and push. Confirm the workflow run fails and that the failing step is clearly identified in the logs.

6. **Fix it and confirm green.**

   Revert your change, commit, and push again. The workflow should pass.

### Verification

* `.github/workflows/ci.yml` exists and is triggered by a push.
* The Actions tab shows a successful run for a valid commit.
* A deliberately broken chart or manifest causes the workflow to fail, with the failing step visible in the logs.

### Common Issues

* **Workflow doesn't appear in the Actions tab:** Confirm Actions are enabled for your fork (GitHub disables them by default on some forks) and that the YAML file's path and extension are exactly `.github/workflows/ci.yml`.
* **YAML syntax errors in the workflow itself:** GitHub shows a parsing error at the top of the run instead of executing any steps. Validate the file locally with `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` before pushing.
* **Helm lint fails on the runner but not locally:** Confirm the chart path in the `helm lint` step matches where you actually committed your chart in Phase 4.

### Next Steps

You have a working CI pipeline that validates every change. In the next exercise, you'll extend it to build your Phase 2 Docker image and publish it to a registry.

Continue to [Exercise 2: Build and Push the Image](exercise-2-build-and-push.md).
