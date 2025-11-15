#!/bin/bash

# Trend App DevOps - Interactive Setup Wizard
# This script guides you through the configuration process

set -e

# Configuration file path
CONFIG_FILE="config.yaml"
CONFIG_EXAMPLE="config.yaml.example"

# Function to print messages
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

# Function to prompt for input with validation

prompt_input() {
    local prompt="$1"
    local default="$2"
    local validation_func="$3"
    local value=""
    
    while true; do
        if [ -n "$default" ]; then
            read -p "$prompt [$default]: " value
            value="${value:-$default}"
        else
            read -p "$prompt: " value
        fi
        
        # If validation function provided, validate input
        if [ -n "$validation_func" ]; then
            if $validation_func "$value"; then
                echo "$value"
                return 0
            fi
        else
            if [ -n "$value" ]; then
                echo "$value"
                return 0
            else
                print_error "Value cannot be empty"
            fi
        fi
    done
}

# Validation functions
validate_aws_account_id() {
    local account_id="$1"
    if [[ "$account_id" =~ ^[0-9]{12}$ ]]; then
        return 0
    else
        print_error "AWS Account ID must be exactly 12 digits"
        return 1
    fi
}

validate_aws_region() {
    local region="$1"
    local valid_regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "eu-west-1" "eu-west-2" "eu-central-1" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1")
    
    for valid_region in "${valid_regions[@]}"; do
        if [ "$region" = "$valid_region" ]; then
            return 0
        fi
    done
    
    print_error "Invalid AWS region. Valid regions: ${valid_regions[*]}"
    return 1
}

validate_cidr() {
    local cidr="$1"
    if [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 0
    else
        print_error "Invalid CIDR format. Example: 10.0.0.0/16"
        return 1
    fi
}

validate_instance_type() {
    local instance_type="$1"
    local valid_types=("t3.small" "t3.medium" "t3.large" "t3.xlarge" "t3.2xlarge")
    
    for valid_type in "${valid_types[@]}"; do
        if [ "$instance_type" = "$valid_type" ]; then
            return 0
        fi
    done
    
    print_error "Invalid instance type. Valid types: ${valid_types[*]}"
    return 1
}

validate_number() {
    local num="$1"
    if [[ "$num" =~ ^[0-9]+$ ]]; then
        return 0
    else
        print_error "Must be a number"
        return 1
    fi
}

validate_yes_no() {
    local answer="$1"
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [ "$answer" = "yes" ] || [ "$answer" = "y" ] || [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
        return 0
    else
        print_error "Please answer yes or no"
        return 1
    fi
}

# Function to check AWS credentials
check_aws_credentials() {
    print_info "Checking AWS credentials..."
    if aws sts get-caller-identity &>/dev/null; then
        local account_id=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS credentials valid (Account: $account_id)"
        echo "$account_id"
        return 0
    else
        print_error "AWS credentials not configured or invalid"
        print_info "Run: aws configure"
        return 1
    fi
}


# Cost estimation removed - this is for learning purposes

# Main wizard function
main() {
    clear
    print_header "Trend App DevOps - Setup Wizard"
    echo ""
    echo "This wizard will guide you through the configuration process."
    echo "You can press Ctrl+C at any time to exit."
    echo ""
    
    # Check required commands
    print_info "Checking required commands..."
    local commands_ok=true
    
    if ! check_command "aws" "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"; then
        commands_ok=false
    fi
    
    if [ "$commands_ok" = false ]; then
        print_warning "AWS CLI is recommended for automatic account detection"
        print_info "You can continue without it, but you'll need to enter values manually"
        read -p "Continue anyway? [y/N]: " continue_anyway
        continue_anyway=$(echo "$continue_anyway" | tr '[:upper:]' '[:lower:]')
        if [ "$continue_anyway" != "y" ] && [ "$continue_anyway" != "yes" ]; then
            print_info "Exiting. Please install AWS CLI and try again."
            exit 1
        fi
    fi
    echo ""
    
    # Check if config already exists
    if [ -f "$CONFIG_FILE" ]; then
        print_warning "Configuration file already exists: $CONFIG_FILE"
        read -p "Do you want to overwrite it? [y/N]: " overwrite
        overwrite=$(echo "$overwrite" | tr '[:upper:]' '[:lower:]')
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "yes" ]; then
            print_info "Exiting without changes"
            exit 0
        fi
    fi
    
    # Check if example config exists
    if [ ! -f "$CONFIG_EXAMPLE" ]; then
        print_error "Configuration example file not found: $CONFIG_EXAMPLE"
        exit 1
    fi
    
    echo ""
    print_header "Step 1: AWS Configuration"
    echo ""
    
    # Check AWS credentials
    detected_account_id=$(check_aws_credentials)
    if [ $? -eq 0 ]; then
        AWS_ACCOUNT_ID=$(prompt_input "AWS Account ID" "$detected_account_id" "validate_aws_account_id")
    else
        AWS_ACCOUNT_ID=$(prompt_input "AWS Account ID" "" "validate_aws_account_id")
    fi
    
    AWS_REGION=$(prompt_input "AWS Region" "us-east-1" "validate_aws_region")
    AWS_PROFILE=$(prompt_input "AWS CLI Profile" "default" "")
    
    echo ""
    print_header "Step 2: DockerHub Configuration"
    echo ""
    
    DOCKERHUB_USERNAME=$(prompt_input "DockerHub Username" "" "")
    DOCKERHUB_REPO=$(prompt_input "DockerHub Repository" "${DOCKERHUB_USERNAME}/trend-app" "")
    
    echo ""
    print_header "Step 3: Infrastructure Sizing"
    echo ""
    
    print_info "Jenkins will run on a dedicated EC2 instance"
    JENKINS_INSTANCE_TYPE=$(prompt_input "Jenkins Instance Type" "t3.medium" "validate_instance_type")
    
    echo ""
    print_info "EKS worker nodes will run your application"
    EKS_NODE_INSTANCE_TYPE=$(prompt_input "EKS Node Instance Type" "t3.medium" "validate_instance_type")
    EKS_NODE_DESIRED=$(prompt_input "Desired number of EKS nodes" "2" "validate_number")
    EKS_NODE_MIN=$(prompt_input "Minimum number of EKS nodes" "1" "validate_number")
    EKS_NODE_MAX=$(prompt_input "Maximum number of EKS nodes" "4" "validate_number")
    
    echo ""
    print_header "Step 4: Monitoring Configuration"
    echo ""
    
    MONITORING_ENABLED=$(prompt_input "Enable monitoring (Prometheus + Grafana)? [yes/no]" "yes" "validate_yes_no")
    MONITORING_ENABLED=$(echo "$MONITORING_ENABLED" | tr '[:upper:]' '[:lower:]')
    
    if [ "$MONITORING_ENABLED" = "yes" ] || [ "$MONITORING_ENABLED" = "y" ]; then
        GRAFANA_PASSWORD=$(prompt_input "Grafana admin password" "changeme123" "")
        MONITORING_ENABLED="true"
    else
        GRAFANA_PASSWORD="changeme123"
        MONITORING_ENABLED="false"
    fi
    

    echo ""
    print_header "Configuration Summary"
    echo ""
    echo "AWS Configuration:"
    echo "  Account ID: $AWS_ACCOUNT_ID"
    echo "  Region: $AWS_REGION"
    echo "  Profile: $AWS_PROFILE"
    echo ""
    echo "DockerHub Configuration:"
    echo "  Username: $DOCKERHUB_USERNAME"
    echo "  Repository: $DOCKERHUB_REPO"
    echo ""
    echo "Infrastructure:"
    echo "  Jenkins Instance: $JENKINS_INSTANCE_TYPE"
    echo "  EKS Node Instance: $EKS_NODE_INSTANCE_TYPE"
    echo "  EKS Node Count: $EKS_NODE_DESIRED (min: $EKS_NODE_MIN, max: $EKS_NODE_MAX)"
    echo ""
    echo "Monitoring:"
    echo "  Enabled: $MONITORING_ENABLED"
    if [ "$MONITORING_ENABLED" = "true" ]; then
        echo "  Grafana Password: ********"
    fi
    echo ""
    
    read -p "Does this look correct? [Y/n]: " confirm
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
    if [ "$confirm" = "n" ] || [ "$confirm" = "no" ]; then
        print_info "Configuration cancelled. Run the wizard again to start over."
        exit 0
    fi
    
    echo ""
    print_info "Generating configuration file..."
    
    # Generate config.yaml from template
    cp "$CONFIG_EXAMPLE" "$CONFIG_FILE"
    
    # Replace placeholders using sed (Windows-compatible)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows (Git Bash)
        sed -i "s/account_id: \"123456789012\"/account_id: \"$AWS_ACCOUNT_ID\"/" "$CONFIG_FILE"
        sed -i "s/region: \"us-east-1\"/region: \"$AWS_REGION\"/" "$CONFIG_FILE"
        sed -i "s/profile: \"default\"/profile: \"$AWS_PROFILE\"/" "$CONFIG_FILE"
        sed -i "s/username: \"yourusername\"/username: \"$DOCKERHUB_USERNAME\"/" "$CONFIG_FILE"
        sed -i "s|repository: \"yourusername/trend-app\"|repository: \"$DOCKERHUB_REPO\"|" "$CONFIG_FILE"
        sed -i "s/instance_type: \"t3.medium\"/instance_type: \"$JENKINS_INSTANCE_TYPE\"/" "$CONFIG_FILE" | head -1
        sed -i "s/instance_type: \"t3.medium\"/instance_type: \"$EKS_NODE_INSTANCE_TYPE\"/" "$CONFIG_FILE"
        sed -i "s/desired_size: 2/desired_size: $EKS_NODE_DESIRED/" "$CONFIG_FILE"
        sed -i "s/min_size: 1/min_size: $EKS_NODE_MIN/" "$CONFIG_FILE"
        sed -i "s/max_size: 4/max_size: $EKS_NODE_MAX/" "$CONFIG_FILE"
        sed -i "s/enabled: true/enabled: $MONITORING_ENABLED/" "$CONFIG_FILE" | head -1
        sed -i "s/admin_password: \"changeme123\"/admin_password: \"$GRAFANA_PASSWORD\"/" "$CONFIG_FILE"
    else
        # Linux/Mac
        sed -i.bak "s/account_id: \"123456789012\"/account_id: \"$AWS_ACCOUNT_ID\"/" "$CONFIG_FILE"
        sed -i.bak "s/region: \"us-east-1\"/region: \"$AWS_REGION\"/" "$CONFIG_FILE"
        sed -i.bak "s/profile: \"default\"/profile: \"$AWS_PROFILE\"/" "$CONFIG_FILE"
        sed -i.bak "s/username: \"yourusername\"/username: \"$DOCKERHUB_USERNAME\"/" "$CONFIG_FILE"
        sed -i.bak "s|repository: \"yourusername/trend-app\"|repository: \"$DOCKERHUB_REPO\"|" "$CONFIG_FILE"
        
        # For Jenkins instance type (first occurrence)
        awk '/jenkins:/{flag=1} flag && /instance_type:/{if(!done){sub(/t3\.medium/, "'"$JENKINS_INSTANCE_TYPE"'"); done=1}} 1' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        # For EKS node instance type (second occurrence)
        awk '/nodes:/{flag=1} flag && /instance_type:/{if(!done){sub(/t3\.medium/, "'"$EKS_NODE_INSTANCE_TYPE"'"); done=1}} 1' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        sed -i.bak "s/desired_size: 2/desired_size: $EKS_NODE_DESIRED/" "$CONFIG_FILE"
        sed -i.bak "s/min_size: 1/min_size: $EKS_NODE_MIN/" "$CONFIG_FILE"
        sed -i.bak "s/max_size: 4/max_size: $EKS_NODE_MAX/" "$CONFIG_FILE"
        
        # For monitoring enabled (first occurrence)
        awk '/monitoring:/{flag=1} flag && /enabled:/{if(!done){sub(/true/, "'"$MONITORING_ENABLED"'"); done=1}} 1' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        sed -i.bak "s/admin_password: \"changeme123\"/admin_password: \"$GRAFANA_PASSWORD\"/" "$CONFIG_FILE"
        
        # Remove backup files
        rm -f "$CONFIG_FILE.bak"
    fi
    
    print_success "Configuration file created: $CONFIG_FILE"
    echo ""
    
    print_header "Next Steps"
    echo ""
    echo "1. Review the configuration file: $CONFIG_FILE"
    echo "2. Run prerequisites validation: ./scripts/validate-prerequisites.sh"
    echo "3. Deploy infrastructure: ./scripts/deploy-all.sh"
    echo ""
    print_success "Setup wizard completed successfully!"
}

# Run main function
main
