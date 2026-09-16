#!/bin/bash

###############################################################################
# GitOps Lab - Full Environment Teardown (Fast Path)
#
# Removes everything created by scripts/bootstrap-full-environment.sh:
# the monitoring stack, ArgoCD, the demo-app Helm release, and the
# Terraform-managed infrastructure.
#
# This does NOT touch anything created by the manual exercises (e.g. the
# demo-app, helm-demo, or container-demo namespaces from Phases 1-3).
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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/.bootstrap"
TF_DIR="$BOOTSTRAP_DIR/terraform"

INFRA_NAMESPACE="tf-demo"
APP_NAMESPACE="gitops-demo"
ARGOCD_NAMESPACE="argocd"
MONITORING_NAMESPACE="monitoring"
PROMETHEUS_RELEASE="kube-prometheus"

teardown_observability() {
    log_info "Removing monitoring stack..."
    if helm list -n "$MONITORING_NAMESPACE" 2>/dev/null | grep -q "$PROMETHEUS_RELEASE"; then
        helm uninstall "$PROMETHEUS_RELEASE" -n "$MONITORING_NAMESPACE"
    fi
    kubectl delete namespace "$MONITORING_NAMESPACE" --ignore-not-found=true
    log_success "Monitoring stack removed"
}

teardown_argocd() {
    log_info "Removing ArgoCD..."
    kubectl delete namespace "$ARGOCD_NAMESPACE" --ignore-not-found=true
    log_success "ArgoCD removed"
}

teardown_demo_app() {
    log_info "Removing demo-app..."
    if helm list -n "$APP_NAMESPACE" 2>/dev/null | grep -q "demo-app"; then
        helm uninstall demo-app -n "$APP_NAMESPACE"
    fi
    kubectl delete namespace "$APP_NAMESPACE" --ignore-not-found=true
    log_success "demo-app removed"
}

teardown_infrastructure() {
    log_info "Destroying Terraform-managed infrastructure..."
    if [ -f "$TF_DIR/main.tf" ]; then
        (cd "$TF_DIR" && terraform destroy -auto-approve) || true
    fi
    kubectl delete namespace "$INFRA_NAMESPACE" --ignore-not-found=true
    log_success "Infrastructure removed"
}

print_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    log_success "Teardown complete 🧹"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Removed: $MONITORING_NAMESPACE, $ARGOCD_NAMESPACE, $APP_NAMESPACE, $INFRA_NAMESPACE"
    log_info "Untouched: any namespaces from the manual exercises (Phases 1-3)"
    echo ""
    log_info "Restart the fast path any time with: ./scripts/bootstrap-full-environment.sh"
    echo "════════════════════════════════════════════════════════════════"
}

main() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "     GitOps Lab - Full Environment Teardown (Fast Path)"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    log_warning "This removes everything provisioned by bootstrap-full-environment.sh"
    read -p "Continue? (yes/no): " confirm

    if [[ "$confirm" != "yes" ]]; then
        log_info "Teardown cancelled"
        exit 0
    fi

    echo ""
    teardown_observability
    teardown_argocd
    teardown_demo_app
    teardown_infrastructure

    rm -rf "$BOOTSTRAP_DIR"

    print_summary
}

main
