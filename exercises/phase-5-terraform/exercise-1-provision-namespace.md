## Exercise 1: Provision a Namespace

**Objective:** Set up a Terraform project targeting your Minikube cluster and manage a namespace through the full plan-apply workflow.

### Steps

1. **Create a working directory.**

   ```bash
   mkdir -p exercises/phase-5-terraform/terraform
   cd exercises/phase-5-terraform/terraform
   ```

2. **Define the provider.**

   Create `main.tf`:

   ```hcl
   terraform {
     required_providers {
       kubernetes = {
         source  = "hashicorp/kubernetes"
         version = "~> 2.30"
       }
     }
   }

   provider "kubernetes" {
     config_path    = "~/.kube/config"
     config_context = "minikube"
   }
   ```

3. **Initialize the project.**

   ```bash
   terraform init
   ```

   This downloads the Kubernetes provider plugin into a local `.terraform/` directory.

4. **Define a namespace resource.**

   Add to `main.tf`:

   ```hcl
   resource "kubernetes_namespace" "tf_demo" {
     metadata {
       name = "tf-demo"
       labels = {
         managed-by = "terraform"
       }
     }
   }
   ```

5. **Preview the change.**

   ```bash
   terraform plan
   ```

   Terraform shows a plan with one resource to add (`+`). Nothing has been created yet.

6. **Apply the change.**

   ```bash
   terraform apply
   ```

   Type `yes` when prompted, or pass `-auto-approve` to skip confirmation.

7. **Verify with kubectl.**

   ```bash
   kubectl get namespace tf-demo --show-labels
   ```

8. **Run plan again.**

   ```bash
   terraform plan
   ```

   With nothing changed, Terraform reports no differences — the cluster already matches your configuration.

### Verification

* `terraform init` completes without errors.
* `terraform plan` clearly shows the namespace as a pending addition before you apply.
* `terraform apply` creates the namespace, visible with `kubectl get namespace tf-demo`.
* A second `terraform plan` reports no changes.

### Common Issues

* **Provider fails to connect:** Verify `kubectl cluster-info` works first. If you use a kubeconfig path other than `~/.kube/config`, update `config_path` accordingly.
* **`terraform init` fails to download the provider:** Check network connectivity and retry; this is a one-time download cached in `.terraform/`.
* **Plan shows changes every time:** Confirm you're not also managing this namespace with a separate manifest or Helm release — two tools managing the same object will fight over it.

### Next Steps

You've provisioned your first piece of infrastructure as code. In the next exercise you'll add a resource quota and RBAC resources to this namespace, using Terraform variables to keep the configuration reusable.

Continue to [Exercise 2: Quotas and RBAC as Code](exercise-2-quotas-and-rbac.md).
