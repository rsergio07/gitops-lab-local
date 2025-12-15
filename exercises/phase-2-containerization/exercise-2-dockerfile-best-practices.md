## Exercise 2 – Dockerfile Best Practices

In this exercise you will refactor your Dockerfile to follow best practices and reduce the size of your image using multi‑stage builds. You will also configure a `.dockerignore` file to speed up builds by excluding unnecessary files.

### Objectives

* Understand how image layers affect build caching and size.
* Use a multi‑stage Dockerfile to separate build and runtime dependencies.
* Create a `.dockerignore` file to minimise the build context.
* Compare the sizes of single‑stage and multi‑stage images.

### Steps

1. **Review the current image.**

   From the previous exercise, note the size of the `simple-app:0.1.0` image using:

   ```bash
   docker images simple-app
   ```

2. **Add a `.dockerignore` file.**

   In your application directory, create a file named `.dockerignore` with the following entries:

   ```
   __pycache__/
   *.pyc
   .git
   node_modules
   *.log
   ```

   This file tells Docker to exclude bytecode caches, VCS metadata and other irrelevant files from the build context.

3. **Write a multi‑stage Dockerfile.**

   Create a file named `Dockerfile.multi` with two stages:

   ```Dockerfile
   # Stage 1: build dependencies
   FROM python:3.11-slim AS builder
   WORKDIR /build
   COPY requirements.txt ./
   RUN pip install --prefix=/install -r requirements.txt

   # Stage 2: runtime
   FROM python:3.11-alpine
   WORKDIR /app
   # Copy installed dependencies from builder stage
   COPY --from=builder /install /usr/local
   # Copy source code
   COPY . .
   EXPOSE 8080
   CMD ["python", "main.py"]
   ```

   The builder stage installs dependencies into `/install`, which is then copied into the final minimal Alpine image, reducing the final size.

4. **Build the multi‑stage image.**

   Run the following command from your app directory:

   ```bash
   docker build -f Dockerfile.multi -t simple-app:0.2.0 .
   ```

5. **Compare image sizes.**

   List both images and observe the size difference:

   ```bash
   docker images simple-app
   ```

   The multi‑stage image (`0.2.0`) should be significantly smaller than the single‑stage image (`0.1.0`).

6. **Test the multi‑stage image.**

   Run the new image and confirm that it still serves traffic:

   ```bash
   docker run -d -p 8080:8080 --name simple-app-multi simple-app:0.2.0
   curl http://localhost:8080
   ```

   Clean up the container afterwards with:

   ```bash
   docker rm -f simple-app-multi
   ```

### Verification

* A `.dockerignore` file exists and excludes unnecessary files.
* The `docker build` command using `Dockerfile.multi` completes successfully.
* The multi‑stage image size is smaller than the original single‑stage image.
* Running the multi‑stage image produces the expected response from the application.

### Common Issues

* **Cache not used:** Changing the order of instructions or copying many files early can invalidate the build cache. Place commands that change infrequently (like installing dependencies) before copying source code.
* **Alpine package issues:** The `python:alpine` images are based on musl libc and may behave slightly differently. If you encounter compatibility issues, stick with slim Debian images for runtime.
* **Missing dependencies:** Ensure that all runtime dependencies are installed in the builder stage and copied into the final stage. If the app cannot import a module, check your multi‑stage installation paths.

### Next Steps

You have optimised your Dockerfile by introducing a `.dockerignore` file and multi‑stage builds, resulting in a smaller and more efficient image. In the next exercise you’ll learn how to store and distribute that image using a local container registry.

Continue to **[Exercise 3 – Local Registry](exercise-3-local-registry.md)**.