#!/bin/bash

###############################################################################
# GitOps Lab - Full Environment Bootstrap (Fast Path)
#
# Provisions the final state of the lab in one step, for exploration only:
#   - Terraform-managed namespace, resource quota, and RBAC (Phase 5)
#   - The demo application, packaged as a Helm chart (Phase 3)
#   - ArgoCD, installed standalone (Phase 4)
#   - Prometheus and Grafana, scraping the demo app (Phase 7)
#
# This is NOT a substitute for the exercises. It skips the manual work that
# teaches the concepts. See README.md for the full learning path.
#
# Known limitations, by design:
#   - ArgoCD is installed but not wired to a live Git sync. A real GitOps
#     Application needs your own fork to sync from - that's the point of
#     Phase 4 (exercises/phase-4-gitops/).
#   - GitHub Actions (Phase 6) runs on GitHub-hosted runners and cannot be
#     reproduced locally. This script skips it entirely.
#
# Requirements: completed PREREQUISITES.md (Colima, Minikube, kubectl, Helm,
# Terraform all installed and the minikube context active).
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/.bootstrap"
CHART_DIR="$BOOTSTRAP_DIR/demo-app"
TF_DIR="$BOOTSTRAP_DIR/terraform"
SERVICEMONITOR_FILE="$BOOTSTRAP_DIR/servicemonitor.yaml"

INFRA_NAMESPACE="tf-demo"
APP_NAMESPACE="gitops-demo"
ARGOCD_NAMESPACE="argocd"
MONITORING_NAMESPACE="monitoring"
PROMETHEUS_RELEASE="kube-prometheus"

# Check tools and cluster connectivity
check_prerequisites() {
    log_info "Checking prerequisites..."

    for tool in kubectl helm terraform; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed. Run ./scripts/setup-macos.sh first."
            exit 1
        fi
    done

    if ! kubectl cluster-info &> /dev/null; then
        log_error "kubectl cannot reach a cluster. Is Minikube running?"
        exit 1
    fi
    log_success "kubectl, helm, and terraform are available and the cluster is reachable"

    allocatable_cpu=$(kubectl get node minikube -o jsonpath='{.status.allocatable.cpu}' 2>/dev/null || echo "?")
    allocatable_mem=$(kubectl get node minikube -o jsonpath='{.status.allocatable.memory}' 2>/dev/null || echo "?")
    log_info "Node allocatable: ${allocatable_cpu} CPU, ${allocatable_mem} memory"
    log_warning "This bootstraps the heaviest combined state in the course (ArgoCD + Terraform + Helm + monitoring stack)."
    log_warning "If pods stay Pending, restart Minikube with more resources: minikube start --cpus=4 --memory=8192"
}

# Phase 5 equivalent: namespace, resource quota, and RBAC as Terraform
provision_infrastructure() {
    log_info "Provisioning infrastructure with Terraform..."
    mkdir -p "$TF_DIR"

    cat <<EOF > "$TF_DIR/main.tf"
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
    name = "$INFRA_NAMESPACE"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_resource_quota" "tf_demo" {
  metadata {
    name      = "tf-demo-quota"
    namespace = kubernetes_namespace.tf_demo.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "2Gi"
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

    (cd "$TF_DIR" && terraform init -input=false && terraform apply -auto-approve)
    log_success "Terraform infrastructure provisioned ($INFRA_NAMESPACE namespace, quota, RBAC)"
}

# Phase 3 + Phase 7 equivalent: a minimal chart wrapping kubernetes/manifests,
# with the metrics-exporter sidecar from Phase 7 added directly
build_demo_chart() {
    log_info "Generating demo-app Helm chart..."
    mkdir -p "$CHART_DIR/templates"

    cat <<EOF > "$CHART_DIR/Chart.yaml"
apiVersion: v2
name: demo-app
description: GitOps Lab demo application (bootstrap fast path)
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

    cat <<EOF > "$CHART_DIR/values.yaml"
replicaCount: 2

image:
  repository: nginx
  tag: alpine
  pullPolicy: IfNotPresent

service:
  port: 8080
  targetPort: 80

metrics:
  enabled: true
  port: 9113

config:
  APP_ENV: "development"
  APP_NAME: "GitOps Demo Application"
  LOG_LEVEL: "info"
  LOG_FORMAT: "json"
  PORT: "8080"
  WORKERS: "2"
EOF

    cat <<'EOF' > "$CHART_DIR/templates/configmap.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-app-config
  labels:
    app: demo-app
data:
{{- range $key, $value := .Values.config }}
  {{ $key }}: {{ $value | quote }}
{{- end }}
EOF

    # Overrides nginx's own default.conf so both "/" and "/stub_status" are
    # served from the same server block - two separate server{} blocks on
    # the same listen port would leave stub_status unreachable.
    cat <<'EOF' > "$CHART_DIR/templates/nginx-conf-configmap.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-default-conf
  labels:
    app: demo-app
data:
  default.conf: |
    server {
      listen 80;
      server_name _;

      location /stub_status {
        stub_status on;
        allow 127.0.0.1;
        deny all;
      }

      location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
      }
    }
EOF

    cat <<'EOF' > "$CHART_DIR/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  labels:
    app: demo-app
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: demo-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
        - name: demo-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          envFrom:
            - configMapRef:
                name: demo-app-config
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
          volumeMounts:
            - name: nginx-default-conf
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
        {{- if .Values.metrics.enabled }}
        - name: metrics-exporter
          image: nginx/nginx-prometheus-exporter:1.1.0
          args:
            - "--nginx.scrape-uri=http://localhost:80/stub_status"
          ports:
            - name: metrics
              containerPort: {{ .Values.metrics.port }}
        {{- end }}
      volumes:
        - name: nginx-default-conf
          configMap:
            name: nginx-default-conf
EOF

    cat <<'EOF' > "$CHART_DIR/templates/service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: demo-app
  labels:
    app: demo-app
spec:
  type: ClusterIP
  selector:
    app: demo-app
  ports:
    - name: http
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
    {{- if .Values.metrics.enabled }}
    - name: metrics
      port: {{ .Values.metrics.port }}
      targetPort: {{ .Values.metrics.port }}
    {{- end }}
EOF

    helm lint "$CHART_DIR"
    log_success "Chart generated at ${CHART_DIR#$REPO_ROOT/}"
}

# Phase 4 equivalent, minus the live GitOps sync (see header note)
deploy_demo_app() {
    log_info "Deploying demo-app..."
    helm upgrade --install demo-app "$CHART_DIR" \
        --namespace "$APP_NAMESPACE" \
        --create-namespace \
        --wait --timeout 120s
    log_success "demo-app deployed to $APP_NAMESPACE"
}

install_argocd() {
    log_info "Installing ArgoCD..."
    kubectl create namespace "$ARGOCD_NAMESPACE" 2>/dev/null || true
    kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n "$ARGOCD_NAMESPACE"
    log_success "ArgoCD installed (standalone - see header note on GitOps sync)"
}

# Phase 7 equivalent: monitoring stack + ServiceMonitor for demo-app
install_observability() {
    log_info "Installing Prometheus and Grafana..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts &> /dev/null || true
    helm repo update &> /dev/null

    kubectl create namespace "$MONITORING_NAMESPACE" 2>/dev/null || true
    helm upgrade --install "$PROMETHEUS_RELEASE" prometheus-community/kube-prometheus-stack \
        --namespace "$MONITORING_NAMESPACE" \
        --set grafana.adminPassword=admin123 \
        --wait --timeout 300s

    mkdir -p "$BOOTSTRAP_DIR"
    cat <<EOF > "$SERVICEMONITOR_FILE"
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-app
  namespace: $MONITORING_NAMESPACE
  labels:
    release: $PROMETHEUS_RELEASE
spec:
  selector:
    matchLabels:
      app: demo-app
  namespaceSelector:
    matchNames:
      - $APP_NAMESPACE
  endpoints:
    - port: metrics
      interval: 15s
EOF
    kubectl apply -f "$SERVICEMONITOR_FILE"
    log_success "Monitoring stack installed and scraping demo-app"
}

print_summary() {
    ARGOCD_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "(already rotated)")

    echo ""
    echo "════════════════════════════════════════════════════════════════"
    log_success "Full environment is up 🚀"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Namespaces: $INFRA_NAMESPACE, $APP_NAMESPACE, $ARGOCD_NAMESPACE, $MONITORING_NAMESPACE"
    echo ""
    log_info "Demo app:"
    echo "  kubectl port-forward svc/demo-app -n $APP_NAMESPACE 8081:8080"
    echo "  curl http://localhost:8081"
    echo ""
    log_info "ArgoCD UI (admin / $ARGOCD_PASSWORD):"
    echo "  kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443"
    echo "  https://localhost:8080"
    echo ""
    log_info "Grafana (admin / admin123):"
    echo "  kubectl port-forward svc/${PROMETHEUS_RELEASE}-grafana -n $MONITORING_NAMESPACE 3000:80"
    echo "  http://localhost:3000"
    echo ""
    log_info "Prometheus:"
    echo "  kubectl port-forward svc/${PROMETHEUS_RELEASE}-kube-prome-prometheus -n $MONITORING_NAMESPACE 9090:9090"
    echo "  http://localhost:9090"
    echo ""
    log_warning "ArgoCD is not syncing from Git, and Phase 6's CI/CD pipeline was not run - see the script header for why."
    log_info "This is an exploration shortcut, not the learning path. Start from Phase 0 to learn how each piece works: exercises/phase-0-validation/"
    echo ""
    log_info "Tear down with: ./scripts/teardown-full-environment.sh"
    echo "════════════════════════════════════════════════════════════════"
}

main() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "     GitOps Lab - Full Environment Bootstrap (Fast Path)"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    check_prerequisites
    provision_infrastructure
    build_demo_chart
    deploy_demo_app
    install_argocd
    install_observability
    print_summary
}

main
