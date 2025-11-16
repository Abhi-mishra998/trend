# Trend App - AWS EKS Deployment with Jenkins CI/CD

Complete DevOps project deploying a React application to AWS EKS using Jenkins pipeline.

## 🎯 Project Overview

This project demonstrates a complete CI/CD pipeline that:

- Builds a React application from source
- Creates Docker containers
- Deploys to AWS EKS (Kubernetes)
- Uses Jenkins for automation
- Integrates with GitHub webhooks

**Application**: React app from https://github.com/Vennilavan12/Trend.git
**Infrastructure**: AWS EKS with 3 nodes, Jenkins EC2 instance
**CI/CD**: Jenkins declarative pipeline with GitHub integration

---

## 🚀 Quick Deployment

```bash
# 1. Clone and setup
git clone <your-repo-url>
cd trend-app-devops

# 2. Configure AWS and DockerHub
# Edit infrastructure/variables.tf with your values

# 3. Deploy infrastructure
cd infrastructure
terraform init
terraform plan
terraform apply

# 4. Configure Jenkins
# - Install plugins: Docker, Kubernetes, Git
# - Add credentials: DockerHub, AWS, kubeconfig
# - Create pipeline job with Jenkinsfile

# 5. Setup GitHub webhook
# - Add webhook to trigger Jenkins on push
```

---

## 📋 Prerequisites

- AWS Account with EKS permissions
- DockerHub account
- GitHub repository
- Jenkins server (deployed via Terraform)

---

## 🏗️ Architecture

### AWS Infrastructure (Terraform)

- VPC with public/private subnets
- EKS Cluster (Kubernetes 1.31)
- 3x t3.large worker nodes
- Jenkins EC2 instance
- Security groups and IAM roles

### Jenkins Pipeline Stages

1. **Checkout** - Pull code from GitHub
2. **Install Dependencies** - npm install
3. **Build Application** - npm run build
4. **Build Docker Image** - Create container
5. **Push to DockerHub** - Upload image
6. **Deploy to Kubernetes** - Update EKS deployment
7. **Verify Deployment** - Health checks

### Kubernetes Resources

- Namespace: `trend-app`
- Deployment with 3 replicas
- LoadBalancer service (NLB)
- Horizontal Pod Autoscaler
- Network policies and resource quotas

---

## 📊 Jenkins Pipeline (Jenkinsfile)

The `Jenkinsfile` defines a declarative pipeline with:

```groovy
pipeline {
    agent any
    environment {
        DOCKERHUB_REPO = 'your-repo/trend-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        NAMESPACE = 'trend-app'
    }
    stages {
        stage('Checkout Code') { /* Git checkout */ }
        stage('Install Dependencies') { /* npm install */ }
        stage('Build Application') { /* npm run build */ }
        stage('Build Docker Image') { /* docker build */ }
        stage('Push to DockerHub') { /* docker push */ }
        stage('Deploy to Kubernetes') { /* kubectl apply */ }
        stage('Verify Deployment') { /* health checks */ }
    }
}
```

---

## 🔧 Jenkins Configuration

### Required Plugins

- Docker Pipeline
- Kubernetes CLI
- GitHub Integration
- Credentials Binding

### Credentials Needed

- `dockerhub-creds`: DockerHub username/password
- `kubeconfig-creds`: EKS kubeconfig file

### Pipeline Job Setup

1. Create new Pipeline job
2. Point to Jenkinsfile in repository
3. Configure GitHub webhook trigger

---

## 🔗 GitHub Webhook Configuration

### Step 1: Get Jenkins URL

```bash
# After Terraform deployment, get Jenkins URL
cd infrastructure
terraform output jenkins_url
# Example output: ec2-13-234-56-789.ap-south-1.compute.amazonaws.com
```

### Step 2: Configure Webhook in GitHub

1. **Go to GitHub Repository**:

   - Open your repository on GitHub
   - Click **Settings** tab
   - Click **Webhooks** in left sidebar
   - Click **Add webhook**

2. **Webhook Settings**:

   ```
   Payload URL: http://YOUR_JENKINS_URL:8080/github-webhook/
   Content type: application/json
   Secret: (leave empty or add a secret for security)
   Which events: Just the push event
   Active: ✅ Checked
   ```

3. **Replace YOUR_JENKINS_URL** with the actual Jenkins EC2 public IP/DNS from Terraform output

### Step 3: Configure Jenkins for Webhook

1. **Install GitHub Plugin** (if not already installed):

   - Jenkins Dashboard → Manage Jenkins → Manage Plugins
   - Search for "GitHub Integration" → Install

2. **Configure GitHub in Jenkins**:

   - Manage Jenkins → Configure System
   - Find "GitHub" section
   - Add GitHub Server:
     - Name: GitHub
     - API URL: https://api.github.com
     - Credentials: Add GitHub Personal Access Token

3. **Update Pipeline Job**:
   - Open your pipeline job
   - Check "GitHub hook trigger for GITScm polling"
   - Save the job

### Step 4: Test Webhook

1. **Push a change** to your repository
2. **Check Jenkins** - Pipeline should trigger automatically
3. **Verify** webhook delivery in GitHub:
   - Repository Settings → Webhooks
   - Click on your webhook
   - Check "Recent Deliveries"

### Troubleshooting Webhook Issues

**Webhook not triggering:**

- Verify Jenkins URL is accessible (no firewall blocking port 8080)
- Check webhook URL format: `http://jenkins-url:8080/github-webhook/`
- Ensure GitHub plugin is installed and configured

**403 Forbidden error:**

- Jenkins CSRF protection might be enabled
- Add `/github-webhook/` to CSRF exempt URLs

**Connection failed:**

- Ensure Jenkins security is not blocking anonymous access
- Check if Jenkins is running and accessible from internet

---

## 📁 Project Structure

```
Trend-by-Abhi/
├── Jenkinsfile              # CI/CD pipeline definition
├── Dockerfile               # Container build instructions
├── infrastructure/          # Terraform AWS setup
│   ├── main.tf             # EKS, VPC, Jenkins EC2
│   ├── modules/            # Reusable Terraform modules
│   └── variables.tf        # Configuration variables
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml     # App deployment
│   ├── service.yaml        # LoadBalancer service
│   ├── hpa.yaml           # Auto-scaling
│   └── network-policy.yaml # Security policies
├── monitoring/             # Prometheus + Grafana (optional)
└── README.md              # This file
```

---

## ✅ Verification Steps

```bash
# Check EKS cluster
kubectl get nodes
kubectl get pods -n trend-app

# Get application URL
kubectl get svc trend-app-service -n trend-app

# Check Jenkins
# Access Jenkins UI and verify pipeline
```

---

## 🎓 Learning Outcomes

This project covers:

- Infrastructure as Code (Terraform)
- Container orchestration (Kubernetes)
- CI/CD automation (Jenkins)
- Cloud deployment (AWS EKS)
- GitOps practices
- Monitoring and logging

---

## 📸 Submission Requirements

For project evaluation, provide:

1. **GitHub Repository Link** - Complete codebase
2. **Jenkins Pipeline Screenshots** - Build success
3. **EKS Cluster Screenshot** - AWS Console
4. **Application Screenshot** - Running in browser
5. **LoadBalancer ARN** - AWS resource identifier
6. **kubectl outputs** - Pod and service status

---

## 🧹 Cleanup

```bash
# Destroy infrastructure
cd infrastructure
terraform destroy

# Delete Docker images
docker system prune -a
```

---

## 📝 Notes

- **Cost**: ~$3-5/day for t3.large instances
- **Time**: 20-30 minutes deployment
- **Region**: ap-south-1 (configurable)
- **Kubernetes**: v1.31
- **Jenkins**: Latest LTS version

---

## 🔗 Useful Commands

```bash
# Jenkins
jenkins_url=$(terraform output -raw jenkins_url)
echo "Jenkins: http://$jenkins_url:8080"

# Kubernetes
kubectl get all -n trend-app
kubectl logs -l app=trend-app -n trend-app

# Docker
docker images | grep trend-app
```

---

**Ready to deploy? Follow the steps above and configure Jenkins for automated deployments!**
