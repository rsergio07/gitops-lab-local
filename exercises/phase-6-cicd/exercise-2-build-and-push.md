## Exercise 2: Build and Push the Image

**Objective:** Extend your workflow with a job that builds your Phase 2 Dockerfile and pushes the resulting image to GitHub Container Registry, tagged with the commit SHA.

## Background

Tagging images with the commit SHA — rather than a static tag like `latest` — is standard practice: it gives every build a unique, traceable identity that maps directly back to the exact code that produced it. This exercise adds that build-and-push step as its own job, so it can run in parallel with validation and only proceeds if validation succeeds.

## Steps

### 1. Commit your Dockerfile and app code

If you haven't already, commit the application and Dockerfile from Phase 2 to your repository, for example under `examples/simple-app/`.

### 2. Add permissions and a build job

Update `.github/workflows/ci.yml`, adding a `permissions` block and a second job that depends on `validate`:

```yaml
permissions:
  contents: read
  packages: write

jobs:
  validate:
    # ... unchanged from Exercise 1 ...

  build-and-push:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          context: examples/simple-app
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/demo-app:${{ github.sha }}
```

`needs: validate` ensures the image only builds if linting passes. `github.sha` gives each image a unique, traceable tag.

### 3. Commit and push

```bash
git add .github/workflows/ci.yml
git commit -m "Build and push image to GHCR"
git push origin <your-branch>
```

### 4. Verify the image was published

On GitHub, open your profile or repository's **Packages** tab. You should see `demo-app` with a version tag matching your latest commit SHA.

### 5. Pull the image locally to confirm

```bash
docker pull ghcr.io/<your-username>/demo-app:<commit-sha>
docker run -d -p 8080:8080 ghcr.io/<your-username>/demo-app:<commit-sha>
curl http://localhost:8080
```

### 6. Make the package public (optional)

By default, packages published with `GITHUB_TOKEN` are private to your account. If you want your ArgoCD-managed cluster to pull without registry credentials, go to the package settings on GitHub and change its visibility to public — reasonable for this training, not for production secrets or proprietary code.

## Verification

* The Actions run shows both `validate` and `build-and-push` jobs, with `build-and-push` starting only after `validate` succeeds.
* The Packages tab shows a new image version tagged with the triggering commit's SHA.
* Pulling and running that exact tag locally serves the expected response.

## Common Issues

### `docker/login-action` fails with permission denied

Confirm the `permissions:` block at the workflow level includes `packages: write`. Without it, `GITHUB_TOKEN` can't push to the registry even though login succeeds.

### Build succeeds but the tag looks wrong

`github.sha` is the full 40-character commit hash. If you want a shorter tag, use `${{ github.sha }}` sliced in a shell step, or reference `github.run_number` for a simpler incrementing tag — either is fine as long as it's unique per build.

### Pods later fail with ImagePullBackOff against this image

If the package is private, the cluster needs an `imagePullSecret` to authenticate. For this local training, making the package public avoids that extra setup.

## Next Steps

Your pipeline now produces a uniquely tagged, published image on every push. The next exercise teaches it to update your Helm chart automatically, so that new image gets deployed without you touching `values.yaml` by hand.

Continue to [Exercise 3: Automate the Helm Chart Update](exercise-3-update-helm-chart.md).
