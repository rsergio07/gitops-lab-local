#!/bin/bash

###############################################################################
# SRE Automation Mastery - macOS Setup Script
# 
# This script installs all required tools for the course:
# - Homebrew
# - Colima (Docker Engine runtime)
# - Minikube (Local Kubernetes)
# - kubectl, helm, terraform, ansible
# - Additional CLI tools
#
# Requirements: macOS 11.0 (Big Sur) or later
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

# Check if running on macOS
check_os() {
    log_info "Checking operating system..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only."
        exit 1
    fi
    
    # Check macOS version
    os_version=$(sw_vers -productVersion)
    log_success "Running on macOS $os_version"
    
    # Check if version is 11.0 or higher
    major_version=$(echo "$os_version" | cut -d. -f1)
    if [ "$major_version" -lt 11 ]; then
        log_error "macOS 11.0 (Big Sur) or later is required. You have $os_version"
        exit 1
    fi
}

# Check system resources
check_resources() {
    log_info "Checking system resources..."
    
    # Check CPU cores
    cpu_cores=$(sysctl -n hw.ncpu)
    log_info "CPU cores: $cpu_cores"
    if [ "$cpu_cores" -lt 4 ]; then
        log_warning "Less than 4 CPU cores detected. 4+ cores recommended for best performance."
    fi
    
    # Check RAM (in GB)
    ram_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    log_info "RAM: ${ram_gb}GB"
    if [ "$ram_gb" -lt 8 ]; then
        log_error "Less than 8GB RAM detected. 8GB minimum required, 16GB recommended."
        exit 1
    elif [ "$ram_gb" -lt 16 ]; then
        log_warning "Less than 16GB RAM. 16GB recommended for optimal performance."
    fi
    
    # Check disk space
    available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/Gi//')
    log_info "Available disk space: ${available_space}GB"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_success "Homebrew already installed"
        log_info "Updating Homebrew..."
        brew update
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed successfully"
    fi
}

# Install Colima
install_colima() {
    if command -v colima &> /dev/null; then
        log_success "Colima already installed ($(colima version))"
    else
        log_info "Installing Colima..."
        brew install colima
        log_success "Colima installed successfully"
    fi
    
    # Check if Colima is running
    if colima status &> /dev/null; then
        log_success "Colima is already running"
    else
        log_info "Starting Colima..."
        colima start --cpu 4 --memory 8 --disk 50
        log_success "Colima started successfully"
    fi
}

# Install Docker CLI
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker CLI already installed ($(docker --version))"
    else
        log_info "Installing Docker CLI..."
        brew install docker
        log_success "Docker CLI installed successfully"
    fi
}

# Install Minikube
install_minikube() {
    if command -v minikube &> /dev/null; then
        log_success "Minikube already installed ($(minikube version --short))"
    else
        log_info "Installing Minikube..."
        brew install minikube
        log_success "Minikube installed successfully"
    fi
    
    # Check if Minikube is running
    if minikube status &> /dev/null; then
        log_success "Minikube cluster is already running"
    else
        log_info "Starting Minikube cluster..."
        minikube start --driver=docker --cpus=4 --memory=6144 --disk-size=40g
        log_success "Minikube cluster started successfully"
    fi
}

# Install kubectl
install_kubectl() {
    if command -v kubectl &> /dev/null; then
        log_success "kubectl already installed ($(kubectl version --client --short 2>/dev/null || kubectl version --client))"
    else
        log_info "Installing kubectl..."
        brew install kubectl
        log_success "kubectl installed successfully"
    fi
}

# Install Helm
install_helm() {
    if command -v helm &> /dev/null; then
        log_success "Helm already installed ($(helm version --short))"
    else
        log_info "Installing Helm..."
        brew install helm
        log_success "Helm installed successfully"
    fi
}

# Install Terraform
install_terraform() {
    if command -v terraform &> /dev/null; then
        log_success "Terraform already installed ($(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4))"
    else
        log_info "Installing Terraform..."
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        log_success "Terraform installed successfully"
    fi
}

# Install Ansible
install_ansible() {
    if command -v ansible &> /dev/null; then
        log_success "Ansible already installed ($(ansible --version | head -n1))"
    else
        log_info "Installing Ansible..."
        brew install ansible
        log_success "Ansible installed successfully"
    fi
}

# Install additional tools
install_additional_tools() {
    log_info "Installing additional CLI tools..."
    
    # jq for JSON processing
    if ! command -v jq &> /dev/null; then
        brew install jq
        log_success "jq installed"
    fi
    
    # yq for YAML processing
    if ! command -v yq &> /dev/null; then
        brew install yq
        log_success "yq installed"
    fi
    
    # git (usually pre-installed, but ensure it's there)
    if ! command -v git &> /dev/null; then
        brew install git
        log_success "git installed"
    fi
    
    # k9s (Kubernetes CLI dashboard)
    if ! command -v k9s &> /dev/null; then
        brew install k9s
        log_success "k9s installed"
    fi
}

# Verify installations
verify_installations() {
    log_info "Verifying all installations..."
    echo ""
    
    # Check Colima
    echo "=== Colima ==="
    colima version
    colima status
    echo ""
    
    # Check Docker
    echo "=== Docker ==="
    docker --version
    docker ps
    echo ""
    
    # Check Minikube
    echo "=== Minikube ==="
    minikube version
    minikube status
    echo ""
    
    # Check kubectl
    echo "=== kubectl ==="
    kubectl version --client --short 2>/dev/null || kubectl version --client
    kubectl cluster-info
    kubectl get nodes
    echo ""
    
    # Check Helm
    echo "=== Helm ==="
    helm version
    echo ""
    
    # Check Terraform
    echo "=== Terraform ==="
    terraform version
    echo ""
    
    # Check Ansible
    echo "=== Ansible ==="
    ansible --version | head -n1
    echo ""
    
    log_success "All tools installed and verified successfully!"
}

# Enable Minikube addons
enable_minikube_addons() {
    log_info "Enabling useful Minikube addons..."
    
    minikube addons enable metrics-server
    minikube addons enable dashboard
    minikube addons enable ingress
    
    log_success "Minikube addons enabled"
}

# Create helpful aliases
create_aliases() {
    log_info "Creating helpful aliases..."
    
    # Detect shell
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Add aliases if not already present
    if ! grep -q "# SRE Automation Mastery aliases" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << 'EOF'

# SRE Automation Mastery aliases
alias k='kubectl'
alias mk='minikube'
alias h='helm'
alias tf='terraform'

EOF
        log_success "Aliases added to $shell_rc"
        log_info "Run 'source $shell_rc' or restart your terminal to use aliases"
    else
        log_info "Aliases already exist in $shell_rc"
    fi
}

# Print next steps
print_next_steps() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    log_success "Setup completed successfully! 🎉"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Next steps:"
    echo ""
    echo "  1. Verify your cluster:"
    echo "     kubectl get pods -A"
    echo ""
    echo "  2. Access Minikube dashboard (optional):"
    echo "     minikube dashboard"
    echo ""
    echo "════════════════════════════════════════════════════════════════"
}

# Main installation flow
main() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "     SRE Automation Mastery - macOS Setup Script"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    check_os
    check_resources
    
    echo ""
    log_info "Starting installation process..."
    echo ""
    
    install_homebrew
    install_colima
    install_docker
    install_minikube
    install_kubectl
    install_helm
    install_terraform
    install_ansible
    install_additional_tools
    
    echo ""
    enable_minikube_addons
    create_aliases
    
    echo ""
    verify_installations
    
    print_next_steps
}

# Run main function
main