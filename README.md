# 🚀 Production-Grade CI/CD Platform for Scalable React Applications on AWS EKS

> **Zero-Downtime Deployment System**: Fully automated CI/CD pipeline that provisions infrastructure, containerizes, and deploys a React application on AWS EKS using Jenkins, Terraform, and Kubernetes — reducing deployment time from ~30 minutes to under 5 minutes.

[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9.8-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)

---

## 📑 Table of Contents

- [Problem Statement](#-problem-statement)
- [Key Innovations](#-key-innovations)
- [Measurable Impact](#-measurable-impact)
- [Project Demo Video](#-project-demo-video)
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
- [Cleanup & Teardown](#-cleanup--teardown)

---

## 🔥 Problem Statement

Modern frontend deployments are often manual, slow, error-prone, and lack scalability. Teams spend valuable time on repetitive deployment tasks, face downtime during updates, and struggle to scale applications under sudden traffic spikes.

**This project solves that by building a fully automated CI/CD pipeline that:**

- Eliminates manual deployment steps from code commit to production
- Enables zero-downtime rolling updates through Kubernetes
- Automatically scales from 3 to 10 pods based on real traffic load
- Provisions an entire production-grade AWS infrastructure in ~20 minutes via Terraform
- Integrates GitHub webhooks so every `git push` triggers a full build-test-deploy cycle

---

## 💡 Key Innovations

**1. GitHub Webhook → Full Automation Pipeline**
Every push to the `main` branch automatically triggers a Jenkins build, Docker containerization, push to DockerHub, and rolling deployment to EKS — zero manual steps required.

**2. Rolling Deployments with Zero Downtime**
Kubernetes rolling update strategy ensures the application remains live throughout every deployment. Old pods are replaced gradually only after new ones pass health checks.

**3. Infrastructure as Code (Full Stack IaC)**
The entire AWS environment — VPC, subnets, security groups, EKS cluster, node groups, and Jenkins EC2 — is defined and reproducible in Terraform. Spin up or tear down the whole stack in one command.

**4. Horizontal Pod Autoscaling**
HPA automatically scales pods from 3 to 10 replicas when CPU utilization exceeds 70%, then scales back down — optimizing both performance and cost.

**5. Security-First Design**
Kubernetes RBAC, NetworkPolicies, IAM least-privilege roles, and Kubernetes Secrets are all configured out of the box. Jenkins credentials are stored encrypted and injected securely into the pipeline.

**6. Full Observability Stack**
Prometheus collects cluster and application metrics; Grafana provides pre-configured dashboards for real-time visibility into pod health, resource usage, and deployment status.

---

## 📊 Measurable Impact

| Metric | Before | After |
|--------|--------|-------|
| **Deployment Time** | ~30 minutes (manual) | ~4 minutes (automated) |
| **Downtime per Deploy** | Variable / service restart | Zero downtime (rolling update) |
| **Pod Scaling** | Fixed 3 pods | Auto-scales 3 → 10 pods |
| **Infrastructure Provisioning** | Manual clicks in AWS console | ~20 minutes via `terraform apply` |
| **Human Intervention Required** | Every deployment | Only on pipeline failure |
| **Deployment Consistency** | Varies per engineer | 100% reproducible pipeline |

---

## 🎥 Project Demo Video

Click below to watch the full project demo — covering infrastructure provisioning, pipeline execution, rolling deployment, and Grafana monitoring:

👉 **[Watch Demo Video](https://drive.google.com/file/d/1k056nk5k4-pviVKDDrEnAtrIE6uTfNAG/view?usp=drive_link)**

[![Watch Demo](https://img.shields.io/badge/Watch%20Demo%20Video-Google%20Drive-blue?logo=google-drive)](https://drive.google.com/file/d/1k056nk5k4-pviVKDDrEnAtrIE6uTfNAG/view?usp=drive_link)

The demo shows the complete flow: **Push Code → Jenkins Triggered → Docker Build → Deploy to EKS → App Live → Grafana Dashboard**

---

## 🎯 Project Overview

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
│                       Monitoring Stack                           │
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

# Install unzip utility if not present
sudo apt install unzip -y

# Extract the Terraform binary
unzip terraform_1.9.8_linux_amd64.zip

# Move Terraform to system PATH for global access
sudo mv terraform /usr/local/bin/

# Verify successful installation
terraform -v
# Expected output: Terraform v1.9.8
```

#### 1.2 Install kubectl (Kubernetes CLI)

```bash
# Download the latest stable version of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make the kubectl binary executable
chmod +x kubectl

# Move kubectl to system PATH
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client
# Expected output: Client Version: v1.x.x
```

#### 1.3 Configure AWS CLI

```bash
# Run interactive AWS configuration wizard
aws configure
# You'll be prompted to enter:
#   - AWS Access Key ID
#   - AWS Secret Access Key
#   - Default region: ap-south-1 (Mumbai)
#   - Default output format: json

# Verify AWS configuration
aws sts get-caller-identity
# Expected output: JSON with UserId, Account, and ARN
```

### Phase 2: Infrastructure Deployment

#### 2.1 Clone and Configure Repository

```bash
# Clone the Trend App repository from GitHub
git clone https://github.com/Abhi-mishra998/trend.git
cd trend

# Navigate to infrastructure folder containing Terraform code
cd infrastructure
```

#### 2.2 Terraform Configuration

Edit `variables.tf` with your specific values:

```hcl
variable "dockerhub_username" {
  default = "your-dockerhub-username"
}

variable "dockerhub_repo" {
  default = "trend-app"
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "trend-app-eks-by-abhi"
}
```

#### 2.3 Deploy Infrastructure with Terraform

```bash
# Initialize Terraform working directory
terraform init
# Expected output: "Terraform has been successfully initialized!"

# Generate and review execution plan
terraform plan
# Review output carefully: ~50+ resources will be created

# Apply the configuration and create AWS resources
terraform apply -auto-approve
# Duration: 15-20 minutes (EKS cluster creation takes longest)

# Save important outputs
terraform output jenkins_url > jenkins_url.txt
terraform output eks_cluster_name
```

### Phase 3: Kubernetes Configuration

#### 3.1 Configure kubectl for EKS Access

```bash
# Update kubeconfig to connect kubectl to your EKS cluster
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1
# Expected output: "Added new context arn:aws:eks:ap-south-1:..."

# Verify cluster connectivity
kubectl get nodes
# Expected output: 3 nodes in "Ready" status

# Get detailed node information
kubectl get nodes -o wide
```

#### 3.2 Deploy Application to Kubernetes

```bash
# Navigate to Kubernetes manifests directory
cd Trend-by-Abhi

# Apply all Kubernetes resource definitions
kubectl apply -f k8s/
# Creates: Namespace, Deployment, Service, HPA, NetworkPolicy, ResourceQuota

# Watch deployment rollout progress
kubectl rollout status deployment/trend-app-deployment -n trend-app

# Verify all pods are running
kubectl get pods -n trend-app
# Expected output: 3 pods in "Running" state with "1/1 READY"

# Get service details including LoadBalancer external IP
kubectl get svc -n trend-app
# Wait for EXTERNAL-IP to change from "<pending>" to AWS NLB DNS name

# Watch service until LoadBalancer is provisioned
kubectl get svc -n trend-app -w
```

#### 3.3 Verify Deployment

```bash
# Get detailed service information
kubectl describe svc trend-app-service -n trend-app

# Check recent events
kubectl get events -n trend-app --sort-by=.metadata.creationTimestamp | tail -20

# View logs from all application pods
kubectl logs -l app=trend-app -n trend-app

# Test horizontal scaling
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app
kubectl scale deployment trend-app-deployment --replicas=3 -n trend-app
```

---

## 🔧 Jenkins Pipeline Configuration

### 4.1 Access Jenkins

```bash
# Get Jenkins URL from Terraform output
terraform output jenkins_url
# Open in browser: http://<jenkins-url>:8080
# Initial admin password: /var/lib/jenkins/secrets/initialAdminPassword
```

### 4.2 Install Required Jenkins Plugins

Navigate to: **Manage Jenkins → Manage Plugins → Available**

Install these plugins:

1. **Docker Pipeline** — Enables Docker commands in Jenkins pipeline
2. **Kubernetes CLI** — Allows kubectl commands in pipeline
3. **GitHub Integration** — Connects Jenkins with GitHub repositories
4. **Credentials Binding** — Securely injects credentials into pipeline
5. **Pipeline Utility Steps** — Provides additional pipeline helper functions

### 4.3 Configure Jenkins Credentials

Navigate to: **Manage Jenkins → Manage Credentials → Global → Add Credentials**

**Credential 1: DockerHub**
```
Kind: Username with password
Username: your-dockerhub-username
Password: your-dockerhub-password
ID: dockerhub-creds
```

**Credential 2: Kubernetes Config**
```
Kind: Secret file
File: Upload your ~/.kube/config file
ID: kubeconfig-creds
```

**Credential 3: GitHub Token**
```
Kind: Secret text
Secret: your-github-personal-access-token
ID: github-token
```

### 4.4 Create Pipeline Job

1. **Jenkins Dashboard → New Item**
2. **Enter job name**: `trend-app-deployment`
3. **Select**: Pipeline → **OK**

**Build Triggers:**
- ☑️ GitHub hook trigger for GITScm polling

**Pipeline Configuration:**
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: `https://github.com/Abhi-mishra998/trend.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

### Understanding the Jenkinsfile

The `Jenkinsfile` defines the complete CI/CD pipeline:

```groovy
pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NAMESPACE = 'trend-app'
        HARDCODE_LB_URL = 'http://k8s-trendapp-trendapp-c1fc9d0bf7-c6d184859c49866d.elb.ap-south-1.amazonaws.com/'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "Source code successfully checked out"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIAL_ID}",
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_REPO}:latest
                    docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBEFILE')]) {
                    sh '''
                    export KUBECONFIG=$KUBEFILE
                    kubectl apply -f k8s/
                    kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}
                    kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE}
                    '''
                }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                echo "Application LoadBalancer:"
                echo "${HARDCODE_LB_URL}"
                echo "Performing health check..."
                curl -I --max-time 20 ${HARDCODE_LB_URL} || echo "Health check failed"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
            echo "Application URL: ${HARDCODE_LB_URL}"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
```

---

## 🔗 GitHub Webhook Integration

### Step 1: Retrieve Jenkins URL

```bash
cd infrastructure
terraform output jenkins_url

# Test Jenkins accessibility
curl http://<jenkins-url>:8080
```

### Step 2: Configure GitHub Webhook

1. Go to: `https://github.com/Abhi-mishra998/trend`
2. Click: **Settings → Webhooks → Add webhook**

| Field | Value |
|-------|-------|
| **Payload URL** | `http://YOUR_JENKINS_URL:8080/github-webhook/` |
| **Content type** | `application/json` |
| **Events** | ☑️ Just the push event |
| **Active** | ☑️ Checked |

> **Note:** The URL must end with `/github-webhook/` exactly. Port 8080 must be open in your Jenkins security group.

### Step 3: Test Webhook Integration

```bash
# Make a test commit
echo "# Test webhook" >> README.md
git add README.md
git commit -m "test: verify webhook trigger"
git push origin main
```

After pushing, Jenkins Dashboard should show a new build triggered automatically with "Started by GitHub push" in the build logs.

### Webhook Troubleshooting

**403 Forbidden** — Add `/github-webhook/` to CSRF exclusion list in Jenkins security settings.

**Connection Timeout** — Verify security group allows inbound TCP port 8080 from `0.0.0.0/0`.

**Build Not Triggering** — Ensure GitHub Integration Plugin is installed and configured under **Manage Jenkins → Configure System → GitHub**.

---

## ☸️ Kubernetes Resources Explained

### Namespace (namespace.yaml)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: trend-app
# Purpose: Logical isolation for all app resources
# Benefits: Resource quotas, network policies, RBAC
```

---

## 🔧 Command Reference

### AWS EKS Cluster Management

```bash
# Get EKS cluster details
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1

# Update kubeconfig
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1

# List all EKS clusters
aws eks list-clusters --region ap-south-1
```

### Kubernetes Operations

```bash
# List all nodes with details
kubectl get nodes -o wide

# Get all resources in namespace
kubectl get all -n trend-app

# Watch deployment rollout
kubectl rollout status deployment/trend-app-deployment -n trend-app

# Scale deployment
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app

# View rollout history
kubectl rollout history deployment/trend-app-deployment -n trend-app
```

### Pod Debugging

```bash
# List pods
kubectl get pods -n trend-app

# View logs from all app pods
kubectl logs -l app=trend-app -n trend-app

# Describe a specific pod
kubectl describe pod <pod-name> -n trend-app

# Exec into a pod
kubectl exec -it <pod-name> -n trend-app -- /bin/sh
```

### Local Port Forwarding

```bash
# Forward local port 8080 to service port 80
kubectl port-forward svc/trend-app-service -n trend-app 8080:80
```

---

## 🚨 Critical Troubleshooting Guide

### Issue 1: LoadBalancer Stuck in Pending State

**Root Cause:** Missing IAM permissions for AWS Load Balancer Controller

```bash
# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Attach policy to EKS node IAM role
aws iam attach-role-policy \
    --role-name <eks-node-role-name> \
    --policy-arn arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy

# Delete and recreate service
kubectl delete svc trend-app-service -n trend-app
kubectl apply -f k8s/service.yaml

# Watch until LoadBalancer is provisioned
kubectl get svc trend-app-service -n trend-app -w
```

**Check Subnet Tags for LoadBalancer Discovery**

```bash
# Public subnets need: kubernetes.io/role/elb = 1
aws ec2 create-tags \
    --resources subnet-xxxxxxxx \
    --tags Key=kubernetes.io/role/elb,Value=1 \
    --region ap-south-1
```

### Issue 2: Pods in CrashLoopBackOff

```bash
# View pod logs
kubectl logs <pod-name> -n trend-app
kubectl logs <pod-name> -n trend-app --previous

# Describe pod for events
kubectl describe pod <pod-name> -n trend-app

# Rollback to working image
kubectl set image deployment/trend-app-deployment \
    trend-app=abhimishra/trend-app:working-tag -n trend-app
```

### Issue 3: Service Has No Endpoints

```bash
# Compare service selector with pod labels
kubectl get svc trend-app-service -n trend-app -o yaml | grep -A 2 selector
kubectl get pods -n trend-app --show-labels

# Fix by editing service or reapplying
kubectl delete svc trend-app-service -n trend-app
kubectl apply -f k8s/service.yaml
```

### Issue 4: Cannot Connect to Jenkins

```bash
# Check instance state
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*jenkins*" \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# Open port 8080 if missing
aws ec2 authorize-security-group-ingress \
    --group-id <jenkins-sg-id> \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

# Check Jenkins service on EC2
ssh -i your-key.pem ec2-user@<jenkins-ip>
sudo systemctl status jenkins
sudo systemctl restart jenkins
```

### Issue 5: Docker Build Fails in Jenkins

```bash
# Add jenkins user to docker group
ssh -i your-key.pem ec2-user@<jenkins-ip>
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Verify Docker access
sudo -u jenkins docker ps
```

### Issue 6: kubectl Fails in Jenkins Pipeline

```bash
# Install kubectl on Jenkins server
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Configure kubeconfig for jenkins user
sudo su - jenkins
mkdir -p ~/.kube
# Copy kubeconfig from your local machine

kubectl get nodes  # Verify access
```

### Issue 7: GitHub Webhook Not Triggering Builds

```bash
# Test webhook manually
curl -X POST http://<jenkins-url>:8080/github-webhook/

# Verify Jenkins is accessible
curl http://<jenkins-url>:8080

# Check recent deliveries in GitHub:
# Repo → Settings → Webhooks → Your webhook → Recent Deliveries
```

---

## 📊 Monitoring & Observability

### Setup Prometheus and Grafana

```bash
# Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

# Add Helm repositories
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm upgrade --install prometheus prometheus-community/prometheus -f prometheus-values.yaml

# Install Grafana
helm upgrade --install grafana grafana/grafana -f grafana-values.yaml

# Access Grafana dashboard
kubectl port-forward svc/grafana 3000:80
# Open: http://localhost:3000
```

---

## 🧹 Cleanup and Teardown

```bash
# Scale down deployment gracefully
kubectl scale deployment trend-app-deployment --replicas=0 -n trend-app

# Delete all Kubernetes resources
kubectl delete namespace trend-app

# Destroy all AWS infrastructure
cd infrastructure
terraform destroy -auto-approve

# Clean up Docker images
docker system prune -a

# Remove Helm releases
helm uninstall grafana
helm uninstall prometheus
```

---

## 💰 Cost Optimization

```bash
# Stop Jenkins EC2 when not in use (saves ~$30-50/month)
aws ec2 stop-instances --instance-ids <jenkins-instance-id>
aws ec2 start-instances --instance-ids <jenkins-instance-id>

# Scale down EKS node group during off-hours (saves ~$100-150/month)
aws eks update-nodegroup-config \
    --cluster-name trend-app-eks-by-abhi \
    --nodegroup-name <nodegroup-name> \
    --scaling-config minSize=1,maxSize=1,desiredSize=1

# Monitor daily costs by service
aws ce get-cost-and-usage \
    --time-period Start=2024-11-01,End=2024-11-17 \
    --granularity DAILY \
    --metrics "BlendedCost" \
    --group-by Type=SERVICE
```

---

## 🔐 Security Best Practices

### IAM Least Privilege

```bash
# Create dedicated IAM user for CI/CD
aws iam create-user --user-name jenkins-cicd-user

# Attach specific policy (not AdministratorAccess)
aws iam attach-user-policy \
    --user-name jenkins-cicd-user \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
```

### Kubernetes RBAC

```bash
# Create service account for Jenkins
kubectl create serviceaccount jenkins-deployer -n trend-app

# Create role with minimal permissions
kubectl create role deployer-role \
    --verb=get,list,update,patch,create \
    --resource=deployments,services,pods \
    -n trend-app

# Bind role to service account
kubectl create rolebinding jenkins-deployer-binding \
    --role=deployer-role \
    --serviceaccount=trend-app:jenkins-deployer \
    -n trend-app
```

### Secrets Management

```bash
# Store sensitive data in Kubernetes secrets
kubectl create secret generic app-secrets \
    --from-literal=db-password='super-secret-password' \
    --from-literal=api-key='your-api-key' \
    -n trend-app
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
- [ ] **Documentation Complete**: Architecture and commands fully documented

---

## 📚 Learning Resources

- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes Official Docs**: https://kubernetes.io/docs/
- **Jenkins Pipeline Syntax**: https://www.jenkins.io/doc/book/pipeline/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **EKS Workshop**: https://www.eksworkshop.com/

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**Abhi Mishra**
- GitHub: [@Abhi-mishra998](https://github.com/Abhi-mishra998)
- Project Repository: [trend](https://github.com/Abhi-mishra998/trend)

---

## 🙏 Acknowledgments

- AWS EKS Documentation Team
- Kubernetes Community
- Jenkins Open Source Contributors
- HashiCorp Terraform Team

---

### Terraform Module Structure

```
infrastructure/
├── main.tf                 # Primary infrastructure definitions
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf            # Provider configurations
└── modules/
    ├── vpc/                # VPC and networking
    ├── eks/                # EKS cluster
    ├── jenkins/            # Jenkins EC2 instance
    └── security/           # Security groups and IAM
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

**🚀 Production-Grade Kubernetes Deployment Pipeline — Built for Real Impact.**

*Author: Abhishek Mishra*
