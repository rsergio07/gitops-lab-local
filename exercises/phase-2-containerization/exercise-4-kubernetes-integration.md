## Exercise 4 – Kubernetes Integration

In this exercise you will deploy your custom container image to your local Kubernetes cluster using Minikube. You will create a namespace, define a Deployment and Service, apply them and verify that the pods can pull the image from your registry.

### Objectives

* Create a Kubernetes namespace dedicated to the container demo.
* Define a Deployment that references your local registry image.
* Expose the Deployment via a ClusterIP Service.
* Test the application inside the cluster and clean up afterwards.

### Steps

1. **Ensure Minikube is using the correct Docker daemon.**

   When using a local registry, you need to ensure that the registry is reachable from within the Minikube VM. Easiest is to run the registry inside Minikube’s Docker environment. Evaluate the Minikube Docker environment and restart your registry if necessary:

   ```bash
   # Configure shell to use Minikube's Docker daemon
   eval $(minikube docker-env)

   # (Re)start the registry inside Minikube's Docker context if not already running
   docker ps | grep registry || docker run -d -p 5000:5000 --restart=always --name registry registry:2
   ```

   After this step, rebuild and push your image using the steps from Exercise 3 so that it is available to Minikube.

2. **Create a namespace.**

   Use kubectl to create a namespace for this exercise:

   ```bash
   kubectl create namespace container-demo
   ```

3. **Write the manifest.**

   Create a file named `deployment.yaml` with the following content, replacing the image tag if necessary:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: simple-app
     namespace: container-demo
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: simple-app
     template:
       metadata:
         labels:
           app: simple-app
       spec:
         containers:
           - name: simple-app
             image: localhost:5000/simple-app:0.2.0
             ports:
               - containerPort: 8080
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: simple-app
     namespace: container-demo
   spec:
     selector:
       app: simple-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 8080
     type: ClusterIP
   ```

4. **Apply the manifest.**

   Deploy the resources:

   ```bash
   kubectl apply -f deployment.yaml
   ```

   Watch the rollout with:

   ```bash
   kubectl get pods -n container-demo -w
   ```

   until both pods show `STATUS: Running` and `READY: 1/1`.

5. **Test connectivity.**

   Launch a temporary curl pod to call the service within the cluster:

   ```bash
   kubectl run curl --rm -it -n container-demo --image=curlimages/curl --restart=Never --command -- curl http://simple-app
   ```

   You should see the same greeting message. If the call fails, describe the pods and events:

   ```bash
   kubectl describe pod -l app=simple-app -n container-demo
   kubectl logs -l app=simple-app -n container-demo
   ```

6. **Clean up.**

   Remove the resources and namespace once you have verified connectivity:

   ```bash
   kubectl delete namespace container-demo
   ```

### Verification

* The deployment and service are created successfully and appear in `kubectl get` outputs.
* Pods pull the image from the local registry without entering `ImagePullBackOff`.
* `curl` within the cluster returns the expected greeting.

### Common Issues

* **Image pull errors:** If pods cannot pull the image, verify that the registry is running within Minikube’s Docker context and that the image tag exists. Running `eval $(minikube docker-env)` before building and pushing ensures images are stored in the correct daemon.
* **Service unreachable:** Ensure the Service selector matches the pod labels and that you are using the Service name (`http://simple-app`) from within the namespace.
* **Namespace mismatch:** Confirm that the Deployment, Service and test pod all reside in the `container-demo` namespace.

### Next Steps

You have successfully deployed your custom image to Kubernetes, exposed it via a Service, and verified connectivity from within the cluster. This exercise completes the containerisation phase by combining image creation, registry usage and Kubernetes deployment. With this foundation, you are now ready to package your Kubernetes resources using Helm.

Continue to **[Phase 3 – Helm chart creation](../phase-3-helm/README.md)**.