# Complete Setup Guide - Trend App DevOps

This guide will walk you through setting up and deploying the Trend App to AWS EKS step-by-step.

---

## 📋 Table of Contents

1. [Prerequisites Installation](#prerequisites-installation)
2. [AWS Configuration](#aws-configuration)
3. [Project Configuration](#project-configuration)
4. [Deployment](#deployment)
5. [Verification](#verification)
6. [Troubleshooting Commands](#troubleshooting-commands)
7. [Cleanup](#cleanup)

---

## Prerequisites Installation

### Required Tools

You need these tools installed on your Windows machine:

#### 1.1 Git Bash (Required)

```powershell
# Download and install Git for Windows
# URL: https://git-scm.com/download/win
# This includes Git Bash which you'll use to run all scripts
```

**Verify:**

```bash
git --version
# Should show: git version 2.x.x
```

#### 1.2 AWS CLI (Required)

```powershell
# Download AWS CLI v2 for Windows
# URL: https://awscli.amazonaws.com/AWSCLIV2.msi
# Or use Chocolatey:
choco install awscli
```

**Verify:**

```bash
aws --version
# Should show: aws-cli/2.x.x
```

#### 1.3 Terraform (Required)

```powershell
# Download Terraform
# URL: https://www.terraform.io/downloads
# Or use Chocolatey:
choco install terraform
```

**Verify:**

```bash
terraform --version
# Should show: Terraform v1.5.x or higher
```

#### 1.4 Docker Desktop (Required)

```powershell
# Download Docker Desktop for Windows
# URL: https://www.docker.com/products/docker-desktop
```

**Verify:**

```bash
docker --version
# Should show: Docker version 20.x.x or higher

docker ps
# Should show running containers or empty list (not an error)
```

#### 1.5 kubectl (Required)

```powershell
# Download kubectl
# URL: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
# Or use Chocolatey:
choco install kubernetes-cli
```

**Verify:**

```bash
kubectl version --client
# Should show: Client Version: v1.27.x or higher
```

---

## AWS Configuration

### 2.1 Get AWS Credentials

You need an AWS account with administrator access or these permissions:

- EC2 (full access)
- EKS (full access)
- IAM (full access)
- VPC (full access)
- Elastic Load Balancing (full access)

### 2.2 Configure AWS CLI

Open **Git Bash** and run:

```bash
aws configure
```

Enter your credentials:

```
AWS Access Key ID: [Your Access Key]
AWS Secret Access Key: [Your Secret Key]
Default region name: us-east-1
Default output format: json
```

### 2.3 Verify AWS Configuration

```bash
# Check if credentials work
aws sts get-caller-identity
```

**Expected output:**

```json
{
  "UserId": "AIDAXXXXXXXXXX",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

**Save your Account ID** - you'll need it in the next step!

---

## Project Configuration

### 3.1 Clone or Navigate to Project

```bash
cd /c/path/to/trend-app-devops
```

### 3.2 Run Setup Wizard

The setup wizard will create your `config.yaml` file:

```bash
bash scripts/setup-wizard.sh
```

**You'll be asked for:**

1. **AWS Account ID** (12 digits from step 2.3)

   - Example: `123456789012`

2. **AWS Region**

   - Recommended: `us-east-1`
   - Other options: `us-west-2`, `eu-west-1`

3. **AWS CLI Profile**

   - Default: `default`
   - Press Enter to use default

4. **DockerHub Username**

   - Your DockerHub username
   - Example: `abhishek8056`

5. **DockerHub Repository**

   - Format: `username/trend-app`
   - Example: `abhishek8056/trend-app`

6. **Infrastructure Sizing**

   - Jenkins Instance: `t3.medium` (recommended)
   - EKS Node Instance: `t3.medium` (recommended)
   - Node Count: Desired `2`, Min `1`, Max `4`

7. **Monitoring**
   - Enable monitoring: `yes` or `no`
   - Grafana password: (if enabled)

### 3.3 Verify Configuration

```bash
# Check if config.yaml was created
cat config.yaml

# Should show your AWS Account ID, region, DockerHub repo, etc.
```

### 3.4 Validate Prerequisites

```bash
bash scripts/validate-prerequisites.sh
```

This checks:

- ✅ All required tools installed
- ✅ AWS credentials valid
- ✅ AWS permissions sufficient
- ✅ Configuration file valid

**If any checks fail, fix them before proceeding!**

---

## Deployment

### 4.1 Deploy Everything

This single command deploys the entire infrastructure:

```bash
bash scripts/deploy-all.sh
```

**What happens:**

1. ✅ Validates prerequisites
2. ✅ Initializes Terraform
3. ✅ Provisions AWS infrastructure (VPC, EKS, Jenkins) - **~15 minutes**
4. ✅ Generates kubeconfig for EKS
5. ✅ Deploys Kubernetes resources
6. ✅ Installs monitoring (if enabled)
7. ✅ Verifies deployment

**Total time: 20-35 minutes**

### 4.2 What Gets Created

**AWS Resources:**

- VPC with public/private subnets
- EKS Cluster (Kubernetes)
- EKS Node Group (2 worker nodes)
- Jenkins EC2 instance
- Security Groups
- IAM Roles
- Load Balancer (for your app)

**Kubernetes Resources:**

- Namespace: `trend-app`
- Deployment: `trend-app-deployment`
- Service: `trend-app-service` (LoadBalancer)
- HPA: Horizontal Pod Autoscaler

---

## Verification

### 5.1 Check Infrastructure

```bash
# Check Terraform state
cd infrastructure
terraform output

# Should show:
# - vpc_id
# - eks_cluster_name
# - jenkins_url
# - etc.
```

### 5.2 Check Kubernetes Cluster

```bash
# Check cluster connection
kubectl cluster-info

# Check nodes
kubectl get nodes
# Should show 2 nodes in Ready state

# Check namespaces
kubectl get namespaces
# Should show trend-app namespace
```

### 5.3 Check Application

```bash
# Check pods
kubectl get pods -n trend-app
# Should show pods in Running state

# Check service
kubectl get svc -n trend-app
# Should show LoadBalancer with EXTERNAL-IP

# Get application URL
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Wait 5-10 minutes for LoadBalancer to be fully ready, then access:**

```
http://[EXTERNAL-IP or HOSTNAME]
```

### 5.4 Check Jenkins

```bash
# Get Jenkins URL
cd infrastructure
terraform output jenkins_url
```

Access Jenkins at the URL shown.

---

## Troubleshooting Commands

### 6.1 AWS Issues

#### Check AWS Credentials

```bash
aws sts get-caller-identity
# If this fails, run: aws configure
```

#### Check AWS Permissions

```bash
# Test EC2 access
aws ec2 describe-vpcs --max-results 1

# Test EKS access
aws eks list-clusters

# Test IAM access
aws iam list-roles --max-items 1
```

#### Check AWS Region

```bash
aws configure get region
# Should match your config.yaml region
```

### 6.2 Terraform Issues

#### Check Terraform State

```bash
cd infrastructure
terraform show
```

#### Validate Terraform Configuration

```bash
cd infrastructure
terraform validate
```

#### Check Terraform Plan

```bash
cd infrastructure
terraform plan
```

#### Fix Terraform Lock Issues

```bash
cd infrastructure
rm -rf .terraform
rm .terraform.lock.hcl
terraform init
```

#### View Terraform Logs

```bash
# Check deployment logs
cat logs/deployment-*.log | tail -100
```

### 6.3 Kubernetes Issues

#### Check Cluster Connection

```bash
kubectl cluster-info
# If fails, regenerate kubeconfig:
aws eks update-kubeconfig --name trend-app-eks --region us-east-1
```

#### Check Pods Status

```bash
# List all pods
kubectl get pods -n trend-app

# Describe specific pod
kubectl describe pod <pod-name> -n trend-app

# View pod logs
kubectl logs <pod-name> -n trend-app

# Follow pod logs
kubectl logs -f <pod-name> -n trend-app
```

#### Check Pod Events

```bash
# See recent events
kubectl get events -n trend-app --sort-by='.lastTimestamp'

# Watch events in real-time
kubectl get events -n trend-app --watch
```

#### Check Deployments

```bash
# List deployments
kubectl get deployments -n trend-app

# Describe deployment
kubectl describe deployment trend-app-deployment -n trend-app

# Check deployment rollout status
kubectl rollout status deployment/trend-app-deployment -n trend-app
```

#### Check Services

```bash
# List services
kubectl get svc -n trend-app

# Describe service
kubectl describe svc trend-app-service -n trend-app

# Get LoadBalancer URL
kubectl get svc trend-app-service -n trend-app -o wide
```

#### Restart Pods

```bash
# Restart deployment (recreates pods)
kubectl rollout restart deployment/trend-app-deployment -n trend-app
```

#### Scale Application

```bash
# Scale to 3 replicas
kubectl scale deployment trend-app-deployment --replicas=3 -n trend-app

# Check scaling
kubectl get pods -n trend-app
```

### 6.4 Docker Issues

#### Check Docker Running

```bash
docker ps
# If error, start Docker Desktop
```

#### Test Docker Build

```bash
# Build image locally
docker build -t trend-app:test .

# Run locally
docker run -d -p 3000:3000 trend-app:test

# Check if running
curl http://localhost:3000
```

#### Check Docker Images

```bash
# List images
docker images

# Remove old images
docker image prune -a
```

### 6.5 Image Pull Issues

#### Check DockerHub Image

```bash
# Try pulling your image
docker pull abhishek8056/trend-app:latest

# If fails, check if image exists on DockerHub
```

#### Push Image to DockerHub

```bash
# Login to DockerHub
docker login

# Build and tag
docker build -t abhishek8056/trend-app:latest .

# Push
docker push abhishek8056/trend-app:latest
```

### 6.6 LoadBalancer Issues

#### Check LoadBalancer Status

```bash
# Get LoadBalancer details
kubectl describe svc trend-app-service -n trend-app

# Check AWS LoadBalancer
aws elbv2 describe-load-balancers --region us-east-1
```

#### Wait for LoadBalancer

```bash
# LoadBalancers take 5-10 minutes to provision
# Check status every minute:
watch -n 60 'kubectl get svc -n trend-app'
```

### 6.7 Node Issues

#### Check Node Status

```bash
# List nodes
kubectl get nodes

# Describe node
kubectl describe node <node-name>

# Check node resources
kubectl top nodes
```

#### Check Node Logs

```bash
# SSH to node (if needed)
# Get node instance ID from AWS console
aws ssm start-session --target <instance-id>
```

### 6.8 Deployment Logs

#### View Deployment Logs

```bash
# Latest deployment log
cat logs/deployment-*.log | tail -200

# Search for errors
grep -i error logs/deployment-*.log

# Search for specific phase
grep -i "terraform" logs/deployment-*.log
```

### 6.9 Configuration Issues

#### Verify Config File

```bash
# Check config.yaml
cat config.yaml

# Check for placeholders
grep "{{" k8s/*.yaml Jenkinsfile infrastructure/variables.tf

# Re-apply configuration
bash scripts/apply-config.sh
```

#### Reset Configuration

```bash
# Backup current config
cp config.yaml config.yaml.backup

# Run setup wizard again
bash scripts/setup-wizard.sh
```

### 6.10 Network Issues

#### Check Connectivity

```bash
# Test AWS connectivity
curl -I https://aws.amazon.com

# Test DockerHub connectivity
curl -I https://hub.docker.com

# Test DNS
nslookup aws.amazon.com
```

#### Check Security Groups

```bash
# List security groups
aws ec2 describe-security-groups --region us-east-1

# Check specific security group
aws ec2 describe-security-groups --group-ids <sg-id> --region us-east-1
```

---

## Cleanup

### 7.1 Delete Everything

When you're done learning, delete all resources to avoid AWS charges:

```bash
bash scripts/cleanup-all.sh
```

**This will:**

1. Delete Kubernetes resources
2. Wait for LoadBalancers to be removed
3. Destroy Terraform infrastructure
4. Verify cleanup

**Time: 10-15 minutes**

### 7.2 Verify Cleanup

```bash
# Check if EKS cluster deleted
aws eks list-clusters --region us-east-1

# Check if VPC deleted
aws ec2 describe-vpcs --region us-east-1

# Check Terraform state
cd infrastructure
terraform show
# Should show: No state
```

### 7.3 Manual Cleanup (if automated fails)

If cleanup script fails, manually delete from AWS Console:

1. **EKS** → Delete cluster `trend-app-eks`
2. **EC2** → Terminate Jenkins instance
3. **EC2 → Load Balancers** → Delete all trend-app LBs
4. **VPC** → Delete VPC (this deletes subnets, route tables, etc.)
5. **IAM** → Delete roles starting with `trend-app-`

### 7.4 Check AWS Costs

```bash
# Check current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost
```

---

## 8. Common Issues & Solutions

### Issue: "AWS credentials not configured"

**Solution:**

```bash
aws configure
# Enter your Access Key, Secret Key, region
```

### Issue: "Terraform initialization failed"

**Solution:**

```bash
cd infrastructure
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: "EKS cluster not accessible"

**Solution:**

```bash
# Regenerate kubeconfig
aws eks update-kubeconfig --name trend-app-eks --region us-east-1

# Test connection
kubectl get nodes
```

### Issue: "Pods stuck in ImagePullBackOff"

**Solution:**

```bash
# Check if image exists
docker pull abhishek8056/trend-app:latest

# If not, build and push:
docker build -t abhishek8056/trend-app:latest .
docker push abhishek8056/trend-app:latest

# Restart deployment
kubectl rollout restart deployment/trend-app-deployment -n trend-app
```

### Issue: "LoadBalancer stuck in Pending"

**Solution:**

```bash
# Wait 10 minutes - LoadBalancers take time
# Check events
kubectl describe svc trend-app-service -n trend-app

# Check AWS console for LoadBalancer creation
```

### Issue: "Terraform destroy fails"

**Solution:**

```bash
# Delete Kubernetes resources first
kubectl delete namespace trend-app --force --grace-period=0

# Wait 5 minutes for LoadBalancers to delete
sleep 300

# Try destroy again
cd infrastructure
terraform destroy -auto-approve
```

### Issue: "Insufficient permissions"

**Solution:**

```bash
# Check your IAM user permissions in AWS Console
# You need: EC2, EKS, IAM, VPC, ELB full access

# Test permissions
aws ec2 describe-vpcs --max-results 1
aws eks list-clusters
aws iam list-roles --max-items 1
```

---

## 9. Quick Reference

### Essential Commands

```bash
# Setup
bash scripts/setup-wizard.sh
bash scripts/validate-prerequisites.sh

# Deploy
bash scripts/deploy-all.sh

# Check Status
kubectl get all -n trend-app
kubectl get nodes
kubectl get svc -n trend-app

# View Logs
kubectl logs -f deployment/trend-app-deployment -n trend-app
cat logs/deployment-*.log

# Cleanup
bash scripts/cleanup-all.sh
```

### Important Files

- `config.yaml` - Your configuration (created by setup wizard)
- `logs/deployment-*.log` - Deployment logs
- `infrastructure/terraform.tfstate` - Terraform state
- `~/.kube/config` - Kubernetes configuration

### Important URLs

After deployment, get URLs:

```bash
# Application URL
kubectl get svc trend-app-service -n trend-app

# Jenkins URL
cd infrastructure && terraform output jenkins_url
```

---

## 10. What to Change

### Before Deployment

**File: `config.yaml`** (created by setup wizard)

- ✅ AWS Account ID
- ✅ AWS Region
- ✅ DockerHub repository
- ✅ Instance types (if you want different sizes)

**No other files need manual editing!** The scripts handle everything else.

### After Deployment

**To scale your app:**

```bash
# Edit k8s/deployment.yaml
# Change: replicas: 2 to replicas: 5

# Apply changes
kubectl apply -f k8s/deployment.yaml
```

**To change resources:**

```bash
# Edit k8s/deployment.yaml
# Change CPU/memory limits

# Apply changes
kubectl apply -f k8s/deployment.yaml
```

---

## 11. Learning Resources

- **AWS EKS**: https://docs.aws.amazon.com/eks/
- **Kubernetes**: https://kubernetes.io/docs/
- **Terraform**: https://www.terraform.io/docs/
- **Docker**: https://docs.docker.com/

---

## Need Help?

1. Check the troubleshooting section above
2. Review deployment logs: `cat logs/deployment-*.log`
3. Check pod status: `kubectl get pods -n trend-app`
4. Check events: `kubectl get events -n trend-app --sort-by='.lastTimestamp'`

**Remember:** This is a learning project. Don't worry if things fail - that's how you learn! Use the troubleshooting commands to understand what went wrong.

## 🚀 Quick Deploy in 5 Steps

```powershell
# 1. Prepare React app (5 min)
npm install && npm run build

# 2. Deploy infrastructure (10 min)
cd infrastructure && terraform apply

# 3. Deploy Kubernetes (5 min)
kubectl apply -f k8s/

# 4. Configure Jenkins (15 min)
# Follow JENKINS_SETUP.md

# 5. Run pipeline & verify (5 min)
# Build in Jenkins, verify deployment
```

---

**Good luck with your DevOps learning journey! 🚀**
