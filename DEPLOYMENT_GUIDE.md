# Production Deployment Guide - Trend App

## Complete Step-by-Step Instructions

---

## Phase 1: Prerequisites

### 1.1 Verify Tools Installed

```powershell
git --version          # Should be 2.30+
aws --version          # Should be AWS CLI v2
terraform --version    # Should be 1.5+
docker --version       # Should be 20.10+
kubectl version        # Should be 1.24+
minikube version       # If using Minikube locally
```

### 1.2 AWS Configuration

```powershell
# Configure AWS credentials
aws configure

# Verify credentials
aws sts get-caller-identity
# Output should show your Account ID, User ARN, etc.

# Get your 12-digit Account ID
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
echo "Your AWS Account ID: $ACCOUNT_ID"
```

### 1.3 Create EC2 Key Pair

```powershell
# Create key pair for Jenkins SSH access
aws ec2 create-key-pair `
  --key-name trend-app-key `
  --region us-east-1 `
  --query 'KeyMaterial' `
  --output text | Out-File -Encoding ASCII trend-app-key.pem

# Set proper permissions (important!)
# On Linux/Mac: chmod 400 trend-app-key.pem
# On Windows: Just keep it safe!
```

### 1.4 Create DockerHub Account

- Sign up at [Docker Hub](https://hub.docker.com)
- Create a public repository: `yourusername/trend-app`
- Note your username and password

---

## Phase 2: Prepare Application

### 2.1 Create React App (if not already done)

```powershell
# Create React app
npx create-react-app .

# Or if you have existing React app, ensure package.json exists
```

### 2.2 Build React App

```powershell
# Install dependencies
npm install

# Build for production
npm run build

# Verify dist folder created
ls dist/
```

### 2.3 Test Docker Image Locally

```powershell
# Build image
docker build -t abhishek8056/trend-app:latest .

# Run container
docker run -d -p 3000:3000 --name test-app abhishek8056/trend-app:latest

# Test endpoint
Start-Sleep -Seconds 3
curl http://localhost:3000

# Cleanup
docker stop test-app
docker rm test-app
```

### 2.4 Push to DockerHub (Optional for local testing)

```powershell
# Login to DockerHub
docker login

# Push image
docker push abhishek8056/trend-app:latest
```

---

## Phase 3: Deploy Infrastructure with Terraform

### 3.1 Navigate to Infrastructure Directory

```powershell
cd infrastructure
```

### 3.2 Initialize Terraform

```powershell
terraform init
```

### 3.3 Create terraform.tfvars File

```powershell
# Create file with your values
@"
aws_region             = "us-east-1"
aws_account_id         = "YOUR_12_DIGIT_ACCOUNT_ID"
project_name           = "trend-app"
environment            = "production"
jenkins_instance_type  = "t3.medium"
jenkins_key_pair_name  = "trend-app-key"
eks_cluster_version    = "1.31"
eks_node_desired_size  = 2
"@ | Out-File terraform.tfvars
```

### 3.4 Plan Terraform Deployment

```powershell
terraform plan -out=tfplan
```

Review the plan output carefully! It should show:

- 1 VPC
- 2 Subnets (public)
- 2 Subnets (private)
- 3 Security Groups
- EKS Cluster
- EKS Node Group
- Jenkins EC2 Instance
- IAM Roles and Policies

### 3.5 Apply Terraform Configuration

```powershell
terraform apply tfplan
```

### 3.6 Save Terraform Outputs

```powershell
# Get all outputs
terraform output

# Save outputs to file
terraform output > ../TERRAFORM_OUTPUTS.txt

# Get specific outputs
$JENKINS_URL = terraform output -raw jenkins_url
$EKS_CLUSTER = terraform output -raw eks_cluster_name
$EKS_ENDPOINT = terraform output -raw eks_cluster_endpoint

echo "Jenkins URL: $JENKINS_URL"
echo "EKS Cluster: $EKS_CLUSTER"
echo "EKS Endpoint: $EKS_ENDPOINT"
```

### 3.7 Update Kubeconfig

```powershell
# Configure kubectl to access EKS cluster
aws eks update-kubeconfig `
  --name trend-app-eks-by-abhi `
  --region us-east-1

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

---

## Phase 4: Deploy Kubernetes Resources

### 4.1 Apply Kubernetes Manifests

```powershell
cd ../k8s

# Create namespace
kubectl apply -f namespace.yaml

# Apply resource quota and limits
kubectl apply -f resource-quota.yaml

# Apply network policy
kubectl apply -f network-policy.yaml

# Deploy application
kubectl apply -f deployment.yaml

# Create service
kubectl apply -f service.yaml

# Create HPA (auto-scaling)
kubectl apply -f hpa.yaml

# Apply MetalLB config (if using Minikube)
kubectl apply -f metallb-config.yaml
```

### 4.2 Verify Deployment

```powershell
# Check namespace
kubectl get namespace trend-app

# Check pods
kubectl get pods -n trend-app -w
# Wait until all pods show "1/1 Running"

# Check service
kubectl get svc -n trend-app

# Check service endpoints
kubectl get endpoints -n trend-app

# Check HPA
kubectl get hpa -n trend-app

# View resource quotas
kubectl describe resourcequota -n trend-app

# View network policies
kubectl get networkpolicy -n trend-app
```

### 4.3 Get Application URL

```powershell
# For EKS (AWS LoadBalancer)
$EXTERNAL_IP = kubectl get svc -n trend-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
echo "App URL: http://$EXTERNAL_IP"

# For Minikube (localhost)
# Run 'minikube tunnel' in separate terminal first
$MINIKUBE_IP = kubectl get svc -n trend-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
echo "App URL: http://$MINIKUBE_IP:80"
```

### 4.4 Test Application

```powershell
# Test HTTP endpoint
curl http://<EXTERNAL_IP>
# Should return React app HTML

# Check logs
kubectl logs -f deployment/trend-app-deployment -n trend-app

# Exec into pod for debugging
kubectl exec -it <pod-name> -n trend-app -- sh
```

---

## Phase 5: Configure Jenkins

### 5.1 Access Jenkins

```powershell
# Get Jenkins URL
cd ../infrastructure
$JENKINS_URL = terraform output -raw jenkins_url
echo $JENKINS_URL
# Visit in browser: http://<jenkins-url>:8080
```

### 5.2 Get Initial Admin Password

```powershell
# Get Jenkins instance ID
$INSTANCE_ID = aws ec2 describe-instances `
  --filters "Name=tag:Name,Values=trend-app-jenkins-production" `
  --query 'Reservations[0].Instances[0].InstanceId' `
  --output text

# Connect to instance via Session Manager or SSH
aws ssm start-session --target $INSTANCE_ID

# Inside instance:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 5.3 Follow Jenkins Setup Guide

See `JENKINS_SETUP.md` for:

- Installing plugins
- Creating DockerHub credentials
- Creating kubeconfig credentials
- Setting up pipeline job
- Running first build

---

## Phase 6: Deploy Monitoring (Optional)

### 6.1 Install Prometheus and Grafana

```powershell
cd ../monitoring

# Make script executable
chmod +x install-monitoring.sh

# Run installation
bash install-monitoring.sh
```

### 6.2 Access Monitoring Dashboard

```powershell
# Port forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Port forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# Get Grafana admin password
$GRAFANA_PASS = kubectl get secret -n monitoring prometheus-grafana `
  -o jsonpath="{.data.admin-password}" | base64 -d
echo "Grafana Password: $GRAFANA_PASS"
```

### 6.3 Access Dashboards

- Grafana: [http://localhost:3000](http://localhost:3000) (admin / password)
- Prometheus: [http://localhost:9090](http://localhost:9090)

---

## Phase 7: Verify Complete Setup

### 7.1 Run Health Check

```powershell
# Check all resources
echo "=== Nodes ==="
kubectl get nodes

echo "=== Pods ==="
kubectl get pods -n trend-app

echo "=== Services ==="
kubectl get svc -n trend-app

echo "=== Deployments ==="
kubectl get deployments -n trend-app

echo "=== HPA ==="
kubectl get hpa -n trend-app

echo "=== Events ==="
kubectl get events -n trend-app --sort-by='.lastTimestamp' | tail -5
```

### 7.2 Verify Endpoints

```powershell
# Application
curl http://<app-url>

# Jenkins
curl http://<jenkins-url>:8080

# Prometheus
curl http://localhost:9090/api/v1/status/config

# Grafana
curl http://localhost:3000/api/health
```

---

## Phase 8: Common Tasks

### Scale Deployment

```powershell
kubectl scale deployment/trend-app-deployment --replicas=5 -n trend-app
```

### View Logs

```powershell
# Real-time logs
kubectl logs -f deployment/trend-app-deployment -n trend-app

# Last 100 lines
kubectl logs --tail=100 deployment/trend-app-deployment -n trend-app
```

### Update Deployment Image

```powershell
# After pushing new image to DockerHub
kubectl set image deployment/trend-app-deployment `
  trend-app=abhishek8056/trend-app:new-tag `
  -n trend-app

# Check rollout status
kubectl rollout status deployment/trend-app-deployment -n trend-app
```

### Restart Pods

```powershell
kubectl rollout restart deployment/trend-app-deployment -n trend-app
```

---

## Phase 9: Cleanup (if needed)

### Delete Kubernetes Resources

```powershell
kubectl delete namespace trend-app --force --grace-period=0
kubectl delete namespace monitoring --force --grace-period=0
```

### Destroy Infrastructure

```powershell
cd infrastructure
terraform destroy -auto-approve
```

### Delete Local Files

```powershell
rm terraform.tfstate*
rm -r .terraform
rm -r logs
```

---

## Troubleshooting

### Pod not starting

```powershell
kubectl describe pod <pod-name> -n trend-app
kubectl logs <pod-name> -n trend-app --previous
```

### Service pending

```powershell
# Check for AWS LB controller
kubectl get deployment -n kube-system | grep load-balancer

# For Minikube: Run minikube tunnel in separate terminal
minikube tunnel
```

### Jenkins can't connect to K8s

```powershell
# Verify kubeconfig in Jenkins credential
kubectl --kubeconfig=<path-to-jenkins-kubeconfig> get pods
```

### Image pull failures

```powershell
# Verify image exists on DockerHub
docker pull abhishek8056/trend-app:latest

# Check pod events
kubectl describe pod <pod-name> -n trend-app
```

---

## Success Checklist

- ✅ Terraform applied successfully
- ✅ EKS cluster running
- ✅ Jenkins EC2 instance running
- ✅ Kubernetes pods in "Running" state
- ✅ Service has external IP/hostname
- ✅ Application accessible via URL
- ✅ Jenkins deployed pipeline job
- ✅ Docker image pushed to DockerHub
- ✅ Monitoring stack running (optional)
- ✅ HPA configured and working

---

For detailed information about each component, refer to:

- Infrastructure: See `infrastructure/README.md`
- Kubernetes: See `k8s/` manifests
- Jenkins: See `JENKINS_SETUP.md`
- Monitoring: See `monitoring/install-monitoring.sh`
  cd C:\Users\USER\Downloads\Trend-by-Abhi

# docs lint (optional if installed)

markdownlint \*\*\*.md

terraform init -backend=false
terraform validate

# go back to repo root and node build

cd ..
npm ci
npm run build

# docker build

docker build -t trend-app:local-test .

# k8s dry-run (client validation)

kubectl apply --dry-run=client -f k8s/
