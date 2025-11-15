#!/bin/bash

# Trend App DevOps - Master Deployment Script
# This script orchestrates the complete deployment process

set -e

# Configuration
CONFIG_FILE="config.yaml"
STATE_FILE=".deployment-state.json"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/deployment-$(date +%Y%m%d-%H%M%S).log"

# Phase tracking
CURRENT_PHASE=0
TOTAL_PHASES=7
START_TIME=$(date +%s)

# Create log directory
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo "========================================" | tee -a "$LOG_FILE"
    echo "$1" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
}

print_success() {
    echo "[SUCCESS] $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo "[WARNING] $1" | tee -a "$LOG_FILE"
}

print_info() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
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

# Progress tracking
update_progress() {
    local phase_name="$1"
    local status="$2"  # in_progress, completed, failed
    
    ((CURRENT_PHASE++))
    local percent=$((CURRENT_PHASE * 100 / TOTAL_PHASES))
    local elapsed=$(($(date +%s) - START_TIME))
    local elapsed_min=$((elapsed / 60))
    local elapsed_sec=$((elapsed % 60))
    
    echo "" | tee -a "$LOG_FILE"
    echo "Deployment Progress" | tee -a "$LOG_FILE"
    echo "Phase: $phase_name" | tee -a "$LOG_FILE"
    echo "Status: $status" | tee -a "$LOG_FILE"
    echo "Elapsed Time: ${elapsed_min}m ${elapsed_sec}s" | tee -a "$LOG_FILE"
    echo "Progress: ${percent}%" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Phase 1: Prerequisites validation
phase_prerequisites() {
    update_progress "Prerequisites Validation" "in_progress"
    log "Starting prerequisites validation..."
    
    # Check required commands before proceeding
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
    
    if [ -f "scripts/validate-prerequisites.sh" ]; then
        if bash scripts/validate-prerequisites.sh >> "$LOG_FILE" 2>&1; then
            update_progress "Prerequisites Validation" "completed"
            print_success "Prerequisites validation passed"
            return 0
        else
            update_progress "Prerequisites Validation" "failed"
            print_error "Prerequisites validation failed"
            print_info "Check log: $LOG_FILE"
            exit 1
        fi
    else
        print_warning "Prerequisites validation script not found, skipping..."
        update_progress "Prerequisites Validation" "completed"
    fi
}

# Phase 2: Terraform initialization
phase_terraform_init() {
    update_progress "Terraform Initialization" "in_progress"
    log "Initializing Terraform..."
    
    cd infrastructure
    
    if terraform init >> "../$LOG_FILE" 2>&1; then
        update_progress "Terraform Initialization" "completed"
        print_success "Terraform initialized"
        cd ..
        return 0
    else
        update_progress "Terraform Initialization" "failed"
        print_error "Terraform initialization failed"
        print_info "Common causes:"
        print_info "  - Invalid Terraform configuration syntax"
        print_info "  - Network connectivity issues"
        print_info "  - Missing provider credentials"
        print_info "Troubleshooting:"
        print_info "  1. Check log file: $LOG_FILE"
        print_info "  2. Run: cd infrastructure && terraform init"
        print_info "  3. Verify AWS credentials: aws sts get-caller-identity"
        cd ..
        exit 1
    fi
}

# Phase 3: Terraform apply
phase_terraform_apply() {
    update_progress "Infrastructure Provisioning" "in_progress"
    log "Provisioning infrastructure with Terraform..."
    
    cd infrastructure
    
    print_info "This may take 10-15 minutes..."
    
    if terraform apply -auto-approve >> "../$LOG_FILE" 2>&1; then
        update_progress "Infrastructure Provisioning" "completed"
        print_success "Infrastructure provisioned successfully"
        
        # Save outputs
        terraform output -json > "../$STATE_FILE" 2>/dev/null || true
        
        cd ..
        return 0
    else
        update_progress "Infrastructure Provisioning" "failed"
        print_error "Infrastructure provisioning failed"
        print_info "Common causes:"
        print_info "  - Insufficient AWS permissions"
        print_info "  - Resource limits exceeded (VPC, EIP, etc.)"
        print_info "  - Invalid configuration values"
        print_info "  - Region capacity issues"
        print_info "Troubleshooting:"
        print_info "  1. Check log file: $LOG_FILE"
        print_info "  2. Review AWS console for partial resources"
        print_info "  3. Run: cd infrastructure && terraform plan"
        print_info "  4. Verify AWS service quotas in your region"
        print_info "  5. Try a different region if capacity issues"
        cd ..
        exit 1
    fi
}

# Phase 4: Generate kubeconfig
phase_kubeconfig() {
    update_progress "Kubeconfig Generation" "in_progress"
    log "Generating kubeconfig for EKS..."
    
    # Extract cluster name and region from config
    local cluster_name=$(grep -A 5 "eks:" "$CONFIG_FILE" | grep "cluster_name:" | awk '{print $2}' | tr -d '"')
    local region=$(grep "region:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '"')
    
    if [ -z "$cluster_name" ] || [ -z "$region" ]; then
        cluster_name="trend-app-eks"
        region="us-east-1"
    fi
    
    if aws eks update-kubeconfig --name "$cluster_name" --region "$region" >> "$LOG_FILE" 2>&1; then
        update_progress "Kubeconfig Generation" "completed"
        print_success "Kubeconfig generated"
        return 0
    else
        update_progress "Kubeconfig Generation" "failed"
        print_error "Kubeconfig generation failed"
        print_info "Common causes:"
        print_info "  - EKS cluster not fully created yet"
        print_info "  - Incorrect cluster name or region"
        print_info "  - AWS credentials don't have EKS access"
        print_info "Troubleshooting:"
        print_info "  1. Check log file: $LOG_FILE"
        print_info "  2. Verify cluster exists: aws eks describe-cluster --name $cluster_name --region $region"
        print_info "  3. Check AWS console EKS section"
        print_info "  4. Wait a few minutes and try again"
        exit 1
    fi
}


# Phase 5: Deploy Kubernetes resources
phase_kubernetes_deploy() {
    update_progress "Kubernetes Deployment" "in_progress"
    log "Deploying Kubernetes resources..."
    
    # Wait for nodes to be ready
    print_info "Waiting for EKS nodes to be ready..."
    local retries=0
    while [ $retries -lt 30 ]; do
        if kubectl get nodes >> "$LOG_FILE" 2>&1; then
            local ready_nodes=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready" || echo "0")
            if [ "$ready_nodes" -gt 0 ]; then
                print_success "EKS nodes are ready ($ready_nodes nodes)"
                break
            fi
        fi
        ((retries++))
        sleep 10
    done
    
    # Apply Kubernetes manifests
    if kubectl apply -f k8s/namespace.yaml >> "$LOG_FILE" 2>&1 && \
       kubectl apply -f k8s/deployment.yaml >> "$LOG_FILE" 2>&1 && \
       kubectl apply -f k8s/service.yaml >> "$LOG_FILE" 2>&1 && \
       kubectl apply -f k8s/hpa.yaml >> "$LOG_FILE" 2>&1; then
        
        print_success "Kubernetes resources deployed"
        
        # Wait for pods to be ready
        print_info "Waiting for pods to be ready..."
        kubectl wait --for=condition=ready pod -l app=trend-app -n trend-app --timeout=300s >> "$LOG_FILE" 2>&1 || true
        
        update_progress "Kubernetes Deployment" "completed"
        return 0
    else
        update_progress "Kubernetes Deployment" "failed"
        print_error "Kubernetes deployment failed"
        print_info "Common causes:"
        print_info "  - Invalid Kubernetes manifest syntax"
        print_info "  - Docker image not accessible"
        print_info "  - Insufficient cluster resources"
        print_info "  - Image pull errors (check DockerHub credentials)"
        print_info "Troubleshooting:"
        print_info "  1. Check log file: $LOG_FILE"
        print_info "  2. Check pod status: kubectl get pods -n trend-app"
        print_info "  3. Check pod logs: kubectl describe pod <pod-name> -n trend-app"
        print_info "  4. Verify image exists: docker pull <your-dockerhub-repo>:latest"
        print_info "  5. Check events: kubectl get events -n trend-app --sort-by='.lastTimestamp'"
        exit 1
    fi
}

# Phase 6: Install monitoring (optional)
phase_monitoring() {
    # Check if monitoring is enabled in config
    local monitoring_enabled=$(grep -A 2 "monitoring:" "$CONFIG_FILE" | grep "enabled:" | head -1 | awk '{print $2}' | tr -d '"')
    
    if [ "$monitoring_enabled" = "true" ]; then
        update_progress "Monitoring Installation" "in_progress"
        log "Installing monitoring stack..."
        
        if [ -f "monitoring/install-monitoring.sh" ]; then
            if bash monitoring/install-monitoring.sh >> "$LOG_FILE" 2>&1; then
                update_progress "Monitoring Installation" "completed"
                print_success "Monitoring stack installed"
                return 0
            else
                update_progress "Monitoring Installation" "failed"
                print_warning "Monitoring installation failed (non-critical)"
            fi
        else
            print_warning "Monitoring installation script not found, skipping..."
            update_progress "Monitoring Installation" "completed"
        fi
    else
        print_info "Monitoring disabled in configuration, skipping..."
        update_progress "Monitoring Installation" "completed"
    fi
}

# Phase 7: Verification
phase_verification() {
    update_progress "Deployment Verification" "in_progress"
    log "Verifying deployment..."
    
    local verification_passed=true
    
    # Check Terraform outputs
    if [ -f "infrastructure/terraform.tfstate" ]; then
        print_success "Terraform state exists"
    else
        print_warning "Terraform state not found"
        verification_passed=false
    fi
    
    # Check EKS cluster
    if kubectl cluster-info >> "$LOG_FILE" 2>&1; then
        print_success "EKS cluster is accessible"
    else
        print_error "Cannot access EKS cluster"
        verification_passed=false
    fi
    
    # Check pods
    local running_pods=$(kubectl get pods -n trend-app --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    if [ "$running_pods" -gt 0 ]; then
        print_success "Application pods are running ($running_pods pods)"
    else
        print_warning "No running pods found"
        verification_passed=false
    fi
    
    # Check service
    if kubectl get svc trend-app-service -n trend-app >> "$LOG_FILE" 2>&1; then
        print_success "Application service exists"
    else
        print_warning "Application service not found"
        verification_passed=false
    fi
    
    if [ "$verification_passed" = true ]; then
        update_progress "Deployment Verification" "completed"
        return 0
    else
        update_progress "Deployment Verification" "failed"
        print_warning "Some verification checks failed"
        return 1
    fi
}

# Display deployment summary
display_summary() {
    local total_time=$(($(date +%s) - START_TIME))
    local total_min=$((total_time / 60))
    local total_sec=$((total_time % 60))
    
    echo "" | tee -a "$LOG_FILE"
    print_header "Deployment Summary"
    echo "" | tee -a "$LOG_FILE"
    
    print_success "Deployment completed in ${total_min}m ${total_sec}s"
    echo "" | tee -a "$LOG_FILE"
    
    # Get Jenkins URL
    cd infrastructure
    local jenkins_url=$(terraform output -raw jenkins_url 2>/dev/null || echo "N/A")
    cd ..
    
    # Get LoadBalancer URL
    local lb_url=$(kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Pending...")
    
    echo "Access URLs:" | tee -a "$LOG_FILE"
    echo "  Jenkins: $jenkins_url" | tee -a "$LOG_FILE"
    echo "  Application: http://$lb_url" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    echo "Next Steps:" | tee -a "$LOG_FILE"
    echo "  1. Access Jenkins and configure credentials" | tee -a "$LOG_FILE"
    echo "  2. Create Jenkins pipeline from Jenkinsfile" | tee -a "$LOG_FILE"
    echo "  3. Configure GitHub webhook for auto-deployment" | tee -a "$LOG_FILE"
    echo "  4. Access application at LoadBalancer URL" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    print_info "Full deployment log: $LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}


# Main deployment function
main() {
    clear
    print_header "Trend App DevOps - Master Deployment"
    echo "" | tee -a "$LOG_FILE"
    
    log "Deployment started"
    
    # Check if config exists
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        print_info "Run: ./scripts/setup-wizard.sh"
        exit 1
    fi
    
    # Apply configuration (replace placeholders)
    print_info "Applying configuration from $CONFIG_FILE..."
    if [ -f "scripts/apply-config.sh" ]; then
        bash scripts/apply-config.sh >> "$LOG_FILE" 2>&1 || {
            print_error "Failed to apply configuration"
            exit 1
        }
        print_success "Configuration applied"
    else
        print_warning "apply-config.sh not found, skipping placeholder replacement"
    fi
    
    print_info "Configuration: $CONFIG_FILE"
    print_info "Log file: $LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Confirmation
    echo "This will deploy the complete infrastructure to AWS." | tee -a "$LOG_FILE"
    echo "Estimated time: 20-35 minutes" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    read -p "Do you want to continue? [y/N]: " confirm
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
    if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
        print_info "Deployment cancelled"
        exit 0
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Execute deployment phases
    phase_prerequisites
    phase_terraform_init
    phase_terraform_apply
    phase_kubeconfig
    phase_kubernetes_deploy
    phase_monitoring
    phase_verification
    
    # Display summary
    display_summary
    
    log "Deployment completed successfully"
}

# Error handler
error_handler() {
    local line_number=$1
    print_error "Deployment failed at line $line_number"
    print_info "Check log for details: $LOG_FILE"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Run main function
main
