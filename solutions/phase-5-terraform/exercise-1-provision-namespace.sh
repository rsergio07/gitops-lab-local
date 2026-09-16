#!/bin/bash

set -e

WORKDIR="exercises/phase-5-terraform/terraform"

echo "[INFO] Setting up Terraform project at $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

cat <<EOF > main.tf
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

resource "kubernetes_namespace" "tf_demo" {
  metadata {
    name = "tf-demo"
    labels = {
      managed-by = "terraform"
    }
  }
}
EOF

echo "[INFO] Initializing"
terraform init

echo "[INFO] Planning"
terraform plan

echo "[INFO] Applying"
terraform apply -auto-approve

echo "[SUCCESS] Namespace created:"
kubectl get namespace tf-demo --show-labels

echo "[DONE] Exercise 1 completed"
