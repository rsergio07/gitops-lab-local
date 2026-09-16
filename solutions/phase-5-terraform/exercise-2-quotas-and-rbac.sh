#!/bin/bash

set -e

WORKDIR="exercises/phase-5-terraform/terraform"
cd "$WORKDIR"

echo "[INFO] Writing variables.tf"
cat <<EOF > variables.tf
variable "namespace" {
  description = "Namespace to apply quota and RBAC to"
  type        = string
  default     = "tf-demo"
}

variable "max_cpu" {
  description = "CPU limit for the namespace"
  type        = string
  default     = "2"
}

variable "max_memory" {
  description = "Memory limit for the namespace"
  type        = string
  default     = "2Gi"
}
EOF

echo "[INFO] Appending quota and RBAC resources to main.tf"
cat <<'EOF' >> main.tf

resource "kubernetes_resource_quota" "tf_demo" {
  metadata {
    name      = "tf-demo-quota"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.max_cpu
      "requests.memory" = var.max_memory
      "pods"            = "10"
    }
  }
}

resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "pod_reader_binding" {
  metadata {
    name      = "pod-reader-binding"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
}
EOF

echo "[INFO] Planning"
terraform plan

echo "[INFO] Applying"
terraform apply -auto-approve

echo "[SUCCESS] Quota and RBAC created:"
kubectl get resourcequota -n tf-demo
kubectl get role,rolebinding -n tf-demo

echo "[DONE] Exercise 2 completed"
