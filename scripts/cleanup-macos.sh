#!/bin/bash

###############################################################################
# SRE Automation Mastery - Cleanup Script
# 
# This script stops and deletes Colima and Minikube instances
# Use this to free up resources or start fresh
#
# Note: This does NOT uninstall the tools, only stops/deletes their instances
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Stop and delete Minikube
cleanup_minikube() {
    log_info "Cleaning up Minikube..."
    
    if command -v minikube &> /dev/null; then
        if minikube status &> /dev/null; then
            log_info "Stopping Minikube cluster..."
            minikube stop
            log_success "Minikube stopped"
        else
            log_info "Minikube is not running"
        fi
        
        log_info "Deleting Minikube cluster..."
        minikube delete
        log_success "Minikube cluster deleted"
    else
        log_warning "Minikube is not installed"
    fi
}

# Stop and delete Colima
cleanup_colima() {
    log_info "Cleaning up Colima..."
    
    if command -v colima &> /dev/null; then
        if colima status &> /dev/null; then
            log_info "Stopping Colima..."
            colima stop
            log_success "Colima stopped"
        else
            log_info "Colima is not running"
        fi
        
        log_info "Deleting Colima instance..."
        colima delete
        log_success "Colima instance deleted"
    else
        log_warning "Colima is not installed"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    log_success "Cleanup completed! 🧹"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    log_info "What was cleaned:"
    echo "  ✓ Minikube cluster stopped and deleted"
    echo "  ✓ Colima instance stopped and deleted"
    echo ""
    log_info "What was NOT removed:"
    echo "  • Homebrew and installed tools (helm, terraform, ansible, etc.)"
    echo "  • You can reinstall by running: ./scripts/setup-macos.sh"
    echo ""
    echo "════════════════════════════════════════════════════════════════"
}

# Main cleanup flow
main() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "     SRE Automation Mastery - Cleanup Script"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    log_warning "This will stop and delete Colima and Minikube instances"
    log_warning "All running containers and Kubernetes resources will be removed"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Cleanup cancelled"
        exit 0
    fi
    
    echo ""
    cleanup_minikube
    echo ""
    cleanup_colima
    
    print_summary
}

# Run main function
main