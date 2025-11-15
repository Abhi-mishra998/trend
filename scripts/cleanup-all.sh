#!/bin/bash

# Trend App DevOps - Cleanup Script
# This script safely destroys all infrastructure resources

set -e

CONFIG_FILE="config.yaml"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/cleanup-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"

print_header() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_success() {
    echo "[SUCCESS] $1"
}

print_error() {
    echo "[ERROR] $1"
}

print_warning() {
    echo "[WARNING] $1"
}

print_info() {
    echo "[INFO] $1"
}

# Command validation function
# Usage: check_command "command_name" "install_url"
check_command() {
    local cmd="$1"
    local install_url="$2"
    
    if ! command -v "$cmd" &> /dev/null; then
        print_error "$cmd is required but not installed"
        print_info "Install from: $install_url"
        return 1
    fi
    return 0
}

# List resources to be destroyed
list_resources() {
    print_header "Resources to be Destroyed"
    echo ""
    
    print_info "Kubernetes Resources:"
    kubectl get all -n trend-app 2>/dev/null || echo "  None found"
    echo ""
    
    print_info "Terraform Resources:"
    cd infrastructure
    terraform show -no-color 2>/dev/null | grep -E "^resource|^data" | head -20 || echo "  None found"
    cd ..
    echo ""
}

# Delete Kubernetes resources
cleanup_kubernetes() {
    print_info "Deleting Kubernetes resources..."
    
    if kubectl delete namespace trend-app --timeout=120s >> "$LOG_FILE" 2>&1; then
        print_success "Kubernetes namespace deleted"
    else
        print_warning "Failed to delete Kubernetes namespace (may not exist)"
        print_info "If namespace is stuck in 'Terminating' state:"
        print_info "  1. Check for finalizers: kubectl get namespace trend-app -o yaml"
        print_info "  2. Force delete if needed: kubectl delete namespace trend-app --grace-period=0 --force"
    fi
    
    if kubectl delete namespace monitoring --timeout=120s >> "$LOG_FILE" 2>&1; then
        print_success "Monitoring namespace deleted"
    else
        print_warning "Failed to delete monitoring namespace (may not exist)"
    fi
    
    # Wait for LoadBalancers to be fully deleted
    print_info "Waiting for LoadBalancers to be deleted (this is important)..."
    sleep 30
}

# Destroy Terraform infrastructure
cleanup_terraform() {
    print_info "Destroying Terraform infrastructure..."
    print_warning "This may take 10-15 minutes..."
    
    cd infrastructure
    
    if terraform destroy -auto-approve >> "../$LOG_FILE" 2>&1; then
        print_success "Terraform infrastructure destroyed"
        cd ..
        return 0
    else
        print_error "Terraform destroy failed"
        print_info "Common causes:"
        print_info "  - Resources have dependencies that need manual deletion"
        print_info "  - LoadBalancers or security groups still in use"
        print_info "  - EKS cluster not fully deleted"
        print_info "  - Network interfaces still attached"
        print_info "Troubleshooting:"
        print_info "  1. Check log file: $LOG_FILE"
        print_info "  2. Delete Kubernetes resources first: kubectl delete namespace trend-app"
        print_info "  3. Wait 5 minutes for LoadBalancers to fully delete"
        print_info "  4. Check AWS console for stuck resources"
        print_info "  5. Try running cleanup again: ./scripts/cleanup-all.sh"
        print_info "Manual cleanup if needed:"
        print_info "  - Delete EKS cluster from AWS console"
        print_info "  - Delete VPC and associated resources"
        print_info "  - Delete EC2 instances (Jenkins)"
        cd ..
        return 1
    fi
}

# Verify cleanup
verify_cleanup() {
    print_info "Verifying cleanup..."
    
    local cleanup_complete=true
    
    # Check if EKS cluster still exists
    local cluster_name=$(grep -A 5 "eks:" "$CONFIG_FILE" | grep "cluster_name:" | awk '{print $2}' | tr -d '"' || echo "trend-app-eks")
    local region=$(grep "region:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '"' || echo "us-east-1")
    
    if aws eks describe-cluster --name "$cluster_name" --region "$region" >> "$LOG_FILE" 2>&1; then
        print_warning "EKS cluster still exists"
        cleanup_complete=false
    else
        print_success "EKS cluster deleted"
    fi
    
    # Check VPC
    cd infrastructure
    local vpc_id=$(terraform output -raw vpc_id 2>/dev/null || echo "")
    cd ..
    
    if [ -n "$vpc_id" ]; then
        if aws ec2 describe-vpcs --vpc-ids "$vpc_id" >> "$LOG_FILE" 2>&1; then
            print_warning "VPC still exists"
            cleanup_complete=false
        else
            print_success "VPC deleted"
        fi
    fi
    
    if [ "$cleanup_complete" = true ]; then
        print_success "All resources successfully deleted"
        return 0
    else
        print_warning "Some resources may still exist"
        return 1
    fi
}

# Cleanup complete message
show_cleanup_complete() {
    print_success "All resources deleted"
    echo ""
}

main() {
    clear
    print_header "Trend App DevOps - Cleanup"
    echo ""
    
    # Check required commands
    print_info "Checking required commands..."
    local commands_ok=true
    
    if ! check_command "terraform" "https://www.terraform.io/downloads"; then
        commands_ok=false
    fi
    
    if ! check_command "kubectl" "https://kubernetes.io/docs/tasks/tools/"; then
        commands_ok=false
    fi
    
    if ! check_command "aws" "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"; then
        commands_ok=false
    fi
    
    if [ "$commands_ok" = false ]; then
        print_error "Required commands are missing. Please install them and try again."
        exit 1
    fi
    
    print_success "All required commands are available"
    echo ""
    
    # Warning
    echo "========================================"
    echo "WARNING"
    echo "========================================"
    echo "This will permanently delete ALL infrastructure"
    echo "resources including:"
    echo "  - EKS Cluster and all workloads"
    echo "  - Jenkins EC2 instance and configuration"
    echo "  - VPC, subnets, and networking"
    echo "  - All data and configurations"
    echo ""
    echo "This action CANNOT be undone!"
    echo "========================================"
    echo ""
    
    # List resources
    list_resources
    
    # Confirmation
    echo "To confirm deletion, type 'DELETE' (in capital letters):"
    read -p "> " confirmation
    
    if [ "$confirmation" != "DELETE" ]; then
        print_info "Cleanup cancelled"
        exit 0
    fi
    
    echo ""
    print_info "Starting cleanup process..."
    print_info "Log file: $LOG_FILE"
    echo ""
    
    # Execute cleanup
    cleanup_kubernetes
    echo ""
    
    cleanup_terraform
    echo ""
    
    verify_cleanup
    echo ""
    
    show_cleanup_complete
    
    print_success "Cleanup completed"
    print_info "Log file: $LOG_FILE"
}

main
