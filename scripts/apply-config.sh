#!/bin/bash

# Trend App DevOps - Apply Configuration Script
# This script reads config.yaml and replaces placeholders in all files

set -e

CONFIG_FILE="config.yaml"

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

# Function to extract value from YAML (simple parser)
get_yaml_value() {
    local key="$1"
    local file="$2"
    
    # Simple YAML parser for key: "value" or key: value format
    grep -E "^\s*${key}:" "$file" | head -1 | sed -E 's/.*:\s*"?([^"]*)"?.*/\1/' | tr -d '"' | xargs
}

# Check if config.yaml exists
check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        print_info "Run: bash scripts/setup-wizard.sh"
        exit 1
    fi
    print_success "Configuration file found"
}

# Extract values from config.yaml
extract_values() {
    print_info "Extracting values from $CONFIG_FILE..."
    
    # AWS Configuration
    AWS_ACCOUNT_ID=$(get_yaml_value "account_id" "$CONFIG_FILE")
    AWS_REGION=$(get_yaml_value "region" "$CONFIG_FILE")
    
    # DockerHub Configuration
    DOCKERHUB_USERNAME=$(get_yaml_value "username" "$CONFIG_FILE")
    DOCKERHUB_REPO=$(get_yaml_value "repository" "$CONFIG_FILE")
    
    # Validate extracted values
    if [ -z "$AWS_ACCOUNT_ID" ] || [ "$AWS_ACCOUNT_ID" = "123456789012" ]; then
        print_error "AWS Account ID not configured in $CONFIG_FILE"
        exit 1
    fi
    
    if [ -z "$DOCKERHUB_REPO" ] || [ "$DOCKERHUB_REPO" = "yourusername/trend-app" ]; then
        print_error "DockerHub repository not configured in $CONFIG_FILE"
        exit 1
    fi
    
    print_success "Values extracted successfully"
    echo "  AWS Account ID: $AWS_ACCOUNT_ID"
    echo "  AWS Region: $AWS_REGION"
    echo "  DockerHub Repo: $DOCKERHUB_REPO"
}

# Replace placeholders in Kubernetes manifests
update_kubernetes_manifests() {
    print_info "Updating Kubernetes manifests..."
    
    # Update deployment.yaml
    if [ -f "k8s/deployment.yaml" ]; then
        if grep -q "{{DOCKERHUB_REPO}}" "k8s/deployment.yaml"; then
            sed -i.bak "s|{{DOCKERHUB_REPO}}|${DOCKERHUB_REPO}|g" "k8s/deployment.yaml"
            rm -f "k8s/deployment.yaml.bak"
            print_success "Updated k8s/deployment.yaml"
        else
            print_info "k8s/deployment.yaml already updated"
        fi
    fi
}

# Replace placeholders in Jenkinsfile
update_jenkinsfile() {
    print_info "Updating Jenkinsfile..."
    
    if [ -f "Jenkinsfile" ]; then
        if grep -q "{{DOCKERHUB_REPO}}" "Jenkinsfile"; then
            sed -i.bak "s|{{DOCKERHUB_REPO}}|${DOCKERHUB_REPO}|g" "Jenkinsfile"
            rm -f "Jenkinsfile.bak"
            print_success "Updated Jenkinsfile"
        else
            print_info "Jenkinsfile already updated"
        fi
    fi
}

# Replace placeholders in Terraform variables
update_terraform_variables() {
    print_info "Updating Terraform variables..."
    
    if [ -f "infrastructure/variables.tf" ]; then
        if grep -q "{{AWS_ACCOUNT_ID}}" "infrastructure/variables.tf"; then
            sed -i.bak "s|{{AWS_ACCOUNT_ID}}|${AWS_ACCOUNT_ID}|g" "infrastructure/variables.tf"
            rm -f "infrastructure/variables.tf.bak"
            print_success "Updated infrastructure/variables.tf"
        else
            print_info "infrastructure/variables.tf already updated"
        fi
    fi
}

# Generate terraform.tfvars from config.yaml
generate_tfvars() {
    print_info "Generating infrastructure/terraform.tfvars..."
    
    # Extract additional values
    PROJECT_NAME=$(get_yaml_value "name" "$CONFIG_FILE")
    ENVIRONMENT=$(get_yaml_value "environment" "$CONFIG_FILE")
    AWS_PROFILE=$(get_yaml_value "profile" "$CONFIG_FILE")
    EKS_CLUSTER_NAME=$(get_yaml_value "cluster_name" "$CONFIG_FILE")
    EKS_VERSION=$(get_yaml_value "version" "$CONFIG_FILE")
    JENKINS_INSTANCE_TYPE=$(grep -A 10 "jenkins:" "$CONFIG_FILE" | get_yaml_value "instance_type" "$CONFIG_FILE")
    EKS_NODE_INSTANCE_TYPE=$(grep -A 20 "nodes:" "$CONFIG_FILE" | grep "instance_type:" | head -1 | sed -E 's/.*:\s*"?([^"]*)"?.*/\1/' | tr -d '"' | xargs)
    EKS_NODE_DESIRED=$(grep -A 20 "nodes:" "$CONFIG_FILE" | get_yaml_value "desired_size" "$CONFIG_FILE")
    EKS_NODE_MIN=$(grep -A 20 "nodes:" "$CONFIG_FILE" | get_yaml_value "min_size" "$CONFIG_FILE")
    EKS_NODE_MAX=$(grep -A 20 "nodes:" "$CONFIG_FILE" | get_yaml_value "max_size" "$CONFIG_FILE")
    
    # Create terraform.tfvars
    cat > infrastructure/terraform.tfvars <<EOF
# Auto-generated from config.yaml by apply-config.sh
# Do not edit manually - changes will be overwritten

# AWS Configuration
aws_region     = "${AWS_REGION}"
aws_profile    = "${AWS_PROFILE}"
aws_account_id = "${AWS_ACCOUNT_ID}"

# Project Configuration
project_name = "${PROJECT_NAME}"
environment  = "${ENVIRONMENT}"

# EKS Configuration
eks_cluster_name         = "${EKS_CLUSTER_NAME}"
eks_cluster_version      = "${EKS_VERSION}"
eks_node_instance_types  = ["${EKS_NODE_INSTANCE_TYPE}"]
eks_node_desired_size    = ${EKS_NODE_DESIRED}
eks_node_min_size        = ${EKS_NODE_MIN}
eks_node_max_size        = ${EKS_NODE_MAX}

# Jenkins Configuration
jenkins_instance_type = "${JENKINS_INSTANCE_TYPE}"
EOF
    
    print_success "Generated infrastructure/terraform.tfvars"
}

# Verify all placeholders are replaced
verify_replacements() {
    print_info "Verifying placeholder replacements..."
    
    local errors=0
    
    # Check for remaining placeholders
    if grep -r "{{DOCKERHUB_REPO}}" k8s/ Jenkinsfile 2>/dev/null; then
        print_error "Found unreplaced {{DOCKERHUB_REPO}} placeholders"
        ((errors++))
    fi
    
    if grep -r "{{AWS_ACCOUNT_ID}}" infrastructure/variables.tf 2>/dev/null; then
        print_error "Found unreplaced {{AWS_ACCOUNT_ID}} placeholders"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "All placeholders replaced successfully"
        return 0
    else
        print_error "Some placeholders were not replaced"
        return 1
    fi
}

# Main function
main() {
    clear
    print_header "Apply Configuration"
    echo ""
    
    check_config
    echo ""
    
    extract_values
    echo ""
    
    update_kubernetes_manifests
    update_jenkinsfile
    update_terraform_variables
    echo ""
    
    generate_tfvars
    echo ""
    
    verify_replacements
    echo ""
    
    print_header "Configuration Applied Successfully"
    echo ""
    print_info "Next steps:"
    echo "  1. Review generated files"
    echo "  2. Run: bash scripts/validate-prerequisites.sh"
    echo "  3. Run: bash scripts/deploy-all.sh"
    echo ""
}

# Run main function
main
