# Command Reference - Trend App DevOps

Quick reference for all commands you'll need to run this project.

---

## 📋 Table of Contents

1. [Setup Commands](#setup-commands)
2. [Docker Commands](#docker-commands)
3. [AWS Commands](#aws-commands)
4. [Terraform Commands](#terraform-commands)
5. [Kubernetes Commands](#kubernetes-commands)
6. [Deployment Commands](#deployment-commands)
7. [Monitoring Commands](#monitoring-commands)
8. [Troubleshooting Commands](#troubleshooting-commands)
9. [Cleanup Commands](#cleanup-commands)

---

## Setup Commands

### Check Tool Versions

```bash
# Check Git
git --version

# Check AWS CLI
aws --version

# Check Terraform
terraform --version

# Check Docker
docker --version

# Check kubectl
kubectl version --client

# Check all at once
echo "Git:" && git --version && \
echo "AWS:" && aws --version && \
echo "Terraform:" && terraform --version && \
echo "Docker:" && docker --version && \
echo "kubectl:" && kubectl version --client
```

### Configure AWS

```bash
# Configure AWS credentials
aws configure

# Check AWS configuration
aws configure list

# Get AWS Account ID
aws sts get-caller-identity

# Get AWS Account ID only
aws sts get-caller-identity --query Account --output text

# Get AWS Region
aws configure get region
```

### Run Setup Wizard

```bash
# Run interactive setup
bash scripts/setup-wizard.sh

# View generated config
cat config.yaml

# Validate prerequisites
bash scripts/validate-prerequisites.sh
```

---

## Docker Commands

### Basic Docker Operations

```bash
# Check Docker is running
docker ps

# List all containers
docker ps -a

# List Docker images
docker images

# Check Docker info
docker info

# Check Docker version
docker version
```

### Build Docker Image

```bash
# Build image (basic)
docker build -t trend-app .

# Build with tag
docker build -t trend-app:latest .

# Build with your DockerHub username
docker build -t abhishek8056/trend-app:latest .

# Build with no cache
docker build --no-cache -t trend-app:latest .

# Build and show progress
docker build -t trend-app:latest . --progress=plain
```

### Run Docker Container Locally

```bash
# Run container
docker run -d -p 3000:3000 trend-app:latest

# Run with name
docker run -d --name trend-app-test -p 3000:3000 trend-app:latest

# Run and view logs
docker run -p 3000:3000 trend-app:latest

# Test if running
curl http://localhost:3000
```

### Docker Container Management

```bash
# List running containers
docker ps

# Stop container
docker stop trend-app-test

# Start container
docker start trend-app-test

# Restart container
docker restart trend-app-test

# Remove container
docker rm trend-app-test

# Stop and remove
docker stop trend-app-test && docker rm trend-app-test

# View container logs
docker logs trend-app-test

# Follow container logs
docker logs -f trend-app-test

# Execute command in container
docker exec -it trend-app-test sh
```

### DockerHub Operations

```bash
# Login to DockerHub
docker login

# Login with username
docker login -u abhishek8056

# Tag image for DockerHub
docker tag trend-app:latest abhishek8056/trend-app:latest

# Push to DockerHub
docker push abhishek8056/trend-app:latest

# Pull from DockerHub
docker pull abhishek8056/trend-app:latest

# Logout
docker logout
```

### Docker Cleanup

```bash
# Remove image
docker rmi trend-app:latest

# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a

# Remove all unused volumes
docker volume prune

# Remove everything unused
docker system prune -a

# Check disk usage
docker system df
```

---

## AWS Commands

### AWS Account & Credentials

```bash
# Get caller identity
aws sts get-caller-identity

# Get Account ID
aws sts get-caller-identity --query Account --output text

# Get User ARN
aws sts get-caller-identity --query Arn --output text

# List AWS profiles
aws configure list-profiles

# Use specific profile
aws --profile myprofile sts get-caller-identity
```

### AWS EC2 Commands

```bash
# List VPCs
aws ec2 describe-vpcs

# List EC2 instances
aws ec2 describe-instances

# List running instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# List security groups
aws ec2 describe-security-groups

# List key pairs
aws ec2 describe-key-pairs
```

### AWS EKS Commands

```bash
# List EKS clusters
aws eks list-clusters

# Describe EKS cluster
aws eks describe-cluster --name trend-app-eks

# Update kubeconfig for EKS
aws eks update-kubeconfig --name trend-app-eks --region us-east-1

# List node groups
aws eks list-nodegroups --cluster-name trend-app-eks

# Describe node group
aws eks describe-nodegroup --cluster-name trend-app-eks --nodegroup-name <nodegroup-name>
```

### AWS Load Balancer Commands

```bash
# List load balancers
aws elbv2 describe-load-balancers

# List target groups
aws elbv2 describe-target-groups

# Describe specific load balancer
aws elbv2 describe-load-balancers --names <lb-name>
```

### AWS IAM Commands

```bash
# List IAM users
aws iam list-users

# List IAM roles
aws iam list-roles

# Get current user
aws iam get-user

# List attached policies
aws iam list-attached-user-policies --user-name <username>
```

### AWS Region Commands

```bash
# List all regions
aws ec2 describe-regions --output table

# Get current region
aws configure get region

# Set region
aws configure set region us-east-1
```

---

## Terraform Commands

### Terraform Initialization

```bash
# Navigate to infrastructure directory
cd infrastructure

# Initialize Terraform
terraform init

# Initialize with upgrade
terraform init -upgrade

# Initialize without backend
terraform init -backend=false

# Reconfigure backend
terraform init -reconfigure
```

### Terraform Planning

```bash
# Create execution plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with specific var file
terraform plan -var-file=terraform.tfvars

# Plan and show detailed changes
terraform plan -detailed-exitcode
```

### Terraform Apply

```bash
# Apply changes (with confirmation)
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Apply saved plan
terraform apply tfplan

# Apply with specific variables
terraform apply -var="aws_region=us-east-1"
```

### Terraform Destroy

```bash
# Destroy infrastructure (with confirmation)
terraform destroy

# Destroy without confirmation
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.jenkins
```

### Terraform State

```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_eks_cluster.main

# Remove resource from state
terraform state rm aws_instance.example

# Pull remote state
terraform state pull
```

### Terraform Output

```bash
# Show all outputs
terraform output

# Show specific output
terraform output vpc_id

# Show output in JSON
terraform output -json

# Show output raw (no quotes)
terraform output -raw jenkins_url
```

### Terraform Validation

```bash
# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Format and check
terraform fmt -check

# Format recursively
terraform fmt -recursive

# Show Terraform version
terraform version
```

### Terraform Workspace

```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new dev

# Select workspace
terraform workspace select dev

# Show current workspace
terraform workspace show
```

---

## Kubernetes Commands

### Cluster Information

```bash
# Get cluster info
kubectl cluster-info

# Get cluster version
kubectl version

# Get cluster nodes
kubectl get nodes

# Describe node
kubectl describe node <node-name>

# Get node resources
kubectl top nodes
```

### Namespace Commands

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace trend-app

# Delete namespace
kubectl delete namespace trend-app

# Set default namespace
kubectl config set-context --current --namespace=trend-app
```

### Pod Commands

```bash
# List pods in namespace
kubectl get pods -n trend-app

# List all pods
kubectl get pods --all-namespaces

# Describe pod
kubectl describe pod <pod-name> -n trend-app

# Get pod logs
kubectl logs <pod-name> -n trend-app

# Follow pod logs
kubectl logs -f <pod-name> -n trend-app

# Get logs from previous container
kubectl logs <pod-name> -n trend-app --previous

# Execute command in pod
kubectl exec -it <pod-name> -n trend-app -- sh

# Execute bash in pod
kubectl exec -it <pod-name> -n trend-app -- /bin/bash

# Copy file to pod
kubectl cp localfile.txt <pod-name>:/path/in/pod -n trend-app

# Copy file from pod
kubectl cp <pod-name>:/path/in/pod/file.txt ./localfile.txt -n trend-app
```

### Deployment Commands (Kubernetes)

```bash
# List deployments
kubectl get deployments -n trend-app

# Describe deployment
kubectl describe deployment trend-app-deployment -n trend-app

# Get deployment details
kubectl get deployment trend-app-deployment -n trend-app -o yaml

# Scale deployment
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app

# Restart deployment
kubectl rollout restart deployment/trend-app-deployment -n trend-app

# Check rollout status
kubectl rollout status deployment/trend-app-deployment -n trend-app

# View rollout history
kubectl rollout history deployment/trend-app-deployment -n trend-app

# Undo rollout
kubectl rollout undo deployment/trend-app-deployment -n trend-app
```

### Service Commands

```bash
# List services
kubectl get svc -n trend-app

# List all services
kubectl get svc --all-namespaces

# Describe service
kubectl describe svc trend-app-service -n trend-app

# Get service details
kubectl get svc trend-app-service -n trend-app -o yaml

# Get LoadBalancer URL
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Get service endpoints
kubectl get endpoints -n trend-app
```

### Apply & Delete Resources

```bash
# Apply single file
kubectl apply -f k8s/deployment.yaml

# Apply all files in directory
kubectl apply -f k8s/

# Apply with namespace
kubectl apply -f k8s/deployment.yaml -n trend-app

# Delete resource
kubectl delete -f k8s/deployment.yaml

# Delete all in namespace
kubectl delete all --all -n trend-app

# Force delete pod
kubectl delete pod <pod-name> -n trend-app --force --grace-period=0
```

### Events & Debugging

```bash
# Get events
kubectl get events -n trend-app

# Get events sorted by time
kubectl get events -n trend-app --sort-by='.lastTimestamp'

# Watch events
kubectl get events -n trend-app --watch

# Get all resources
kubectl get all -n trend-app

# Get all resources with labels
kubectl get all -n trend-app --show-labels

# Get resources by label
kubectl get pods -l app=trend-app -n trend-app
```

### ConfigMaps & Secrets

```bash
# List configmaps
kubectl get configmaps -n trend-app

# Describe configmap
kubectl describe configmap <configmap-name> -n trend-app

# List secrets
kubectl get secrets -n trend-app

# Describe secret
kubectl describe secret <secret-name> -n trend-app

# Create secret from literal
kubectl create secret generic my-secret --from-literal=key=value -n trend-app
```

### Resource Usage

```bash
# Get pod resource usage
kubectl top pods -n trend-app

# Get node resource usage
kubectl top nodes

# Describe resource quotas
kubectl describe resourcequota -n trend-app

# Get HPA status
kubectl get hpa -n trend-app

# Describe HPA
kubectl describe hpa trend-app-hpa -n trend-app
```

### Port Forwarding

```bash
# Forward local port to pod
kubectl port-forward <pod-name> 8080:3000 -n trend-app

# Forward to service
kubectl port-forward svc/trend-app-service 8080:80 -n trend-app

# Forward to deployment
kubectl port-forward deployment/trend-app-deployment 8080:3000 -n trend-app
```

---

## Deployment Commands

### Full Deployment

```bash
# Run complete deployment
bash scripts/deploy-all.sh

# View deployment logs
cat logs/deployment-*.log

# View last 100 lines of log
tail -100 logs/deployment-*.log

# Follow deployment log
tail -f logs/deployment-*.log
```

### Step-by-Step Deployment

```bash
# 1. Setup configuration
bash scripts/setup-wizard.sh

# 2. Validate prerequisites
bash scripts/validate-prerequisites.sh

# 3. Apply configuration
bash scripts/apply-config.sh

# 4. Initialize Terraform
cd infrastructure
terraform init

# 5. Plan infrastructure
terraform plan

# 6. Apply infrastructure
terraform apply -auto-approve

# 7. Update kubeconfig
aws eks update-kubeconfig --name trend-app-eks --region us-east-1

# 8. Deploy Kubernetes resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# 9. Verify deployment
kubectl get all -n trend-app
```

### Verify Deployment

```bash
# Check all resources
kubectl get all -n trend-app

# Check pods are running
kubectl get pods -n trend-app

# Check service has external IP
kubectl get svc -n trend-app

# Check nodes are ready
kubectl get nodes

# Check deployment status
kubectl rollout status deployment/trend-app-deployment -n trend-app

# Get application URL
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

## Monitoring Commands

### Install Monitoring

```bash
# Install Prometheus and Grafana
bash monitoring/install-monitoring.sh

# Check monitoring namespace
kubectl get all -n monitoring

# Get Grafana URL
kubectl get svc -n monitoring | grep grafana
```

### Access Monitoring

```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Port forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# Get Grafana admin password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Monitoring Queries

```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Then visit: http://localhost:9090/targets

# Check metrics
kubectl top pods -n trend-app
kubectl top nodes
```

---

## Troubleshooting Commands

### Check Everything (Quick)

```bash
# Quick health check
kubectl get nodes && \
kubectl get pods -n trend-app && \
kubectl get svc -n trend-app && \
kubectl get events -n trend-app --sort-by='.lastTimestamp' | tail -10
```

### Debug Pods

```bash
# Check pod status
kubectl get pods -n trend-app

# Describe pod (shows events)
kubectl describe pod <pod-name> -n trend-app

# Get pod logs
kubectl logs <pod-name> -n trend-app

# Get previous pod logs (if crashed)
kubectl logs <pod-name> -n trend-app --previous

# Check pod events
kubectl get events -n trend-app --field-selector involvedObject.name=<pod-name>

# Execute shell in pod
kubectl exec -it <pod-name> -n trend-app -- sh

# Check pod resource usage
kubectl top pod <pod-name> -n trend-app
```

### Debug Services

```bash
# Check service
kubectl get svc trend-app-service -n trend-app

# Describe service
kubectl describe svc trend-app-service -n trend-app

# Check endpoints
kubectl get endpoints trend-app-service -n trend-app

# Test service from within cluster
kubectl run test-pod --rm -it --image=busybox -- wget -O- http://trend-app-service.trend-app.svc.cluster.local
```

### Debug Deployments

```bash
# Check deployment
kubectl get deployment trend-app-deployment -n trend-app

# Describe deployment
kubectl describe deployment trend-app-deployment -n trend-app

# Check replica sets
kubectl get rs -n trend-app

# Check rollout status
kubectl rollout status deployment/trend-app-deployment -n trend-app

# View rollout history
kubectl rollout history deployment/trend-app-deployment -n trend-app
```

### Debug Nodes

```bash
# Check nodes
kubectl get nodes

# Describe node
kubectl describe node <node-name>

# Check node conditions
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type

# Check node capacity
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### Debug Network

```bash
# Test DNS
kubectl run test-dns --rm -it --image=busybox -- nslookup kubernetes.default

# Test external connectivity
kubectl run test-net --rm -it --image=busybox -- wget -O- https://google.com

# Check network policies
kubectl get networkpolicies -n trend-app

# Check ingress
kubectl get ingress -n trend-app
```

### Check Logs

```bash
# Deployment logs
cat logs/deployment-*.log

# Search for errors in logs
grep -i error logs/deployment-*.log

# Search for specific term
grep -i "terraform" logs/deployment-*.log

# View last 50 lines
tail -50 logs/deployment-*.log

# Follow log file
tail -f logs/deployment-*.log
```

### AWS Troubleshooting

```bash
# Check EKS cluster status
aws eks describe-cluster --name trend-app-eks --region us-east-1

# Check EC2 instances
aws ec2 describe-instances --region us-east-1

# Check Load Balancers
aws elbv2 describe-load-balancers --region us-east-1

# Check VPC
aws ec2 describe-vpcs --region us-east-1

# Check security groups
aws ec2 describe-security-groups --region us-east-1
```

---

## Cleanup Commands

### Full Cleanup

```bash
# Run cleanup script
bash scripts/cleanup-all.sh

# View cleanup logs
cat logs/cleanup-*.log
```

### Manual Cleanup

```bash
# 1. Delete Kubernetes resources
kubectl delete namespace trend-app --force --grace-period=0
kubectl delete namespace monitoring --force --grace-period=0

# 2. Wait for LoadBalancers to delete
sleep 300

# 3. Destroy Terraform infrastructure
cd infrastructure
terraform destroy -auto-approve

# 4. Verify cleanup
aws eks list-clusters --region us-east-1
aws ec2 describe-vpcs --region us-east-1
```

### Cleanup Docker

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Clean everything
docker system prune -a --volumes
```

### Cleanup Local Files

```bash
# Remove Terraform state
cd infrastructure
rm -rf .terraform
rm .terraform.lock.hcl
rm terraform.tfstate*

# Remove logs
rm -rf logs/

# Remove config
rm config.yaml

# Remove kubeconfig
rm ~/.kube/config
```

---

## 10. Quick Command Combos

### Complete Setup & Deploy

```bash
# One-liner setup and deploy
bash scripts/setup-wizard.sh && \
bash scripts/validate-prerequisites.sh && \
bash scripts/deploy-all.sh
```

### Check Everything

```bash
# Check all status
echo "=== Nodes ===" && kubectl get nodes && \
echo "=== Pods ===" && kubectl get pods -n trend-app && \
echo "=== Services ===" && kubectl get svc -n trend-app && \
echo "=== Deployments ===" && kubectl get deployments -n trend-app
```

### Get All URLs

```bash
# Get application and Jenkins URLs
echo "Application URL:" && \
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && \
echo "" && \
echo "Jenkins URL:" && \
cd infrastructure && terraform output -raw jenkins_url && cd ..
```

### Full Status Check

```bash
# Complete health check
echo "=== AWS ===" && aws sts get-caller-identity && \
echo "=== Terraform ===" && cd infrastructure && terraform output && cd .. && \
echo "=== Kubernetes ===" && kubectl get all -n trend-app && \
echo "=== Events ===" && kubectl get events -n trend-app --sort-by='.lastTimestamp' | tail -5
```

### Restart Everything

```bash
# Restart all pods
kubectl rollout restart deployment/trend-app-deployment -n trend-app && \
kubectl rollout status deployment/trend-app-deployment -n trend-app
```

---

## 11. Useful Aliases

Add these to your `~/.bashrc` or `~/.bash_profile`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods -n trend-app'
alias kgs='kubectl get svc -n trend-app'
alias kgn='kubectl get nodes'
alias kga='kubectl get all -n trend-app'
alias kl='kubectl logs -f'
alias kd='kubectl describe'
alias ke='kubectl get events -n trend-app --sort-by=.lastTimestamp'

# Docker aliases
alias d='docker'
alias dps='docker ps'
alias di='docker images'
alias dlog='docker logs -f'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'

# AWS aliases
alias awswho='aws sts get-caller-identity'
alias awseks='aws eks list-clusters'

# Project aliases
alias deploy='bash scripts/deploy-all.sh'
alias cleanup='bash scripts/cleanup-all.sh'
alias validate='bash scripts/validate-prerequisites.sh'
```

---

## 12. Emergency Commands

### Force Delete Stuck Resources

```bash
# Force delete namespace
kubectl delete namespace trend-app --force --grace-period=0

# Force delete pod
kubectl delete pod <pod-name> -n trend-app --force --grace-period=0

# Remove finalizers from namespace
kubectl get namespace trend-app -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/trend-app/finalize" -f -
```

### Reset Everything

```bash
# Reset Kubernetes
kubectl delete namespace trend-app --force --grace-period=0
kubectl delete namespace monitoring --force --grace-period=0

# Reset Terraform
cd infrastructure
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
terraform init

# Reset kubeconfig
rm ~/.kube/config
aws eks update-kubeconfig --name trend-app-eks --region us-east-1

# Reset Docker
docker system prune -a --volumes
```

---

**💡 Tip:** Bookmark this file and use Ctrl+F to quickly find commands you need!
