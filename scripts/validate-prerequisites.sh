#!/bin/bash

# Trend App DevOps - Prerequisites Validation Script
# This script validates all required tools and credentials

set -e

# Minimum required versions
MIN_AWS_CLI_VERSION="2.0.0"
MIN_TERRAFORM_VERSION="1.5.0"
MIN_DOCKER_VERSION="20.10.0"
MIN_KUBECTL_VERSION="1.27.0"
MIN_HELM_VERSION="3.0.0"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Configuration file
CONFIG_FILE="config.yaml"

# Function to print messages
print_header() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_success() {
    echo "[SUCCESS] $1"
    ((PASSED++))
}

print_error() {
    echo "[ERROR] $1"
    ((FAILED++))
}

print_warning() {
    echo "[WARNING] $1"
    ((WARNINGS++))
}

print_info() {
    echo "[INFO] $1"
}

# Function to compare versions
version_ge() {
    # Returns 0 if $1 >= $2
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}


# Check AWS CLI
check_aws_cli() {
    print_info "Checking AWS CLI..."
    
    if command -v aws &> /dev/null; then
        local version=$(aws --version 2>&1 | grep -oP 'aws-cli/\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -z "$version" ]; then
            version=$(aws --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        fi
        
        if version_ge "$version" "$MIN_AWS_CLI_VERSION"; then
            print_success "AWS CLI (v$version) - OK"
        else
            print_error "AWS CLI (v$version) - Version too old (minimum: $MIN_AWS_CLI_VERSION)"
            print_info "Update: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        fi
    else
        print_error "AWS CLI not found"
        print_info "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    fi
}

# Check Terraform
check_terraform() {
    print_info "Checking Terraform..."
    
    if command -v terraform &> /dev/null; then
        local version=$(terraform version -json 2>/dev/null | grep -oP '"terraform_version":\s*"\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -z "$version" ]; then
            version=$(terraform version | grep -oP 'Terraform v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        fi
        
        if version_ge "$version" "$MIN_TERRAFORM_VERSION"; then
            print_success "Terraform (v$version) - OK"
        else
            print_error "Terraform (v$version) - Version too old (minimum: $MIN_TERRAFORM_VERSION)"
            print_info "Update: https://www.terraform.io/downloads"
        fi
    else
        print_error "Terraform not found"
        print_info "Install: https://www.terraform.io/downloads"
    fi
}

# Check Docker
check_docker() {
    print_info "Checking Docker..."
    
    if command -v docker &> /dev/null; then
        local version=$(docker --version | grep -oP 'Docker version \K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        
        if version_ge "$version" "$MIN_DOCKER_VERSION"; then
            print_success "Docker (v$version) - OK"
            
            # Check if Docker daemon is running
            if docker ps &> /dev/null; then
                print_success "Docker daemon is running"
            else
                print_error "Docker daemon is not running"
                print_info "Start Docker Desktop or run: sudo systemctl start docker"
            fi
        else
            print_error "Docker (v$version) - Version too old (minimum: $MIN_DOCKER_VERSION)"
            print_info "Update: https://docs.docker.com/get-docker/"
        fi
    else
        print_error "Docker not found"
        print_info "Install: https://docs.docker.com/get-docker/"
    fi
}

# Check kubectl
check_kubectl() {
    print_info "Checking kubectl..."
    
    if command -v kubectl &> /dev/null; then
        local version=$(kubectl version --client -o json 2>/dev/null | grep -oP '"gitVersion":\s*"v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -z "$version" ]; then
            version=$(kubectl version --client --short 2>/dev/null | grep -oP 'Client Version: v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        fi
        
        if version_ge "$version" "$MIN_KUBECTL_VERSION"; then
            print_success "kubectl (v$version) - OK"
        else
            print_error "kubectl (v$version) - Version too old (minimum: $MIN_KUBECTL_VERSION)"
            print_info "Update: https://kubernetes.io/docs/tasks/tools/"
        fi
    else
        print_error "kubectl not found"
        print_info "Install: https://kubernetes.io/docs/tasks/tools/"
    fi
}

# Check Helm (optional)
check_helm() {
    print_info "Checking Helm (optional)..."
    
    if command -v helm &> /dev/null; then
        local version=$(helm version --short 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        
        if version_ge "$version" "$MIN_HELM_VERSION"; then
            print_success "Helm (v$version) - OK"
        else
            print_warning "Helm (v$version) - Version too old (minimum: $MIN_HELM_VERSION)"
            print_info "Update: https://helm.sh/docs/intro/install/"
        fi
    else
        print_warning "Helm not found (optional for monitoring)"
        print_info "Install: https://helm.sh/docs/intro/install/"
    fi
}


# Check AWS credentials
check_aws_credentials() {
    print_info "Checking AWS credentials..."
    
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity &> /dev/null; then
            local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
            local user_arn=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
            print_success "AWS credentials valid"
            print_info "  Account: $account_id"
            print_info "  Identity: $user_arn"
        else
            print_error "AWS credentials not configured or invalid"
            print_info "Run: aws configure"
        fi
    else
        print_warning "AWS CLI not found, skipping credential check"
    fi
}

# Check AWS permissions
check_aws_permissions() {
    print_info "Checking AWS permissions..."
    
    if ! command -v aws &> /dev/null; then
        print_warning "AWS CLI not found, skipping permission check"
        return
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_warning "AWS credentials not configured, skipping permission check"
        return
    fi
    
    local permissions_ok=true
    
    # Check EC2 permissions
    if aws ec2 describe-vpcs --max-results 1 &> /dev/null; then
        print_success "EC2 permissions - OK"
    else
        print_error "EC2 permissions - Insufficient"
        permissions_ok=false
    fi
    
    # Check EKS permissions
    if aws eks list-clusters --max-results 1 &> /dev/null; then
        print_success "EKS permissions - OK"
    else
        print_error "EKS permissions - Insufficient"
        permissions_ok=false
    fi
    
    # Check IAM permissions
    if aws iam list-roles --max-items 1 &> /dev/null; then
        print_success "IAM permissions - OK"
    else
        print_error "IAM permissions - Insufficient"
        permissions_ok=false
    fi
    
    if [ "$permissions_ok" = false ]; then
        print_info "Required permissions: ec2:*, eks:*, iam:*, vpc:*, elasticloadbalancing:*"
    fi
}

# Check config.yaml
check_config_file() {
    print_info "Checking configuration file..."
    
    if [ -f "$CONFIG_FILE" ]; then
        print_success "config.yaml exists"
        
        # Check for placeholder values
        if grep -q "123456789012" "$CONFIG_FILE" 2>/dev/null; then
            print_warning "config.yaml contains placeholder AWS Account ID"
            print_info "Run: ./scripts/setup-wizard.sh"
        fi
        
        if grep -q "yourusername" "$CONFIG_FILE" 2>/dev/null; then
            print_warning "config.yaml contains placeholder DockerHub username"
            print_info "Run: ./scripts/setup-wizard.sh"
        fi
        
        # Validate config using Python script if available
        if [ -f "scripts/validate-config.py" ] && command -v python3 &> /dev/null; then
            if python3 scripts/validate-config.py &> /dev/null; then
                print_success "config.yaml is valid"
            else
                print_error "config.yaml has validation errors"
                print_info "Run: python3 scripts/validate-config.py"
            fi
        elif [ -f "scripts/validate-config.sh" ]; then
            if bash scripts/validate-config.sh &> /dev/null; then
                print_success "config.yaml is valid"
            else
                print_error "config.yaml has validation errors"
                print_info "Run: bash scripts/validate-config.sh"
            fi
        fi
    else
        print_error "config.yaml not found"
        print_info "Run: ./scripts/setup-wizard.sh"
    fi
}

# Check network connectivity
check_network_connectivity() {
    print_info "Checking network connectivity..."
    
    # Check AWS connectivity
    if command -v curl &> /dev/null; then
        if curl -s --connect-timeout 5 https://aws.amazon.com > /dev/null; then
            print_success "AWS connectivity - OK"
        else
            print_error "Cannot reach AWS"
            print_info "Check your internet connection and firewall"
        fi
        
        # Check DockerHub connectivity
        if curl -s --connect-timeout 5 https://hub.docker.com > /dev/null; then
            print_success "DockerHub connectivity - OK"
        else
            print_warning "Cannot reach DockerHub"
            print_info "Check your internet connection and firewall"
        fi
        
        # Check GitHub connectivity
        if curl -s --connect-timeout 5 https://github.com > /dev/null; then
            print_success "GitHub connectivity - OK"
        else
            print_warning "Cannot reach GitHub"
            print_info "Check your internet connection and firewall"
        fi
    else
        print_warning "curl not found, skipping connectivity checks"
    fi
}

# Check Git
check_git() {
    print_info "Checking Git..."
    
    if command -v git &> /dev/null; then
        local version=$(git --version | grep -oP 'git version \K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_success "Git (v$version) - OK"
    else
        print_warning "Git not found (optional)"
        print_info "Install: https://git-scm.com/downloads"
    fi
}

# Check Python (for validation scripts)
check_python() {
    print_info "Checking Python..."
    
    if command -v python3 &> /dev/null; then
        local version=$(python3 --version | grep -oP 'Python \K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_success "Python 3 (v$version) - OK"
        
        # Check for PyYAML
        if python3 -c "import yaml" &> /dev/null; then
            print_success "PyYAML module - OK"
        else
            print_warning "PyYAML module not found"
            print_info "Install: pip3 install pyyaml"
        fi
    else
        print_warning "Python 3 not found (optional for validation)"
        print_info "Install: https://www.python.org/downloads/"
    fi
}


# Main validation function
main() {
    clear
    print_header "Prerequisites Validation"
    echo ""
    echo "Checking all required tools and configurations..."
    echo ""
    
    # Required tools
    print_header "Required Tools"
    echo ""
    check_aws_cli
    check_terraform
    check_docker
    check_kubectl
    echo ""
    
    # Optional tools
    print_header "Optional Tools"
    echo ""
    check_helm
    check_git
    check_python
    echo ""
    
    # AWS configuration
    print_header "AWS Configuration"
    echo ""
    check_aws_credentials
    check_aws_permissions
    echo ""
    
    # Configuration file
    print_header "Configuration"
    echo ""
    check_config_file
    echo ""
    
    # Network connectivity
    print_header "Network Connectivity"
    echo ""
    check_network_connectivity
    echo ""
    
    # Summary
    print_header "Validation Summary"
    echo ""
    echo "Passed:   $PASSED"
    echo "Warnings: $WARNINGS"
    echo "Failed:   $FAILED"
    echo ""
    
    if [ $FAILED -eq 0 ]; then
        print_success "All prerequisites met! Ready to deploy."
        echo ""
        echo "Next steps:"
        echo "  1. Review configuration: cat config.yaml"
        echo "  2. Deploy infrastructure: ./scripts/deploy-all.sh"
        echo ""
        exit 0
    else
        print_error "Some prerequisites are not met."
        echo ""
        echo "Please install missing tools and configure credentials."
        echo "Then run this script again."
        echo ""
        exit 1
    fi
}

# Run main function
main
