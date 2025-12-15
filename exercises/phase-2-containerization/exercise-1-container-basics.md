## Exercise 1 – Container Basics

This exercise introduces you to building and running a containerised application from scratch. You will create a simple Python HTTP server, package it in a Docker image and verify that it runs correctly on your local machine.

### Objectives

* Build a Docker image for a basic web service.
* Understand the structure of a Dockerfile.
* Run the container and test that it serves traffic.
* Clean up images and containers when finished.

### Steps

1. **Create the application.**

   In an empty directory (`examples/simple-app` in this repo is suggested), create a file named `main.py` with the following content:

   ```python
   from flask import Flask
   app = Flask(__name__)

   @app.route('/')
   def hello():
       return 'Hello from your container!\n'

   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=8080)
   ```

   Create a `requirements.txt` file containing:

   ```
   flask==3.0.0
   ```

2. **Write the Dockerfile.**

   Create a file named `Dockerfile` in the same directory with the following instructions:

   ```Dockerfile
   # Use an official Python runtime as a parent image
   FROM python:3.11-slim

   # Set working directory
   WORKDIR /app

   # Copy dependency list and install
   COPY requirements.txt ./
   RUN pip install --no-cache-dir -r requirements.txt

   # Copy source code
   COPY . .

   # Expose port
   EXPOSE 8080

   # Default command
   CMD ["python", "main.py"]
   ```

3. **Build the image.**

   From the directory containing your Dockerfile, build the image and tag it `simple-app:0.1.0`:

   ```bash
   docker build -t simple-app:0.1.0 .
   ```

   Use `docker images` to confirm that the image exists.

4. **Run the container.**

   Start the container and map port 8080 inside the container to port 8080 on your host:

   ```bash
   docker run -d -p 8080:8080 --name simple-app simple-app:0.1.0
   ```

   Verify that the container is running with `docker ps`.

5. **Test the application.**

   Use `curl` or your browser to call the endpoint:

   ```bash
   curl http://localhost:8080
   ```

   You should see `Hello from your container!` in the response. Check logs with `docker logs simple-app` to see request details.

6. **Clean up.**

   Stop and remove the running container when you are done:

   ```bash
   docker rm -f simple-app
   ```

   You can remove the image with `docker rmi simple-app:0.1.0` if you no longer need it.

### Verification

* The `docker build` command completes successfully and outputs an image ID.
* `docker run` starts a container that appears in `docker ps` with status `Up`.
* `curl http://localhost:8080` returns the expected greeting.

### Common Issues

* **Ports not exposed:** Ensure that the `EXPOSE 8080` directive is present and that you map the port correctly in `docker run`.
* **Dependency installation fails:** Check your internet connection and ensure `requirements.txt` has the correct package versions. Use `pip install` without the `--no-cache-dir` option if network caching issues occur.
* **Application errors:** View logs with `docker logs` to debug Python exceptions or import errors. Ensure the code matches the example exactly.

### Next Steps

You have built and run a simple application inside a container and are now comfortable with basic Docker operations, including writing a Dockerfile, building an image and running a container. In the next exercise you will learn how to optimise your Dockerfile, leverage multi‑stage builds and use a `.dockerignore` file to reduce image size.

Continue to **[Exercise 2 – Dockerfile Best Practices](exercise-2-dockerfile-best-practices.md)**.
