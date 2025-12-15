## Exercise 3 – Local Registry

Running a local container registry allows you to store and distribute images without relying on remote services. In this exercise you will start a registry, tag your optimised image, push it to the registry and pull it back.

### Objectives

* Deploy a local Docker registry container.
* Tag your image with a registry address.
* Push the image to the registry and verify the upload.
* Remove local copies and pull the image back from the registry.

### Steps

1. **Start the registry.**

   Run the official Docker Registry image:

   ```bash
   docker run -d -p 5000:5000 --restart=always --name registry registry:2
   ```

   This command starts the registry on port 5000. Verify it is running with `docker ps`.

2. **Tag your image.**

   Tag your multi‑stage image so that it points to the local registry:

   ```bash
   docker tag simple-app:0.2.0 localhost:5000/simple-app:0.2.0
   ```

3. **Push the image.**

   Push the tagged image to the registry:

   ```bash
   docker push localhost:5000/simple-app:0.2.0
   ```

   You should see layers being uploaded. If you encounter authentication errors, ensure you are referencing `localhost` and not `docker.io`.

4. **Remove the local image.**

   To prove that the registry stores your image, remove the local copy:

   ```bash
   docker rmi localhost:5000/simple-app:0.2.0 simple-app:0.2.0
   ```

5. **Pull the image back.**

   Pull the image from the registry:

   ```bash
   docker pull localhost:5000/simple-app:0.2.0
   ```

   Run it again to confirm it works:

   ```bash
   docker run -d -p 8080:8080 --name simple-app-registry localhost:5000/simple-app:0.2.0
   curl http://localhost:8080
   ```

   Clean up with:

   ```bash
   docker rm -f simple-app-registry
   ```

### Verification

* A container named `registry` is running and listening on port 5000.
* The image `localhost:5000/simple-app:0.2.0` appears in `docker images` after pushing.
* Pulling the image after removing local copies retrieves it from the registry successfully.
* The pulled image runs and serves the application as expected.

### Common Issues

* **Port conflicts:** If port 5000 is already in use, choose another port (e.g. `-p 5001:5000`) and adjust the image tag accordingly.
* **Incorrect image name:** Make sure the tag exactly matches the registry address (`localhost:5000`) and repository name. Typos will cause the push to go to Docker Hub by default.
* **Registry not running:** If `docker push` fails to connect, verify the registry container is running and the port is mapped correctly. Use `docker logs registry` to check for errors.

### Next Steps

You have successfully stored and retrieved your optimised image using a local container registry. This ensures you can distribute images without relying on remote services. In the next exercise you will integrate your custom image into Kubernetes, create a Deployment and Service, and test application connectivity within the cluster.

Continue to **[Exercise 4 – Kubernetes Integration](exercise-4-kubernetes-integration.md)**.