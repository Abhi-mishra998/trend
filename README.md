# 🚀 Trend App - Production-Grade AWS EKS Deployment with Jenkins CI/CD

> **Enterprise-level DevOps implementation**: Automated React application deployment to AWS EKS using Infrastructure as Code, containerization, and continuous delivery pipelines.

[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9.8-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture Diagram](#-architecture-diagram)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Quick Start Guide](#-quick-start-guide)
- [Detailed Setup Instructions](#-detailed-setup-instructions)
- [Jenkins Pipeline Configuration](#-jenkins-pipeline-configuration)
- [GitHub Webhook Integration](#-github-webhook-integration)
- [Kubernetes Resources](#-kubernetes-resources)
- [Monitoring & Observability](#-monitoring--observability)
- [Command Reference](#-command-reference)
- [Troubleshooting](#-troubleshooting)
- [Cost Optimization](#-cost-optimization)
- [Security Best Practices](#-security-best-practices)
- [Project Submission](#-project-submission)
- [Cleanup & Teardown](#-cleanup--teardown)

---

## 🎯 Project Overview

### What This Project Does

This is a **complete end-to-end DevOps implementation** that demonstrates:

1. **Infrastructure as Code (IaC)**: Provisioning AWS resources using Terraform
2. **Containerization**: Packaging React applications with Docker
3. **Orchestration**: Managing containers with Kubernetes on AWS EKS
4. **CI/CD Automation**: Automated build, test, and deployment pipelines with Jenkins
5. **GitOps Workflow**: Source control integration with GitHub webhooks
6. **Monitoring**: Prometheus and Grafana for observability

### Application Details

- **Source Repository**: [Trend App](https://github.com/Vennilavan12/Trend.git)
- **Framework**: React (Modern JavaScript Frontend)
- **Deployment Target**: AWS Elastic Kubernetes Service (EKS)
- **Container Registry**: DockerHub
- **CI/CD Tool**: Jenkins (Self-hosted on EC2)

### Infrastructure Specifications

| Component | Configuration | Purpose |
|-----------|--------------|---------|
| **EKS Cluster** | Kubernetes v1.31 | Container orchestration platform |
| **Worker Nodes** | 3x t3.large (2 vCPU, 8GB RAM) | Application workload execution |
| **Jenkins Server** | EC2 t3.medium | CI/CD automation engine |
| **VPC** | Public/Private subnets | Network isolation and security |
| **Load Balancer** | AWS NLB | External traffic distribution |
| **Region** | ap-south-1 (Mumbai) | AWS datacenter location |

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                    (Source Code Management)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │ Webhook Trigger (on git push)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Jenkins EC2 Instance                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Pipeline Stages:                                         │  │
│  │  1. Checkout Code    → Clone from GitHub                 │  │
│  │  2. Install Deps     → npm install                       │  │
│  │  3. Build App        → npm run build                     │  │
│  │  4. Docker Build     → Create container image            │  │
│  │  5. Push to DockerHub → Upload to registry               │  │
│  │  6. Deploy to K8s    → Update EKS deployment             │  │
│  │  7. Verify           → Health checks                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │ kubectl apply
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AWS EKS Cluster (Kubernetes)                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Worker Node 1  │  │  Worker Node 2  │  │  Worker Node 3  │ │
│  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │ │
│  │  │  Pod 1    │  │  │  │  Pod 2    │  │  │  │  Pod 3    │  │ │
│  │  │ Trend App │  │  │  │ Trend App │  │  │  │ Trend App │  │ │
│  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                             │                                    │
│                    ┌────────▼─────────┐                         │
│                    │  LoadBalancer    │                         │
│                    │  Service (NLB)   │                         │
│                    └────────┬─────────┘                         │
└─────────────────────────────┼─────────────────────────────────┘
                              │
                              ▼
                      ┌───────────────┐
                      │  End Users    │
                      │  (Internet)   │
                      └───────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     Monitoring Stack (Optional)                  │
│  ┌──────────────┐         ┌──────────────┐                     │
│  │  Prometheus  │────────▶│   Grafana    │                     │
│  │  (Metrics)   │         │ (Dashboards) │                     │
│  └──────────────┘         └──────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💻 Technology Stack

### Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Terraform** | 1.9.8 | Infrastructure provisioning and management |
| **Kubernetes** | 1.31 | Container orchestration and scaling |
| **Docker** | Latest | Application containerization |
| **Jenkins** | Latest LTS | Continuous Integration/Deployment |
| **AWS EKS** | 1.31 | Managed Kubernetes service |
| **React** | Latest | Frontend application framework |
| **Node.js** | LTS | JavaScript runtime for building |

### DevOps Tools

- **kubectl**: Kubernetes command-line tool (cluster interaction)
- **Helm**: Kubernetes package manager (chart deployments)
- **AWS CLI**: Amazon Web Services command-line interface
- **Git**: Version control system

### Monitoring & Observability

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **CloudWatch**: AWS native monitoring (EKS logs)

---

## 📋 Prerequisites

### Required Accounts & Access

1. **AWS Account**
   - IAM user with Administrator or EKS/EC2/VPC permissions
   - Access Key ID and Secret Access Key
   - Region: ap-south-1 (or your preferred region)

2. **DockerHub Account**
   - Username and password for container registry
   - Repository created (e.g., `your-username/trend-app`)

3. **GitHub Account**
   - Repository forked or cloned
   - Personal Access Token (for webhook authentication)

### Local Development Tools

```bash
# Required installations on your local machine
- Git (version control)
- AWS CLI v2 (cloud resource management)
- Terraform v1.9.8+ (infrastructure automation)
- kubectl (Kubernetes cluster management)
- Docker (optional, for local testing)
```

### Knowledge Prerequisites

- Basic understanding of Linux commands
- Familiarity with Git workflows
- AWS fundamentals (VPC, EC2, IAM)
- Docker container concepts
- Kubernetes basics (Pods, Deployments, Services)

---

## 🚀 Quick Start Guide

### 5-Minute Deployment (For Experienced Users)

```bash
# Step 1: Clone the repository
git clone https://github.com/Abhi-mishra998/trend.git
cd trend

# Step 2: Configure AWS credentials
aws configure
# Enter your AWS Access Key, Secret Key, and region (ap-south-1)

# Step 3: Update Terraform variables
cd infrastructure
nano variables.tf  # Edit with your DockerHub repo and AWS settings

# Step 4: Deploy infrastructure (takes ~15-20 minutes)
terraform init      # Initialize Terraform providers
terraform plan      # Preview changes
terraform apply -auto-approve  # Create AWS resources

# Step 5: Configure kubectl to access EKS
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1

# Step 6: Get Jenkins URL and configure pipeline
terraform output jenkins_url
# Access Jenkins at http://<output-url>:8080

# Step 7: Verify deployment
kubectl get nodes               # Check EKS nodes are ready
kubectl get pods -n trend-app   # Check application pods
kubectl get svc -n trend-app    # Get LoadBalancer URL
```

---

## 📚 Detailed Setup Instructions

### Phase 1: Environment Preparation

#### 1.1 Install Terraform

```bash
# Download Terraform 1.9.8 for Linux AMD64 architecture
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
# Purpose: Downloads the specific Terraform version binary package

# Install unzip utility if not present
sudo apt install unzip -y
# Purpose: Provides the unzip command to extract .zip archives

# Extract the Terraform binary from the downloaded archive
unzip terraform_1.9.8_linux_amd64.zip
# Purpose: Decompresses the zip file to get the terraform executable

# Move Terraform to system PATH for global access
sudo mv terraform /usr/local/bin/
# Purpose: Makes 'terraform' command available from any directory

# Verify successful installation
terraform -v
# Purpose: Confirms Terraform is installed and displays version number
# Expected output: Terraform v1.9.8
```

#### 1.2 Install kubectl (Kubernetes CLI)

```bash
# Download the latest stable version of kubectl for Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Purpose: Fetches the most recent stable kubectl binary from Kubernetes release server
# -L follows redirects, -O saves file with original name

# Make the kubectl binary executable
chmod +x kubectl
# Purpose: Adds execute permission so the file can be run as a program

# Move kubectl to system PATH for system-wide access
sudo mv kubectl /usr/local/bin/
# Purpose: Allows running 'kubectl' command from any terminal location

# Verify kubectl installation and version
kubectl version --client
# Purpose: Displays installed kubectl version without connecting to a cluster
# Expected output: Client Version: v1.x.x
```

#### 1.3 Configure AWS CLI

```bash
# Run interactive AWS configuration wizard
aws configure
# Purpose: Sets up AWS credentials and default region for CLI operations
# You'll be prompted to enter:
#   - AWS Access Key ID: Your IAM user access key
#   - AWS Secret Access Key: Your IAM user secret key
#   - Default region: ap-south-1 (Mumbai)
#   - Default output format: json (recommended)

# Verify AWS configuration by checking caller identity
aws sts get-caller-identity
# Purpose: Confirms AWS credentials are valid and shows your account details
# Expected output: JSON with UserId, Account, and ARN
```

### Phase 2: Infrastructure Deployment

#### 2.1 Clone and Configure Repository

```bash
# Clone the Trend App repository from GitHub
git clone https://github.com/Abhi-mishra998/trend.git
# Purpose: Creates a local copy of the project with all code and configuration files

# Change directory to the cloned repository
cd trend
# Purpose: Navigates into the project root directory

# Navigate to infrastructure folder containing Terraform code
cd infrastructure
# Purpose: Access the directory with main.tf, variables.tf, and module files
```

#### 2.2 Terraform Configuration

Edit `variables.tf` with your specific values:

```hcl
# Example variables.tf configuration
variable "dockerhub_username" {
  default = "your-dockerhub-username"  # Replace with your DockerHub username
}

variable "dockerhub_repo" {
  default = "trend-app"  # Your Docker repository name
}

variable "aws_region" {
  default = "ap-south-1"  # AWS region for deployment
}

variable "cluster_name" {
  default = "trend-app-eks-by-abhi"  # EKS cluster identifier
}
```

#### 2.3 Deploy Infrastructure with Terraform

```bash
# Initialize Terraform working directory
terraform init
# Purpose: Downloads required provider plugins (AWS, Kubernetes) and initializes backend
# Creates .terraform directory with provider binaries
# Expected output: "Terraform has been successfully initialized!"

# Generate and review execution plan
terraform plan
# Purpose: Shows what resources will be created/modified/destroyed
# Performs validation checks without making actual changes
# Review output carefully: ~50+ resources will be created (VPC, EKS, EC2, etc.)

# Apply the configuration and create AWS resources
terraform apply -auto-approve
# Purpose: Creates all infrastructure defined in Terraform files
# -auto-approve flag skips manual confirmation prompt
# Duration: 15-20 minutes (EKS cluster creation takes longest)
# Creates: VPC, subnets, security groups, EKS cluster, node groups, Jenkins EC2

# Save important outputs for later use
terraform output jenkins_url > jenkins_url.txt
# Purpose: Extracts Jenkins public DNS/IP and saves to file
# Use this URL to access Jenkins: http://<output>:8080

terraform output eks_cluster_name
# Purpose: Displays the name of the created EKS cluster
# Needed for kubectl configuration
```

### Phase 3: Kubernetes Configuration

#### 3.1 Configure kubectl for EKS Access

```bash
# Update kubeconfig to connect kubectl to your EKS cluster
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1
# Purpose: Downloads cluster credentials and adds them to ~/.kube/config
# Configures kubectl to communicate with your specific EKS cluster
# Creates context and sets it as current
# Expected output: "Added new context arn:aws:eks:ap-south-1:..."

# Verify cluster connectivity by listing nodes
kubectl get nodes
# Purpose: Tests connection and shows all worker nodes in the cluster
# Expected output: 3 nodes in "Ready" status with EKS-optimized AMI
# Shows: NAME, STATUS, ROLES, AGE, VERSION

# Get detailed information about nodes including IP addresses
kubectl get nodes -o wide
# Purpose: Extended node information with internal/external IPs, OS, kernel
# Useful for troubleshooting network issues
```

#### 3.2 Deploy Application to Kubernetes

```bash
# Navigate to Kubernetes manifests directory
cd Trend-by-Abhi
# Purpose: Access folder containing deployment.yaml, service.yaml, etc.

# Apply all Kubernetes resource definitions
kubectl apply -f k8s/
# Purpose: Creates/updates all resources defined in k8s/ directory
# Creates: Namespace, Deployment, Service, HPA, NetworkPolicy, ResourceQuota
# Expected output: Multiple "created" or "configured" messages

# Watch deployment rollout progress in real-time
kubectl rollout status deployment/trend-app-deployment -n trend-app
# Purpose: Monitors deployment until all pods are running
# Shows progress: "Waiting for deployment to roll out: X of 3 updated replicas..."
# Completes when: "deployment successfully rolled out"

# Verify all pods are running and healthy
kubectl get pods -n trend-app
# Purpose: Lists all application pods with their status
# Expected output: 3 pods (replicas) in "Running" state with "1/1 READY"

# Get service details including LoadBalancer external IP
kubectl get svc -n trend-app
# Purpose: Shows service configuration and external access URL
# Wait for EXTERNAL-IP to change from "<pending>" to actual AWS NLB DNS name
# This URL is your application's public endpoint

# Watch service until LoadBalancer is provisioned (can take 2-3 minutes)
kubectl get svc -n trend-app -w
# Purpose: Continuously watches service status updates
# -w flag enables watch mode (press Ctrl+C to exit)
# Wait until EXTERNAL-IP shows AWS NLB DNS name
```

#### 3.3 Verify Deployment

```bash
# Get detailed service information including events
kubectl describe svc trend-app-service -n trend-app
# Purpose: Shows comprehensive service details, endpoints, and events
# Check for "LoadBalancer Ingress" field with NLB DNS name
# Look for successful events: "EnsuringLoadBalancer", "EnsuredLoadBalancer"

# Check recent events in the namespace for troubleshooting
kubectl get events -n trend-app --sort-by=.metadata.creationTimestamp | tail -20
# Purpose: Shows last 20 events chronologically for debugging
# --sort-by sorts by creation time (newest last)
# tail -20 shows only the most recent 20 events

# View logs from all application pods
kubectl logs -l app=trend-app -n trend-app
# Purpose: Displays application logs from all pods matching label selector
# -l flag filters pods by label (app=trend-app)
# Useful for debugging application issues

# Scale deployment to test horizontal scaling
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app
# Purpose: Changes number of pod replicas from 3 to 5
# Tests Kubernetes' ability to scale your application
# Verify with: kubectl get pods -n trend-app (should show 5 pods)

# Scale back down to original replica count
kubectl scale deployment trend-app-deployment --replicas=3 -n trend-app
# Purpose: Returns to original 3-replica configuration
# Demonstrates scaling down capability
```

---

## 🔧 Jenkins Pipeline Configuration

### Jenkins Installation and Initial Setup

#### 4.1 Access Jenkins

```bash
# Get Jenkins URL from Terraform output
terraform output jenkins_url
# Purpose: Retrieves the public DNS/IP of Jenkins EC2 instance
# Example output: ec2-13-234-56-789.ap-south-1.compute.amazonaws.com

# Open in browser: http://<jenkins-url>:8080
# Initial admin password is located at: /var/lib/jenkins/secrets/initialAdminPassword
```

#### 4.2 Install Required Jenkins Plugins

Navigate to: **Manage Jenkins → Manage Plugins → Available**

Install these plugins:

1. **Docker Pipeline**
   - Purpose: Enables Docker commands in Jenkins pipeline
   - Features: docker.build(), docker.push(), docker.image()

2. **Kubernetes CLI**
   - Purpose: Allows kubectl commands in pipeline
   - Features: Execute kubectl apply, get, delete commands

3. **GitHub Integration**
   - Purpose: Connects Jenkins with GitHub repositories
   - Features: Webhook triggers, branch detection, commit status

4. **Credentials Binding**
   - Purpose: Securely injects credentials into pipeline
   - Features: Environment variable injection, masked passwords

5. **Pipeline Utility Steps**
   - Purpose: Provides additional pipeline helper functions
   - Features: File manipulation, JSON parsing

#### 4.3 Configure Jenkins Credentials

Navigate to: **Manage Jenkins → Manage Credentials → Global → Add Credentials**

**Credential 1: DockerHub**
```
Kind: Username with password
Scope: Global
Username: your-dockerhub-username
Password: your-dockerhub-password
ID: dockerhub-creds
Description: DockerHub Container Registry Access
```

**Credential 2: Kubernetes Config**
```
Kind: Secret file
Scope: Global
File: Upload your ~/.kube/config file
ID: kubeconfig-creds
Description: EKS Cluster Authentication
```

**Credential 3: GitHub Token (for webhooks)**
```
Kind: Secret text
Scope: Global
Secret: your-github-personal-access-token
ID: github-token
Description: GitHub API Access for Webhooks
```

### Jenkins Pipeline Job Creation

#### 4.4 Create Pipeline Job

1. **Jenkins Dashboard → New Item**
2. **Enter job name**: `trend-app-deployment`
3. **Select**: Pipeline
4. **Click**: OK

#### 4.5 Configure Pipeline Job

**General Settings:**
- ☑️ GitHub project: `https://github.com/Abhi-mishra998/trend`
- ☑️ Discard old builds: Keep last 10 builds

**Build Triggers:**
- ☑️ GitHub hook trigger for GITScm polling
  - Purpose: Triggers build automatically when code is pushed to GitHub

**Pipeline Configuration:**
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: `https://github.com/Abhi-mishra998/trend.git`
- Credentials: (none for public repo)
- Branch: `*/main`
- Script Path: `Jenkinsfile`

**Click**: Save

### Understanding the Jenkinsfile

The `Jenkinsfile` defines the complete CI/CD pipeline:

```groovy
pipeline {
    agent any  // Run on any available Jenkins agent
    
    environment {
        // Environment variables available to all stages
        DOCKERHUB_REPO = 'abhimishra/trend-app'  // Docker registry path
        IMAGE_TAG = "${BUILD_NUMBER}"  // Unique tag per build (1, 2, 3...)
        NAMESPACE = 'trend-app'  // Kubernetes namespace for deployment
    }
    
    stages {
        stage('Checkout Code') {
            // Purpose: Clone latest code from GitHub repository
            steps {
                git branch: 'main', 
                    url: 'https://github.com/Abhi-mishra998/trend.git'
            }
        }
        
        stage('Install Dependencies') {
            // Purpose: Download Node.js packages required for React app
            steps {
                sh 'npm install'  // Reads package.json and installs modules
            }
        }
        
        stage('Build Application') {
            // Purpose: Compile React app into static files (HTML/JS/CSS)
            steps {
                sh 'npm run build'  // Creates optimized production build in /dist
            }
        }
        
        stage('Build Docker Image') {
            // Purpose: Package application into Docker container image
            steps {
                script {
                    docker.build("${DOCKERHUB_REPO}:${IMAGE_TAG}")
                    // Executes: docker build -t abhimishra/trend-app:BUILD_NUMBER .
                }
            }
        }
        
        stage('Push to DockerHub') {
            // Purpose: Upload container image to Docker registry
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-creds') {
                        // Authenticates with DockerHub using stored credentials
                        docker.image("${DOCKERHUB_REPO}:${IMAGE_TAG}").push()
                        docker.image("${DOCKERHUB_REPO}:${IMAGE_TAG}").push('latest')
                        // Pushes both versioned tag and 'latest' tag
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            // Purpose: Update running application on EKS cluster
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')]) {
                    // Injects kubeconfig file for cluster authentication
                    sh """
                        kubectl set image deployment/trend-app-deployment \\
                            trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} \\
                            -n ${NAMESPACE}
                        # Updates deployment with new image version
                        
                        kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE}
                        # Waits until all pods are updated and running
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            // Purpose: Confirm deployment succeeded and app is healthy
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl get pods -n ${NAMESPACE}
                        # Lists all pods to verify they're running
                        
                        kubectl get svc -n ${NAMESPACE}
                        # Shows service and LoadBalancer URL
                    """
                }
            }
        }
    }
    
    post {
        // Actions to perform after pipeline completes
        success {
            echo '✅ Deployment successful!'
            // In production, send notification (Slack/email)
        }
        failure {
            echo '❌ Deployment failed!'
            // In production, alert team about failure
        }
    }
}
```

---

## 🔗 GitHub Webhook Integration

### Complete Webhook Setup Guide

#### Step 1: Retrieve Jenkins URL

```bash
# Get Jenkins public URL from Terraform
cd infrastructure
terraform output jenkins_url
# Purpose: Displays Jenkins EC2 public DNS or IP address
# Example output: ec2-13-234-56-789.ap-south-1.compute.amazonaws.com

# Test Jenkins accessibility from internet
curl http://<jenkins-url>:8080
# Purpose: Verifies Jenkins is reachable externally
# Expected: HTML response with Jenkins login page
```

#### Step 2: Configure GitHub Webhook

**2.1 Navigate to GitHub Repository Settings**
1. Go to: `https://github.com/Abhi-mishra998/trend`
2. Click: **Settings** (requires admin access)
3. Click: **Webhooks** (left sidebar)
4. Click: **Add webhook** (green button)

**2.2 Webhook Configuration**

| Field | Value | Purpose |
|-------|-------|---------|
| **Payload URL** | `http://YOUR_JENKINS_URL:8080/github-webhook/` | Endpoint for GitHub to send events |
| **Content type** | `application/json` | Data format for webhook payload |
| **Secret** | (optional but recommended) | Validates webhook authenticity |
| **SSL verification** | Enable (if using HTTPS) | Security for encrypted connections |
| **Events** | ☑️ Just the push event | Trigger only on git push |
| **Active** | ☑️ Checked | Enable webhook immediately |

**Important Notes:**
- Must end with `/github-webhook/` (exact path required)
- Port 8080 must be accessible (check security group)
- Use HTTP for now (HTTPS requires SSL certificate setup)

#### Step 3: Configure Jenkins for Webhooks

**3.1 Install GitHub Plugin**
```
Manage Jenkins → Manage Plugins → Available
Search: "GitHub Integration Plugin"
Install and restart Jenkins
```

**3.2 Configure GitHub in Jenkins**
```
Manage Jenkins → Configure System
Scroll to: "GitHub" section
Click: Add GitHub Server
  - Name: GitHub
  - API URL: https://api.github.com (default)
  - Credentials: Add → Secret text → Your GitHub Personal Access Token
  - Test connection: Click "Test connection" (should show "Verified")
```

**3.3 Update Pipeline Job for Webhook**
```
Pipeline Job → Configure
Build Triggers section:
  ☑️ GitHub hook trigger for GITScm polling
Save
```

#### Step 4: Test Webhook Integration

**4.1 Make a Test Commit**
```bash
# Navigate to your local repository
cd trend

# Make a small change to trigger build
echo "# Test webhook" >> README.md
# Purpose: Adds a comment to README to create a change

# Stage changes for commit
git add README.md
# Purpose: Marks README.md for inclusion in next commit

# Create commit with descriptive message
git commit -m "test: verify webhook trigger"
# Purpose: Records changes in Git history

# Push changes to GitHub
git push origin main
# Purpose: Uploads commit to remote repository, triggering webhook
```

**4.2 Verify Build Triggered**
```bash
# Check Jenkins immediately after push
# Jenkins Dashboard should show:
#   - New build started automatically
#   - Build number incremented
#   - "Started by GitHub push" in build logs
```

**4.3 Verify Webhook Delivery in GitHub**
```
Repository → Settings → Webhooks → Your webhook
Click on webhook URL
Scroll to: "Recent Deliveries"
Latest delivery should show:
  - Green checkmark (successful)
  - Response code: 200
  - Response body: Triggered jobs (if successful)
```

### Webhook Troubleshooting

#### Common Issues and Solutions

**Issue 1: Webhook Shows 403 Forbidden**
```bash
# Problem: Jenkins CSRF protection blocking webhook
# Solution: Configure CSRF exemption
Manage Jenkins → Configure Global Security
CSRF Protection → Add /github-webhook/ to exclusion list
```

**Issue 2: Webhook Connection Timeout**
```bash
# Problem: Jenkins not accessible from internet
# Check security group allows port 8080:
aws ec2 describe-security-groups --group-ids <jenkins-sg-id>
# Add rule if missing:
aws ec2 authorize-security-group-ingress \
  --group-id <jenkins-sg-id> \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

**Issue 3: Build Not Triggering**
```bash
# Problem: GitHub plugin not configured
# Verify plugin installation:
curl -s http://jenkins-url:8080/pluginManager/api/json?depth=1 | grep -i github
# Should show: github, github-branch-source plugins

# Check Jenkins logs for webhook reception:
tail -f /var/log/jenkins/jenkins.log | grep webhook
```

---

## ☸️ Kubernetes Resources Explained

### Resource Manifests Overview

#### 1. Namespace (namespace.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: trend-app
# Purpose: Logical isolation for all app resources
# Benefits: Resource quotas, network policies, RBAC
```

---

## 🔧 Command Reference & Troubleshooting

### Essential Commands for Daily Operations

#### AWS EKS Cluster Management

```bash
# Get EKS cluster details and verify configuration
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1
# Purpose: Shows cluster status, VPC config, endpoint, and Kubernetes version
# Use case: Verify cluster is active before deploying applications

# Update kubeconfig to connect to EKS cluster
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1
# Purpose: Configures kubectl to authenticate with your EKS cluster
# Creates/updates ~/.kube/config with cluster credentials

# List all EKS clusters in your region
aws eks list-clusters --region ap-south-1
# Purpose: Shows all EKS clusters to verify cluster name
# Useful when managing multiple clusters

# Describe cluster's VPC and subnet configuration
aws eks describe-cluster --name trend-app-eks-by-abhi --query "cluster.resourcesVpcConfig" --output json
# Purpose: Shows VPC ID, subnet IDs, security group IDs
# Critical for troubleshooting network connectivity issues
```

#### Subnet and Network Configuration

```bash
# List all subnets in your VPC with detailed information
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-083ba4e38e3114ac2" --query "Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,Tags:Tags}" --output json
# Purpose: Shows subnet IDs, availability zones, and tags
# Use case: Verify LoadBalancer has access to correct subnets

# Display subnets in table format for better readability
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-083ba4e38e3114ac2" --query "Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,Tags:Tags}" --output table
# Purpose: Human-readable subnet information
# Easier to identify public vs private subnets by tags

# Get specific subnet details by subnet ID
aws ec2 describe-subnets --subnet-ids subnet-016f079baf283d82c --query "Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,Tags:Tags}" --output json
# Purpose: Deep dive into single subnet configuration
# Check MapPublicIpOnLaunch, CIDR block, route table association
```

#### Kubernetes Cluster Operations

```bash
# List all nodes in the cluster with detailed information
kubectl get nodes -o wide
# Purpose: Shows node names, status, roles, age, version, internal/external IPs
# Use case: Verify all 3 worker nodes are in 'Ready' state

# Get basic node information
kubectl get nodes
# Purpose: Quick check of node health and Kubernetes version
# Output: Node name, status (Ready/NotReady), role, age

# Check cluster events for troubleshooting
kubectl get events -n trend-app --sort-by=.metadata.creationTimestamp
# Purpose: Shows all events in chronological order
# Critical for debugging deployment, pod, or service issues

# View only recent events (last 20)
kubectl get events -n trend-app --sort-by=.metadata.creationTimestamp | tail -20
# Purpose: Focus on most recent cluster activities
# Faster troubleshooting by filtering noise from old events
```

#### Application Deployment and Management

```bash
# Apply all Kubernetes manifests from k8s directory
cd Trend-by-Abhi && kubectl apply -f k8s/
# Purpose: Creates/updates Deployment, Service, HPA, NetworkPolicy
# Single command to deploy entire application stack

# Watch deployment rollout progress in real-time
kubectl rollout status deployment/trend-app-deployment -n trend-app
# Purpose: Monitors pod creation and readiness during updates
# Blocks until rollout completes or fails (useful in CI/CD)

# Scale deployment to handle more traffic
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app
# Purpose: Increases pod count from 3 to 5 for higher capacity
# Horizontal scaling without downtime

# Scale back to original replica count
kubectl scale deployment trend-app-deployment --replicas=1 -n trend-app
# Purpose: Reduces resource usage during low traffic periods
# Cost optimization by running fewer pods
```

#### Service and LoadBalancer Troubleshooting

```bash
# Get all services in trend-app namespace
cd Trend-by-Abhi && kubectl get svc -n trend-app
# Purpose: Shows service type, cluster IP, external IP, ports
# Check if LoadBalancer external IP is assigned (not <pending>)

# Watch service status until LoadBalancer is provisioned
cd Trend-by-Abhi && kubectl get svc -n trend-app -w
# Purpose: Continuously monitors service updates in real-time
# Wait for EXTERNAL-IP to change from <pending> to AWS NLB DNS
# Exit with Ctrl+C once LoadBalancer is ready

# Get detailed service information including events
cd Trend-by-Abhi && kubectl describe svc trend-app-service -n trend-app
# Purpose: Shows service configuration, endpoints, events, annotations
# Check for "EnsuredLoadBalancer" event indicating successful NLB creation
# Verify "LoadBalancer Ingress" field has AWS NLB DNS name

# Describe specific service by name
kubectl describe svc trend-app-service -n trend-app
# Purpose: Troubleshoot service issues (no endpoints, wrong selector)
# Look for "FailedToEnsureLoadBalancer" errors
```

#### Pod Debugging and Logs

```bash
# List all pods in trend-app namespace
kubectl get pods -n trend-app
# Purpose: Shows pod names, ready status (1/1), status (Running), restarts
# Quick health check of application instances

# View logs from all pods with label app=trend-app
kubectl logs -l app=trend-app -n trend-app
# Purpose: Aggregated logs from all application pods
# Useful for debugging application errors across replicas

# Describe a specific pod for detailed information
kubectl describe pod <pod-name> -n trend-app
# Purpose: Shows pod events, container status, resource usage, volumes
# Critical for debugging CrashLoopBackOff or ImagePullBackOff errors

# Execute commands inside a running pod
kubectl exec -it <pod-name> -n trend-app -- /bin/sh
# Purpose: Interactive shell access to pod for live debugging
# Test connectivity, check files, verify environment variables
```

#### Local Port Forwarding for Testing

```bash
# Forward local port 8080 to application service port 80
cd Trend-by-Abhi && kubectl port-forward svc/trend-app-service -n trend-app 8080:80
# Purpose: Access service locally without LoadBalancer (testing)
# Open browser to http://localhost:8080 to view application
# Use case: Test before LoadBalancer is provisioned

# Forward to pod directly (bypassing service)
kubectl port-forward pod/<pod-name> -n trend-app 3000:3000
# Purpose: Access specific pod's container port directly
# Useful for debugging single pod issues

# Port forward and run in background
kubectl port-forward svc/trend-app-service 8080:80 -n trend-app &
# Purpose: Keeps port-forward running while using terminal
# Access application while executing other kubectl commands
```

#### Infrastructure Verification

```bash
# Get EKS cluster name to verify correct cluster
cd Trend-by-Abhi && aws eks describe-cluster --name trend-app-eks-by-abhi --query "cluster.name" --output text
# Purpose: Confirms you're working with correct cluster
# Returns: trend-app-eks-by-abhi

# View Jenkins URL from Terraform output
terraform output jenkins_url
# Purpose: Retrieves Jenkins EC2 public DNS for browser access
# Use: http://<output>:8080 to access Jenkins UI

# Get all Terraform outputs
terraform output
# Purpose: Shows all exported values (Jenkins URL, cluster name, VPC ID)
# Useful for getting multiple configuration details at once
```

#### Monitoring and Health Checks

```bash
# Check deployment logs from Jenkins
cat logs/deployment-*.log
# Purpose: Review Jenkins pipeline execution logs
# Troubleshoot build failures, Docker errors, kubectl failures

# View MetalLB controller status (if using MetalLB)
kubectl describe pod controller-bf6bd556d-jfw67 -n metallb-system
# Purpose: Debug LoadBalancer controller issues
# Check for image pull errors, configuration problems

# Get all resources in namespace
kubectl get all -n trend-app
# Purpose: Comprehensive view of pods, services, deployments, replicasets
# Quick overview of entire application stack

# Check resource usage of pods
kubectl top pods -n trend-app
# Purpose: Shows CPU and memory consumption per pod
# Requires metrics-server to be installed in cluster

# View deployment history and revisions
kubectl rollout history deployment/trend-app-deployment -n trend-app
# Purpose: Shows all deployment revisions and change causes
# Useful for rollback to previous working version
```

---

## 🚨 Critical Troubleshooting Guide

### Issue 1: LoadBalancer Stuck in Pending State

**Symptoms:**
- `kubectl get svc` shows `<pending>` for EXTERNAL-IP
- Service not accessible from internet
- LoadBalancer not created in AWS Console

**Root Cause:** Missing IAM permissions for AWS Load Balancer Controller

**Solution:**

```bash
# Step 1: Verify IAM policy exists
aws iam list-policies --query 'Policies[?PolicyName==`AWSLoadBalancerControllerIAMPolicy`]'
# Purpose: Check if Load Balancer Controller policy exists
# If empty output, policy needs to be created

# Step 2: Create IAM policy from JSON file (if missing)
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
# Purpose: Creates policy with necessary LoadBalancer permissions
# File iam_policy.json should contain AWS LB Controller permissions
# Save the PolicyArn from output for next step

# Step 3: Attach policy to EKS node IAM role
aws iam attach-role-policy \
    --role-name <eks-node-role-name> \
    --policy-arn arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy
# Purpose: Grants worker nodes permission to create/manage LoadBalancers
# Replace <eks-node-role-name> with actual node role (check EKS console)
# Replace <account-id> with your AWS account ID

# Step 4: Verify policy is attached to role
aws iam list-attached-role-policies --role-name <eks-node-role-name>
# Purpose: Confirms policy is properly attached
# Should show AWSLoadBalancerControllerIAMPolicy in output

# Step 5: Delete and recreate service to trigger LoadBalancer creation
kubectl delete svc trend-app-service -n trend-app
# Purpose: Removes existing service with pending LoadBalancer

kubectl apply -f k8s/service.yaml
# Purpose: Recreates service with proper IAM permissions now in place

# Step 6: Watch service until LoadBalancer is provisioned
kubectl get svc trend-app-service -n trend-app -w
# Purpose: Monitor LoadBalancer creation in real-time
# Should show EXTERNAL-IP within 2-3 minutes
```

**Alternative: Check Subnet Tags for LoadBalancer Discovery**

```bash
# LoadBalancers require specific subnet tags to function
# Public subnets need:
# kubernetes.io/role/elb = 1

# Private subnets need:
# kubernetes.io/role/internal-elb = 1

# Add tags to subnets if missing:
aws ec2 create-tags \
    --resources subnet-xxxxxxxx \
    --tags Key=kubernetes.io/role/elb,Value=1 \
    --region ap-south-1
# Purpose: Tags subnet for LoadBalancer placement
# EKS uses these tags to determine which subnets can host LoadBalancers
```

### Issue 2: Pods in CrashLoopBackOff State

**Symptoms:**
- Pods constantly restarting
- Application not accessible
- High restart count

**Diagnosis Commands:**

```bash
# Check pod status and restart count
kubectl get pods -n trend-app
# Look for STATUS: CrashLoopBackOff and RESTARTS: >5

# View pod logs to identify error
kubectl logs <pod-name> -n trend-app
# Purpose: Shows application error messages
# Common issues: Missing env vars, port conflicts, dependency failures

# Get previous pod logs (if pod restarted)
kubectl logs <pod-name> -n trend-app --previous
# Purpose: View logs from crashed container before restart
# Critical for finding crash cause

# Describe pod for events and status
kubectl describe pod <pod-name> -n trend-app
# Purpose: Shows container exit codes, events, resource constraints
# Look for: Exit Code, Last State, Events section
```

**Common Solutions:**

```bash
# Fix 1: Update container image to working version
kubectl set image deployment/trend-app-deployment \
    trend-app=abhimishra/trend-app:working-tag -n trend-app
# Purpose: Rollback to known good image version

# Fix 2: Increase resource limits if OOMKilled
kubectl set resources deployment trend-app-deployment \
    --limits=memory=512Mi -n trend-app
# Purpose: Provides more memory if pods are being killed by OOM

# Fix 3: Check and fix environment variables
kubectl set env deployment/trend-app-deployment \
    NODE_ENV=production -n trend-app
# Purpose: Sets required environment variables
```

### Issue 3: Service Has No Endpoints

**Symptoms:**
- Service created but no traffic routing
- `kubectl describe svc` shows "Endpoints: <none>"
- Application unreachable through service

**Diagnosis:**

```bash
# Check if service has endpoints
kubectl describe svc trend-app-service -n trend-app | grep Endpoints
# Purpose: Verifies if service can find matching pods
# If <none>, selector labels don't match pod labels

# Compare service selector with pod labels
kubectl get svc trend-app-service -n trend-app -o yaml | grep -A 2 selector
kubectl get pods -n trend-app --show-labels
# Purpose: Ensure service selector matches pod labels exactly
# Common issue: Typo in label name or value
```

**Solution:**

```bash
# Fix service selector to match pod labels
kubectl edit svc trend-app-service -n trend-app
# Purpose: Opens service YAML in editor
# Update selector section to match pod labels
# Example: Change app: trend to app: trend-app

# Or delete and recreate with correct configuration
kubectl delete svc trend-app-service -n trend-app
kubectl apply -f k8s/service.yaml
# Purpose: Recreates service with corrected selector
```

### Issue 4: Cannot Connect to Jenkins

**Symptoms:**
- Jenkins URL not accessible
- Connection timeout or refused
- Cannot trigger pipelines

**Solution:**

```bash
# Check if Jenkins EC2 instance is running
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*jenkins*" \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'
# Purpose: Verifies Jenkins instance state and public IP
# State should be 'running'

# Check security group allows port 8080
aws ec2 describe-security-groups \
    --filters "Name=tag:Name,Values=*jenkins*" \
    --query 'SecurityGroups[].IpPermissions[]'
# Purpose: Verifies inbound rule for port 8080
# Should show: FromPort: 8080, ToPort: 8080, IpRanges: 0.0.0.0/0

# Add security group rule if missing
aws ec2 authorize-security-group-ingress \
    --group-id <jenkins-sg-id> \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0
# Purpose: Opens port 8080 for Jenkins web UI access
# Replace <jenkins-sg-id> with actual security group ID

# SSH into Jenkins instance to check service status
ssh -i your-key.pem ec2-user@<jenkins-ip>
sudo systemctl status jenkins
# Purpose: Verifies Jenkins service is running on EC2
# Should show: active (running)

# Restart Jenkins if needed
sudo systemctl restart jenkins
# Purpose: Restarts Jenkins service
# Wait 2-3 minutes for Jenkins to fully start
```

### Issue 5: Docker Build Fails in Jenkins Pipeline

**Symptoms:**
- Pipeline fails at "Build Docker Image" stage
- Error: "Cannot connect to Docker daemon"
- Permission denied errors

**Solution:**

```bash
# SSH into Jenkins server
ssh -i your-key.pem ec2-user@<jenkins-ip>

# Add jenkins user to docker group
sudo usermod -aG docker jenkins
# Purpose: Grants Jenkins permission to use Docker
# Allows pipeline to execute docker build/push commands

# Restart Jenkins to apply group changes
sudo systemctl restart jenkins
# Purpose: Reloads user group memberships
# Required for usermod changes to take effect

# Verify Docker is running
sudo systemctl status docker
# Purpose: Confirms Docker daemon is active
# Should show: active (running)

# Test Docker access as jenkins user
sudo -u jenkins docker ps
# Purpose: Verifies jenkins user can communicate with Docker
# Should list containers or show empty list (not permission error)
```

### Issue 6: Kubectl Commands Fail in Jenkins Pipeline

**Symptoms:**
- Pipeline fails at "Deploy to Kubernetes" stage
- Error: "The connection to the server localhost:8080 was refused"
- kubectl: command not found

**Solution:**

```bash
# SSH into Jenkins server
ssh -i your-key.pem ec2-user@<jenkins-ip>

# Install kubectl if not present
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
# Purpose: Installs kubectl CLI tool on Jenkins server

# Configure kubeconfig for jenkins user
sudo su - jenkins
mkdir -p ~/.kube
# Copy kubeconfig from your local machine or EC2 instance
# Purpose: Provides Jenkins with EKS cluster credentials

# Test kubectl access
kubectl get nodes
# Purpose: Verifies kubectl can connect to EKS cluster
# Should list all worker nodes

# Ensure kubeconfig is referenced in Jenkins pipeline
# In Jenkinsfile, verify:
# withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')])
```

### Issue 7: GitHub Webhook Not Triggering Builds

**Symptoms:**
- Manual builds work, but git push doesn't trigger
- No build activity after pushing code
- Webhook shows failed deliveries

**Solution:**

```bash
# Check webhook delivery status in GitHub
# Go to: Repo → Settings → Webhooks → Your webhook → Recent Deliveries
# Look for HTTP response code and error message

# Common Fix 1: Verify webhook URL format
# Correct format: http://<jenkins-url>:8080/github-webhook/
# Common mistake: Missing trailing slash or /github-webhook/

# Common Fix 2: Check Jenkins is accessible from internet
curl http://<jenkins-url>:8080
# Purpose: Tests if Jenkins is publicly accessible
# Should return HTML (Jenkins login page)

# Common Fix 3: Disable CSRF protection for webhook endpoint
# Jenkins → Manage Jenkins → Configure Global Security
# CSRF Protection → Advanced → Add /github-webhook/ to exceptions

# Common Fix 4: Verify GitHub plugin configuration
# Manage Jenkins → Configure System → GitHub
# Ensure GitHub server is added with valid credentials

# Test webhook manually
curl -X POST http://<jenkins-url>:8080/github-webhook/
# Purpose: Simulates GitHub webhook call
# Should trigger Jenkins build if configured correctly
```

### Issue 8: High Pod Restart Count

**Symptoms:**
- Pods frequently restarting
- Application intermittently unavailable
- Restart count increasing over time

**Diagnosis & Solution:**

```bash
# Check pod resource usage
kubectl top pods -n trend-app
# Purpose: Shows if pods are hitting memory/CPU limits
# High usage indicates need for resource limit increase

# View pod events for OOMKilled errors
kubectl describe pod <pod-name> -n trend-app | grep -A 5 "Last State"
# Purpose: Identifies if pods killed due to Out Of Memory
# Shows: Exit Code 137 = OOMKilled

# Increase memory limits if OOMKilled
kubectl set resources deployment/trend-app-deployment \
    --requests=memory=512Mi \
    --limits=memory=1Gi \
    -n trend-app
# Purpose: Provides more memory to prevent OOM kills
# Adjust values based on actual usage from kubectl top

# Check for liveness/readiness probe failures
kubectl describe pod <pod-name> -n trend-app | grep -i probe
# Purpose: Identifies if health check probes are failing
# Failing probes cause Kubernetes to restart pods

# Adjust probe thresholds if needed
kubectl edit deployment trend-app-deployment -n trend-app
# Purpose: Modify liveness/readiness probe configuration
# Increase initialDelaySeconds, timeoutSeconds, or failureThreshold
```

---

## 📊 Monitoring Commands

### Prometheus and Grafana Setup

```bash
# Update system packages on Jenkins/monitoring server
sudo yum update -y
# Purpose: Ensures latest security patches and package versions
# Always run before installing new software

# Install Docker on Amazon Linux 2
sudo amazon-linux-extras install docker -y
# Purpose: Installs Docker from Amazon Linux Extras repository
# Required for running Grafana container

# Enable Docker to start on boot
sudo systemctl enable docker
# Purpose: Auto-starts Docker service after server reboot
# Ensures monitoring remains available after maintenance

# Start Docker service immediately
sudo systemctl start docker
# Purpose: Starts Docker daemon without reboot
# Makes docker commands available now

# Add current user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker $USER
# Purpose: Grants non-root user permission to run Docker
# Logout and login again for changes to take effect

# Run Grafana container with persistent storage
docker run -d -p 3000:3000 \
  --name=grafana \
  -v /home/ec2-user/monitoring/dashboards:/var/lib/grafana/dashboards \
  grafana/grafana
# Purpose: Launches Grafana web interface on port 3000
# -d runs in background, -p maps ports, -v mounts volume for dashboards
# Access via: http://<server-ip>:3000 (default login: admin/admin)

# Install Helm package manager
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
# Purpose: Installs Helm 3 for Kubernetes package management
# Helm simplifies deployment of complex applications like Prometheus

# Verify Helm installation
helm version
# Purpose: Confirms Helm is installed and shows version
# Should display: version.BuildInfo{Version:"v3.x.x"}

# Add Grafana Helm chart repository
helm repo add grafana https://grafana.github.io/helm-charts
# Purpose: Adds official Grafana charts repository to Helm
# Enables installation of Grafana via Helm

# Add Prometheus Helm chart repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Purpose: Adds Prometheus community charts to Helm
# Required for installing Prometheus monitoring stack

# Update Helm repositories to get latest charts
helm repo update
# Purpose: Refreshes local cache with latest chart versions
# Similar to 'apt update' or 'yum update' for Helm

# Install Grafana using Helm with custom values
helm upgrade --install grafana grafana/grafana -f grafana-values.yaml
# Purpose: Deploys Grafana to Kubernetes cluster
# --install creates if doesn't exist, --upgrade updates if exists
# -f specifies custom configuration file

# Install Prometheus using Helm with custom values
helm upgrade --install prometheus prometheus-community/prometheus -f prometheus-values.yaml
# Purpose: Deploys Prometheus metrics collection system
# Automatically discovers and scrapes Kubernetes metrics

# Forward Grafana service port to localhost for access
kubectl port-forward svc/grafana 3000:80
# Purpose: Creates tunnel from local machine to Grafana service
# Access dashboard via: http://localhost:3000
# Useful when LoadBalancer is not configured

# Check Grafana server status (if installed via systemd)
sudo systemctl status grafana-server
# Purpose: Verifies Grafana service is running on host
# Alternative to containerized Grafana

# Start Grafana service
sudo systemctl start grafana-server
# Purpose: Starts Grafana if stopped
# Access via: http://<server-ip>:3000

# Enable Grafana to start on boot
sudo systemctl enable grafana-server
# Purpose: Auto-starts Grafana after server reboot
# Ensures monitoring survives maintenance windows
```

---

## 🧹 Cleanup and Teardown

### Complete Infrastructure Removal

```bash
# Scale down deployment to zero replicas (graceful shutdown)
kubectl scale deployment trend-app-deployment --replicas=0 -n trend-app
# Purpose: Stops all application pods before deletion
# Prevents sudden traffic interruption

# Delete all Kubernetes resources in namespace
kubectl delete namespace trend-app
# Purpose: Removes all resources (pods, services, deployments) in one command
# Faster than deleting resources individually

# Destroy all AWS infrastructure created by Terraform
cd infrastructure
terraform destroy -auto-approve
# Purpose: Deletes EKS cluster, VPC, subnets, security groups, EC2 instances
# -auto-approve skips confirmation prompt
# WARNING: This is irreversible - ensure you have backups

# Remove Docker images from Jenkins server to free disk space
docker system prune -a
# Purpose: Deletes all unused containers, networks, images, and build cache
# -a removes all unused images, not just dangling ones
# Frees up significant disk space

# Delete Docker images with specific tag
docker rmi abhimishra/trend-app:latest
# Purpose: Removes specific Docker image by name and tag
# Use when you want selective cleanup

# Remove Helm releases
helm uninstall grafana
helm uninstall prometheus
# Purpose: Removes Helm-deployed applications from cluster
# Cleaner than manual kubectl delete

# Clean up local kubeconfig context
kubectl config delete-context <context-name>
# Purpose: Removes EKS cluster context from ~/.kube/config
# Prevents accidental commands to deleted cluster
```

---

## 💰 Cost Optimization Tips

```bash
# Check running EC2 instances and their costs
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].[InstanceId,InstanceType,LaunchTime]' \
    --output table
# Purpose: Lists all running instances with type and launch time
# Identify instances to stop during non-working hours

# Stop Jenkins EC2 instance when not in use
aws ec2 stop-instances --instance-ids <jenkins-instance-id>
# Purpose: Stops Jenkins to save costs (only pay for EBS storage)
# Save ~$30-50/month by stopping outside work hours

# Start Jenkins when needed
aws ec2 start-instances --instance-ids <jenkins-instance-id>
# Purpose: Restarts Jenkins EC2 for pipeline executions
# Takes 2-3 minutes to boot and start Jenkins service

# Scale down EKS node group during off-hours
aws eks update-nodegroup-config \
    --cluster-name trend-app-eks-by-abhi \
    --nodegroup-name <nodegroup-name> \
    --scaling-config minSize=1,maxSize=1,desiredSize=1
# Purpose: Reduces worker nodes from 3 to 1 to cut costs
# Saves ~$100-150/month during non-production hours

# Delete unused LoadBalancers to avoid charges
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code]'
# Purpose: Lists all Load Balancers and their states
# Delete unused LBs: ~$16-20/month per NLB

# Monitor AWS costs with AWS Cost Explorer (via CLI)
aws ce get-cost-and-usage \
    --time-period Start=2024-11-01,End=2024-11-17 \
    --granularity DAILY \
    --metrics "BlendedCost" \
    --group-by Type=SERVICE
# Purpose: Shows daily cost breakdown by AWS service
# Identify cost spikes and optimize accordingly
```

---

## 📸 Project Submission Checklist

### Required Screenshots and Outputs

```bash
# 1. Capture EKS cluster details
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1 > cluster-details.json
# Purpose: Saves complete cluster configuration as proof
# Submit this JSON file with your project

# 2. Get Jenkins pipeline build screenshot
# Navigate to: http://<jenkins-url>:8080/job/trend-app-deployment/
# Take screenshot showing: Successful build, all stages passed

# 3. Export kubectl outputs
kubectl get all -n trend-app > kubectl-resources.txt
# Purpose: Captures all deployed resources (pods, services, deployments)
# Shows application is successfully deployed

# 4. Get LoadBalancer ARN
aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?contains(LoadBalancerName, `trend`)].LoadBalancerArn' \
    --output text > loadbalancer-arn.txt
# Purpose: Retrieves AWS resource identifier for LoadBalancer
# Required for project verification

# 5. Get application URL
kubectl get svc trend-app-service -n trend-app \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' > app-url.txt
# Purpose: Extracts public URL of deployed application
# Use this URL for live demo screenshot

# 6. Capture application screenshot
# Open browser to LoadBalancer URL
# Take full-page screenshot showing application running

# 7. Export Terraform state outputs
cd infrastructure
terraform output -json > terraform-outputs.json
# Purpose: Saves all infrastructure details (VPC ID, subnet IDs, etc.)
# Documents complete infrastructure setup
```

### Submission Package Contents

```
project-submission/
├── screenshots/
│   ├── 01-eks-cluster-console.png       # AWS EKS console showing cluster
│   ├── 02-jenkins-pipeline-success.png  # Jenkins build #X successful
│   ├── 03-kubectl-get-all.png           # Terminal output of resources
│   ├── 04-application-running.png       # Browser showing live app
│   └── 05-loadbalancer-aws-console.png  # AWS EC2 LoadBalancer page
├── outputs/
│   ├── cluster-details.json             # EKS cluster configuration
│   ├── kubectl-resources.txt            # All K8s resources
│   ├── loadbalancer-arn.txt             # LB ARN for verification
│   ├── app-url.txt                      # Public application URL
│   └── terraform-outputs.json           # Infrastructure details
├── logs/
│   ├── terraform-apply.log              # Infrastructure creation log
│   ├── jenkins-build-10.log             # Latest successful build log
│   └── kubectl-deployment.log           # Deployment execution log
└── README.md                            # This documentation
```

---

## 🎓 Learning Resources

### Official Documentation
- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes Official Docs**: https://kubernetes.io/docs/
- **Jenkins Pipeline Syntax**: https://www.jenkins.io/doc/book/pipeline/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Docker Documentation**: https://docs.docker.com/

### Useful Tutorials
- **EKS Workshop**: https://www.eksworkshop.com/
- **Kubernetes by Example**: https://kubernetesbyexample.com/
- **Jenkins Pipeline Examples**: https://www.jenkins.io/doc/pipeline/examples/

---

## 🔐 Security Best Practices

### IAM and Access Management

```bash
# Create dedicated IAM user for CI/CD (instead of using root)
aws iam create-user --user-name jenkins-cicd-user
# Purpose: Creates isolated user for Jenkins with minimal permissions
# Follow principle of least privilege

# Create access key for Jenkins user
aws iam create-access-key --user-name jenkins-cicd-user
# Purpose: Generates credentials for programmatic access
# Store AccessKeyId and SecretAccessKey securely in Jenkins credentials

# Attach specific policy instead of AdministratorAccess
aws iam attach-user-policy \
    --user-name jenkins-cicd-user \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
# Purpose: Grants only necessary EKS permissions
# Prevents over-privileged access

# Enable MFA for AWS console access
aws iam enable-mfa-device \
    --user-name your-admin-user \
    --serial-number arn:aws:iam::ACCOUNT-ID:mfa/USERNAME \
    --authentication-code-1 123456 \
    --authentication-code-2 789012
# Purpose: Adds two-factor authentication for enhanced security
# Protects against credential theft
```

### Kubernetes RBAC (Role-Based Access Control)

```bash
# Create service account for Jenkins in Kubernetes
kubectl create serviceaccount jenkins-deployer -n trend-app
# Purpose: Creates dedicated identity for Jenkins in cluster
# Better than using default service account

# Create role with specific permissions
kubectl create role deployer-role \
    --verb=get,list,update,patch,create \
    --resource=deployments,services,pods \
    -n trend-app
# Purpose: Defines what actions are allowed
# Limits permissions to only necessary operations

# Bind role to service account
kubectl create rolebinding jenkins-deployer-binding \
    --role=deployer-role \
    --serviceaccount=trend-app:jenkins-deployer \
    -n trend-app
# Purpose: Grants service account the defined permissions
# Associates identity with authorization rules

# Get service account token for Jenkins
kubectl get secret $(kubectl get sa jenkins-deployer -n trend-app -o jsonpath='{.secrets[0].name}') -n trend-app -o jsonpath='{.data.token}' | base64 -d
# Purpose: Extracts authentication token for use in Jenkins
# Use this token instead of cluster admin credentials
```

### Docker Image Security

```bash
# Scan Docker image for vulnerabilities before pushing
docker scan abhimishra/trend-app:latest
# Purpose: Identifies security vulnerabilities in image layers
# Requires Docker Hub account and docker scan enabled

# Use multi-stage builds to reduce image size and attack surface
# In Dockerfile:
# FROM node:18 AS builder
# ... build steps ...
# FROM nginx:alpine
# COPY --from=builder /app/dist /usr/share/nginx/html
# Purpose: Final image only contains runtime dependencies, not build tools

# Sign Docker images for authenticity
docker trust sign abhimishra/trend-app:latest
# Purpose: Cryptographically signs image to verify publisher
# Prevents image tampering and ensures authenticity

# Enable Docker Content Trust in Jenkins
# Add to Jenkinsfile environment:
# DOCKER_CONTENT_TRUST = '1'
# Purpose: Enforces image signature verification before deployment
```

### Secrets Management

```bash
# Store sensitive data in Kubernetes secrets (not ConfigMaps)
kubectl create secret generic app-secrets \
    --from-literal=db-password='super-secret-password' \
    --from-literal=api-key='your-api-key' \
    -n trend-app
# Purpose: Encrypts sensitive configuration at rest
# Base64 encoded and can be encrypted with KMS

# Reference secrets in deployment
# In deployment.yaml:
# env:
#   - name: DB_PASSWORD
#     valueFrom:
#       secretKeyRef:
#         name: app-secrets
#         key: db-password
# Purpose: Injects secrets as environment variables securely

# Use AWS Secrets Manager for production secrets
aws secretsmanager create-secret \
    --name trend-app/prod/db-credentials \
    --secret-string '{"username":"admin","password":"secure-password"}'
# Purpose: Centralized secret storage with automatic rotation
# Integrates with EKS using CSI driver

# Install AWS Secrets Manager CSI driver
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/rbac-secretproviderclass.yaml
# Purpose: Enables mounting secrets from AWS Secrets Manager as volumes
# Secrets auto-sync without pod restart
```

### Network Security

```bash
# Apply NetworkPolicy to restrict pod communication
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: trend-app-network-policy
  namespace: trend-app
spec:
  podSelector:
    matchLabels:
      app: trend-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: trend-app
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
EOF
# Purpose: Restricts network traffic to/from pods
# Only allows necessary communication paths

# Enable VPC Flow Logs for network monitoring
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-083ba4e38e3114ac2 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/trend-app
# Purpose: Captures all network traffic for security analysis
# Helps detect suspicious activity and troubleshoot connectivity

# Restrict security group rules to minimum required
aws ec2 revoke-security-group-ingress \
    --group-id sg-xxxxx \
    --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=0.0.0.0/0}]'
# Purpose: Removes overly permissive SSH access from anywhere
# Replace with specific IP range for admin access only

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxx \
    --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=YOUR-IP/32}]'
# Purpose: Allows SSH only from your specific IP address
# Reduces attack surface significantly
```

### Jenkins Security Hardening

```bash
# Enable CSRF protection in Jenkins
# Navigate to: Manage Jenkins → Configure Global Security
# ☑️ Prevent Cross Site Request Forgery exploits
# Purpose: Protects against CSRF attacks that could trigger unauthorized builds

# Use Jenkins Credentials Plugin for secret management
# Never hardcode passwords in Jenkinsfile
# Instead use: credentials('credential-id')
# Purpose: Keeps secrets encrypted in Jenkins and masked in logs

# Enable audit logging in Jenkins
# Install: Audit Trail Plugin
# Configure: Manage Jenkins → Configure System → Audit Trail
# Purpose: Tracks all user actions for compliance and security investigations

# Restrict Jenkins agent execution to labeled nodes
# In Jenkinsfile: agent { label 'docker-enabled' }
# Purpose: Ensures pipelines run only on authorized nodes
# Prevents execution on compromised or untrusted agents

# Regular backup of Jenkins configuration
tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz /var/lib/jenkins/
# Purpose: Creates compressed backup of Jenkins home directory
# Include jobs, configurations, credentials (encrypted)
# Store backups in S3 or secure location
```

---

## 📈 Performance Optimization

### Kubernetes Resource Optimization

```bash
# Set appropriate resource requests and limits
kubectl set resources deployment/trend-app-deployment \
    --requests=cpu=100m,memory=256Mi \
    --limits=cpu=500m,memory=512Mi \
    -n trend-app
# Purpose: Ensures pods get minimum resources and don't exceed limits
# Prevents resource starvation and OOM kills
# Adjust based on actual usage from kubectl top

# Enable Horizontal Pod Autoscaler (HPA)
kubectl autoscale deployment trend-app-deployment \
    --cpu-percent=70 \
    --min=3 \
    --max=10 \
    -n trend-app
# Purpose: Automatically scales pods based on CPU utilization
# Maintains performance during traffic spikes
# Scales down during low traffic to save costs

# Verify HPA is working
kubectl get hpa -n trend-app
# Purpose: Shows current replicas, target CPU, and scaling status
# Monitor during load tests to verify autoscaling behavior

# Enable cluster autoscaler for node scaling
# Add tags to Auto Scaling Group:
# k8s.io/cluster-autoscaler/enabled: true
# k8s.io/cluster-autoscaler/trend-app-eks-by-abhi: owned
aws autoscaling create-or-update-tags \
    --tags "ResourceId=<asg-name>,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true"
# Purpose: Enables automatic node provisioning when pods can't be scheduled
# Adds nodes during high demand, removes during low usage
```

### Docker Image Optimization

```bash
# Use Alpine-based images for smaller size
# In Dockerfile:
# FROM node:18-alpine AS builder
# Purpose: Reduces image size by 70-80%
# Faster pulls and deployments

# Use .dockerignore to exclude unnecessary files
cat > .dockerignore <<EOF
node_modules
npm-debug.log
.git
.github
*.md
.env
.DS_Store
EOF
# Purpose: Excludes files from Docker build context
# Speeds up build and reduces image size

# Build with BuildKit for better caching
DOCKER_BUILDKIT=1 docker build -t abhimishra/trend-app:latest .
# Purpose: Enables advanced caching and parallel builds
# 2-3x faster builds with better layer caching

# Compress layers and remove unnecessary files
# In Dockerfile:
# RUN apt-get update && apt-get install -y package \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
# Purpose: Combines commands and cleans up in same layer
# Reduces final image size

# Analyze image layers to find optimization opportunities
docker history abhimishra/trend-app:latest
# Purpose: Shows size of each layer
# Identify large layers and optimize them
```

### Application Performance

```bash
# Enable caching in React app
# In package.json build script:
# "build": "react-scripts build && npm run sw-build"
# Purpose: Generates service worker for offline caching
# Improves load time for repeat visitors

# Enable Gzip compression in nginx
# In nginx.conf:
# gzip on;
# gzip_types text/css application/javascript application/json;
# Purpose: Compresses responses to reduce bandwidth
# 70-80% reduction in payload size

# Use CDN for static assets
# Configure CloudFront distribution:
aws cloudfront create-distribution \
    --origin-domain-name <load-balancer-dns> \
    --default-root-object index.html
# Purpose: Caches static content globally
# Reduces latency for international users

# Enable connection pooling for database (if applicable)
# In application code:
# Pool size: 10-20 connections
# Purpose: Reuses database connections instead of creating new ones
# Reduces connection overhead and improves throughput
```

---

## 🔄 Disaster Recovery & Backup

### EKS Cluster Backup

```bash
# Backup EKS cluster configuration
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1 \
    > backups/eks-cluster-$(date +%Y%m%d).json
# Purpose: Saves complete cluster configuration
# Use for disaster recovery or cloning to new region

# Backup all Kubernetes resources
kubectl get all --all-namespaces -o yaml > backups/k8s-all-resources-$(date +%Y%m%d).yaml
# Purpose: Exports all deployments, services, pods, etc.
# Quick restore with: kubectl apply -f backup-file.yaml

# Backup persistent volume data (if using EBS)
aws ec2 create-snapshot \
    --volume-id vol-xxxxx \
    --description "Trend App Data Backup $(date +%Y-%m-%d)"
# Purpose: Creates point-in-time snapshot of EBS volume
# Restores data in case of corruption or deletion

# Install Velero for automated backups
kubectl apply -f https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz
# Purpose: Kubernetes backup and restore tool
# Supports scheduled backups to S3

# Create Velero backup
velero backup create trend-app-backup \
    --include-namespaces trend-app \
    --storage-location aws
# Purpose: Backs up entire namespace to S3
# Includes resources, volumes, and configurations

# Schedule daily backups
velero schedule create daily-backup \
    --schedule="0 2 * * *" \
    --include-namespaces trend-app
# Purpose: Automates daily backups at 2 AM
# Retention policy can be configured
```

### Jenkins Backup

```bash
# Backup Jenkins home directory
tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz \
    -C /var/lib/jenkins \
    --exclude='workspace' \
    --exclude='caches' \
    .
# Purpose: Creates compressed archive of Jenkins configuration
# Excludes large temporary directories

# Upload backup to S3
aws s3 cp jenkins-backup-$(date +%Y%m%d).tar.gz \
    s3://your-backup-bucket/jenkins/
# Purpose: Stores backup off-server for disaster recovery
# Enable versioning on S3 bucket for history

# Automate backup with cron job
crontab -e
# Add: 0 3 * * * /path/to/jenkins-backup-script.sh
# Purpose: Runs backup daily at 3 AM automatically
# Email notifications can be configured for failures

# Backup Jenkins credentials separately
cp /var/lib/jenkins/credentials.xml backups/credentials-$(date +%Y%m%d).xml
# Purpose: Separately backs up encrypted credentials
# Critical for pipeline functionality restoration
```

### Recovery Procedures

```bash
# Restore EKS cluster from backup
# 1. Recreate cluster with same configuration
terraform apply

# 2. Restore Kubernetes resources
kubectl apply -f backups/k8s-all-resources-YYYYMMDD.yaml
# Purpose: Recreates all deployments, services, etc.
# May need to adjust resource versions

# 3. Restore persistent data
aws ec2 create-volume \
    --snapshot-id snap-xxxxx \
    --availability-zone ap-south-1a
# Purpose: Creates new volume from snapshot
# Attach to pod via PersistentVolume

# Restore Jenkins from backup
# 1. Stop Jenkins
sudo systemctl stop jenkins

# 2. Extract backup
tar -xzf jenkins-backup-YYYYMMDD.tar.gz -C /var/lib/jenkins/
# Purpose: Restores all configurations and jobs

# 3. Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/
# Purpose: Ensures Jenkins can read/write files

# 4. Start Jenkins
sudo systemctl start jenkins
# Purpose: Brings Jenkins back online with restored state

# Test recovery with dry-run
velero restore create --from-backup trend-app-backup --dry-run
# Purpose: Validates backup can be restored without applying changes
# Checks for resource conflicts and errors
```

---

## 📝 Additional Best Practices

### Git Workflow

```bash
# Use feature branches for development
git checkout -b feature/new-component
# Purpose: Isolates new features from main branch
# Enables parallel development without conflicts

# Create pull requests for code review
# Push branch: git push origin feature/new-component
# Create PR on GitHub for team review
# Purpose: Ensures code quality through peer review
# Triggers CI/CD pipeline for automated testing

# Tag releases for version tracking
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
# Purpose: Marks stable releases in Git history
# Enables rollback to specific versions

# Use semantic versioning
# Format: MAJOR.MINOR.PATCH (e.g., 1.2.3)
# Purpose: Communicates type of changes in release
# Breaking changes: increment MAJOR
# New features: increment MINOR
# Bug fixes: increment PATCH
```

### CI/CD Pipeline Enhancements

```bash
# Add automated testing stage to Jenkinsfile
stage('Run Tests') {
    steps {
        sh 'npm test -- --coverage'
        publishHTML(target: [
            reportDir: 'coverage',
            reportFiles: 'index.html',
            reportName: 'Test Coverage'
        ])
    }
}
# Purpose: Runs unit tests before deployment
# Prevents broken code from reaching production

# Add security scanning stage
stage('Security Scan') {
    steps {
        sh 'npm audit --audit-level=high'
        sh 'docker scan ${DOCKERHUB_REPO}:${IMAGE_TAG}'
    }
}
# Purpose: Identifies security vulnerabilities early
# Fails build if critical vulnerabilities found

# Add smoke tests after deployment
stage('Smoke Test') {
    steps {
        script {
            def response = sh(
                script: "curl -f http://${LOAD_BALANCER_URL}",
                returnStatus: true
            )
            if (response != 0) {
                error("Application health check failed")
            }
        }
    }
}
# Purpose: Verifies application is accessible after deployment
# Rolls back if health check fails
```

### Monitoring Alerts

```bash
# Create CloudWatch alarm for high CPU usage
aws cloudwatch put-metric-alarm \
    --alarm-name trend-app-high-cpu \
    --alarm-description "Alert when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EKS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2
# Purpose: Notifies when cluster is under heavy load
# Enables proactive scaling or investigation

# Create alarm for pod restarts
# Requires Prometheus metrics
# Alert rule in prometheus-values.yaml:
# - alert: HighPodRestartRate
#   expr: rate(kube_pod_container_status_restarts_total[15m]) > 0.1
# Purpose: Detects application instability
# Indicates need for bug fixes or resource adjustments

# Set up SNS topic for alarm notifications
aws sns create-topic --name trend-app-alerts
aws sns subscribe \
    --topic-arn arn:aws:sns:ap-south-1:ACCOUNT-ID:trend-app-alerts \
    --protocol email \
    --notification-endpoint your-email@example.com
# Purpose: Sends email/SMS notifications for critical alerts
# Enables rapid response to incidents
```

---

## 🎯 Project Success Criteria

### Validation Checklist

- [ ] **Infrastructure Created**: All Terraform resources provisioned successfully
- [ ] **EKS Cluster Running**: 3 worker nodes in Ready state
- [ ] **Application Deployed**: All pods running with 1/1 Ready status
- [ ] **LoadBalancer Active**: External IP assigned and accessible
- [ ] **Jenkins Operational**: Pipeline executing successfully
- [ ] **Webhook Configured**: Git push triggers automatic builds
- [ ] **Monitoring Setup**: Prometheus and Grafana collecting metrics
- [ ] **Security Hardened**: RBAC, NetworkPolicies, and Secrets configured
- [ ] **Backups Enabled**: Automated backup solution in place
- [ ] **Documentation Complete**: All commands and architecture documented

### Performance Benchmarks

```bash
# Test application response time
curl -w "@curl-format.txt" -o /dev/null -s http://<load-balancer-url>
# Purpose: Measures page load time
# Target: < 2 seconds for acceptable UX

# Load test with Apache Bench
ab -n 1000 -c 10 http://<load-balancer-url>/
# Purpose: Tests application under load (1000 requests, 10 concurrent)
# Target: 99% success rate, < 5s average response time

# Monitor pod resource usage during load test
kubectl top pods -n trend-app --watch
# Purpose: Observes CPU/memory consumption under stress
# Validates resource limits are appropriate
```

---

## 📞 Support and Contribution

### Getting Help

- **GitHub Issues**: Report bugs or request features
- **Documentation**: Refer to official docs for tools used
- **Community**: Join Kubernetes Slack for real-time help

### Contributing

```bash
# Fork repository
git clone https://github.com/YOUR-USERNAME/trend.git

# Create feature branch
git checkout -b feature/improvement

# Make changes and test thoroughly
npm test
docker build -t test-image .

# Submit pull request
git push origin feature/improvement
# Create PR on GitHub with detailed description
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Abhi Mishra**
- GitHub: [@Abhi-mishra998](https://github.com/Abhi-mishra998)
- Project: Trend App DevOps Implementation

---

## 🙏 Acknowledgments

- AWS EKS Documentation Team
- Kubernetes Community
- Jenkins Open Source Contributors
- HashiCorp Terraform Team

---

## 📚 Appendix

### Terraform Module Structure

```
infrastructure/
├── main.tf                 # Primary infrastructure definitions
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── providers.tf           # Provider configurations
└── modules/
    ├── vpc/              # VPC and networking
    ├── eks/              # EKS cluster
    ├── jenkins/          # Jenkins EC2 instance
    └── security/         # Security groups and IAM
```

### Environment Variables Reference

```bash
# AWS Configuration
export AWS_REGION="ap-south-1"
export AWS_ACCOUNT_ID="123456789012"

# Docker Configuration
export DOCKERHUB_USERNAME="your-username"
export DOCKERHUB_REPO="trend-app"

# EKS Configuration
export CLUSTER_NAME="trend-app-eks-by-abhi"
export NAMESPACE="trend-app"

# Jenkins Configuration
export JENKINS_URL="http://ec2-xx-xx-xx-xx.compute.amazonaws.com:8080"
```

### Common Port Reference

| Service | Port | Purpose |
|---------|------|---------|
| Jenkins | 8080 | Web UI |
| Kubernetes API | 6443 | Cluster management |
| Application | 3000 | React dev server |
| Grafana | 3000 | Monitoring dashboard |
| Prometheus | 9090 | Metrics collection |
| SSH | 22 | Remote access |
| HTTP | 80 | Web traffic |
| HTTPS | 443 | Secure web traffic |

---

**🚀 Ready to deploy your production-grade Kubernetes application!**

*Last Updated: November 2025*
*Author: Abhishek-Mishra
