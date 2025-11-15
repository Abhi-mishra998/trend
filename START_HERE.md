# 🚀 START HERE - Complete Project Setup Guide

**ONE FILE TO RULE THEM ALL** - Everything you need to deploy this project from scratch.

---

## 📌 What This Project Does

Deploys a React application (Trend app) to AWS EKS with:
- ✅ Docker containerization
- ✅ Terraform infrastructure (VPC, EKS, Jenkins)
- ✅ Jenkins CI/CD pipeline
- ✅ Kubernetes deployment
- ✅ Auto-scaling & monitoring
- ✅ GitHub webhook integration

**Application**: https://github.com/Vennilavan12/Trend.git  
**Port**: 3000  
**Cluster**: EKS 1.31 with 3x t3.large nodes

---

## ⚡ QUICK START (3 Steps)

```bash
# Step 1: Configure
bash scripts/setup-wizard.sh

# Step 2: Validate
bash scripts/validate-prerequisites.sh

# Step 3: Deploy (20-30 min)
bash scripts/deploy-all.sh
```

**Done!** Skip to [Verify Deployment](#verify-deployment) section.

---

## 📋 DETAILED SETUP (Step-by-Step)

### STEP 1: Install Prerequisites

#### On Windows (Git Bash Required)

**1.1 Install Git Bash**
```powershell
# Download: https://git-scm.com/download/win
# Install and open "Git Bash" for all commands below
```

**1.2 Install AWS CLI**
```powershell
# Download: https://awscli.amazonaws.com/AWSCLIV2.msi
# Or use Chocolatey:
choco install awscli
```
**Verify:**
```bash
aws --version
# Expected: aws-cli/2.x.x
```

**1.3 Install Terraform**
```powershell
# Download: https://www.terraform.io/downloads
# Or use Chocolatey:
choco install terraform
```
**Verify:**
```bash
terraform --version
# Expected: Terraform v1.5.x or higher
```

**1.4 Install Docker Desktop**
```powershell
# Download: https://www.docker.com/products/docker-desktop
# Start Docker Desktop after installation
```
**Verify:**
```bash
docker --version
docker ps
# Expected: Docker version 20.x.x and running containers list
```

**1.5 Install kubectl**
```powershell
# Download: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
# Or use Chocolatey:
choco install kubernetes-cli
```
**Verify:**
```bash
kubectl version --client
# Expected: Client Version: v1.27.x or higher
```

---

### STEP 2: Configure AWS

**2.1 Get AWS Credentials**

You need:
- AWS Access Key ID
- AWS Secret Access Key
- Permissions: EC2, EKS, IAM, VPC, ELB (full access)

**2.2 Configure AWS CLI**
```bash
aws configure
```
Enter when prompted:
```
AWS Access Key ID: [paste your key]
AWS Secret Access Key: [paste your secret]
Default region name: ap-south-1
Default output format: json
```

**2.3 Verify AWS Access**
```bash
aws sts get-caller-identity
```
**Expected output:**
```json
{
    "UserId": "AIDAXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-name"
}
```
**📝 SAVE YOUR ACCOUNT ID** (the 12-digit number) - you'll need it!

---

### STEP 3: Configure DockerHub

**3.1 Create DockerHub Account**
- Go to: https://hub.docker.com
- Sign up (free account)
- Remember your username

**3.2 Create Repository**
- Click "Create Repository"
- Name: `trend-app`
- Visibility: Public
- Your repo will be: `your-username/trend-app`

---

### STEP 4: Run Setup Wizard

**What it does:** Creates `config.yaml` with your settings

```bash
bash scripts/setup-wizard.sh
```

**You'll be asked:**

**Q1: AWS Account ID?**
```
Enter the 12-digit number from Step 2.3
Example: 123456789012
```

**Q2: AWS Region?**
```
Default: ap-south-1 (Mumbai)
Press Enter to use default
Other options: us-east-1, us-west-2, eu-west-1
```

**Q3: AWS CLI Profile?**
```
Press Enter to use "default"
```

**Q4: DockerHub Username?**
```
Enter your DockerHub username
Example: abhishek8056
```

**Q5: DockerHub Repository?**
```
Format: username/trend-app
Example: abhishek8056/trend-app
```

**Q6: Jenkins Instance Type?**
```
Press Enter to use t3.large (recommended)
```

**Q7: EKS Node Instance Type?**
```
Press Enter to use t3.large (recommended)
```

**Q8: EKS Node Count?**
```
Desired: 3
Min: 2
Max: 5
Press Enter for defaults
```

**Q9: Enable Monitoring?**
```
Type: yes
(Installs Prometheus + Grafana)
```

**Q10: Grafana Password?**
```
Enter a password (save it!)
Example: MySecurePass123
```

**✅ Setup wizard complete!** File `config.yaml` created.

---

### STEP 5: Validate Prerequisites

**What it does:** Checks all tools and AWS access

```bash
bash scripts/validate-prerequisites.sh
```

**Expected output:**
```
[SUCCESS] AWS CLI (v2.x.x) - OK
[SUCCESS] Terraform (v1.x.x) - OK
[SUCCESS] Docker (v20.x.x) - OK
[SUCCESS] kubectl (v1.x.x) - OK
[SUCCESS] AWS credentials valid
[SUCCESS] EC2 permissions - OK
[SUCCESS] EKS permissions - OK
[SUCCESS] IAM permissions - OK
[SUCCESS] config.yaml exists

All prerequisites met! Ready to deploy.
```

**❌ If any check fails:**
- Install the missing tool
- Fix AWS credentials: `aws configure`
- Re-run validation

---

### STEP 6: Deploy Infrastructure

**What it does:** Deploys everything to AWS (20-30 minutes)

```bash
bash scripts/deploy-all.sh
```

**What happens:**

**Phase 1: Prerequisites (1 min)**
```
✓ Checking required commands
✓ Validating prerequisites
```

**Phase 2: Terraform Init (2 min)**
```
✓ Initializing Terraform
✓ Downloading AWS provider
```

**Phase 3: Infrastructure (15 min)**
```
✓ Creating VPC
✓ Creating subnets
✓ Creating security groups
✓ Creating IAM roles
✓ Creating EKS cluster
✓ Creating node group
✓ Creating Jenkins EC2
```

**Phase 4: Kubeconfig (1 min)**
```
✓ Generating kubeconfig
✓ Connecting to EKS
```

**Phase 5: Kubernetes (5 min)**
```
✓ Creating namespace
✓ Deploying application
✓ Creating service
✓ Creating HPA
✓ Waiting for pods
```

**Phase 6: Monitoring (3 min)**
```
✓ Installing Prometheus
✓ Installing Grafana
```

**Phase 7: Verification (1 min)**
```
✓ Checking cluster
✓ Checking pods
✓ Checking service
```

**✅ Deployment complete!**

---

## ✅ Verify Deployment

### Check Kubernetes Cluster
```bash
kubectl get nodes
```
**Expected:** 3 nodes in "Ready" status

### Check Application Pods
```bash
kubectl get pods -n trend-app
```
**Expected:** Pods in "Running" status

### Check Service
```bash
kubectl get svc -n trend-app
```
**Expected:** Service with EXTERNAL-IP (LoadBalancer)

### Get Application URL
```bash
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
**Copy the URL and open in browser** (wait 5-10 min for LoadBalancer)

### Get Jenkins URL
```bash
cd infrastructure
terraform output jenkins_url
```
**Access Jenkins at this URL**

---

## 🔧 Configure Jenkins

### Step 1: Access Jenkins
```bash
# Get Jenkins URL
cd infrastructure
terraform output jenkins_url

# Get initial password
# SSH to Jenkins instance or check user-data logs
```

### Step 2: Setup Jenkins Kubeconfig
```bash
# SSH to Jenkins EC2 instance
# Run this command:
sudo /usr/local/bin/update-jenkins-kubeconfig.sh
```
**This fixes kubeconfig issues!**

### Step 3: Install Plugins
In Jenkins UI:
1. Go to "Manage Jenkins" → "Plugins"
2. Install:
   - Docker Pipeline
   - Kubernetes
   - Git
   - Pipeline

### Step 4: Add Credentials
1. Go to "Manage Jenkins" → "Credentials"
2. Add DockerHub credentials:
   - Kind: Username with password
   - ID: `dockerhub-credentials`
   - Username: your DockerHub username
   - Password: your DockerHub password

### Step 5: Create Pipeline
1. New Item → Pipeline
2. Name: `trend-app-pipeline`
3. Pipeline script from SCM
4. SCM: Git
5. Repository URL: your GitHub repo
6. Script Path: `Jenkinsfile`

### Step 6: Setup GitHub Webhook
1. GitHub repo → Settings → Webhooks
2. Add webhook:
   - URL: `http://[jenkins-url]/github-webhook/`
   - Content type: application/json
   - Events: Push events
3. Save

**✅ Jenkins configured!** Now every commit triggers auto-deployment.

---

## 🆘 TROUBLESHOOTING

### Issue 1: AWS Credentials Not Working
**Symptom:** `aws sts get-caller-identity` fails

**Fix:**
```bash
# Reconfigure AWS
aws configure

# Test again
aws sts get-caller-identity
```

---

### Issue 2: Docker Not Running
**Symptom:** `docker ps` shows error

**Fix:**
```bash
# Start Docker Desktop (Windows)
# Wait for Docker to fully start
docker ps
```

---

### Issue 3: Terraform Init Fails
**Symptom:** Terraform initialization error

**Fix:**
```bash
cd infrastructure
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

### Issue 4: EKS Cluster Not Accessible
**Symptom:** `kubectl get nodes` fails

**Fix:**
```bash
# Regenerate kubeconfig
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1

# Test
kubectl get nodes
```

---

### Issue 5: Pods Not Starting (ImagePullBackOff)
**Symptom:** Pods stuck in ImagePullBackOff

**Fix:**
```bash
# Check if image exists
docker pull your-username/trend-app:latest

# If not, build and push:
docker build -t your-username/trend-app:latest .
docker login
docker push your-username/trend-app:latest

# Restart deployment
kubectl rollout restart deployment/trend-app-deployment -n trend-app
```

---

### Issue 6: LoadBalancer Stuck in Pending
**Symptom:** Service shows `<pending>` for EXTERNAL-IP

**Fix:**
```bash
# Wait 10 minutes - LoadBalancers take time
# Check status
kubectl describe svc trend-app-service -n trend-app

# Check events
kubectl get events -n trend-app --sort-by='.lastTimestamp'
```

---

### Issue 7: Jenkins Can't Access Kubernetes
**Symptom:** Jenkins pipeline fails with kubeconfig error

**Fix:**
```bash
# SSH to Jenkins EC2 instance
# Run kubeconfig update script
sudo /usr/local/bin/update-jenkins-kubeconfig.sh

# Verify
sudo -u jenkins kubectl get nodes
```

---

### Issue 8: Terraform Destroy Fails
**Symptom:** Can't delete infrastructure

**Fix:**
```bash
# Delete Kubernetes resources first
kubectl delete namespace trend-app --force --grace-period=0

# Wait 5 minutes for LoadBalancers
sleep 300

# Try destroy again
cd infrastructure
terraform destroy -auto-approve
```

---

### Issue 9: Out of Memory / Resources
**Symptom:** Pods crashing, nodes not ready

**Fix:**
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n trend-app

# Scale down if needed
kubectl scale deployment trend-app-deployment --replicas=1 -n trend-app
```

---

### Issue 10: Can't Access Application
**Symptom:** LoadBalancer URL not working

**Fix:**
```bash
# Get LoadBalancer URL
kubectl get svc trend-app-service -n trend-app

# Wait 10 minutes after deployment
# Check if pods are running
kubectl get pods -n trend-app

# Check pod logs
kubectl logs -f deployment/trend-app-deployment -n trend-app

# Test from inside cluster
kubectl run test --rm -it --image=busybox -- wget -O- http://trend-app-service.trend-app.svc.cluster.local
```

---

## 📊 Useful Commands

### Check Everything
```bash
# Quick health check
kubectl get nodes
kubectl get pods -n trend-app
kubectl get svc -n trend-app
```

### View Logs
```bash
# Deployment logs
cat logs/deployment-*.log

# Pod logs
kubectl logs -f <pod-name> -n trend-app

# All pod logs
kubectl logs -f deployment/trend-app-deployment -n trend-app
```

### Scale Application
```bash
# Scale to 5 replicas
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app

# Check scaling
kubectl get pods -n trend-app
```

### Restart Application
```bash
# Restart all pods
kubectl rollout restart deployment/trend-app-deployment -n trend-app

# Check status
kubectl rollout status deployment/trend-app-deployment -n trend-app
```

### Check Events
```bash
# Recent events
kubectl get events -n trend-app --sort-by='.lastTimestamp'

# Watch events
kubectl get events -n trend-app --watch
```

### Debug Pod
```bash
# Describe pod
kubectl describe pod <pod-name> -n trend-app

# Execute shell in pod
kubectl exec -it <pod-name> -n trend-app -- sh

# Check pod resources
kubectl top pod <pod-name> -n trend-app
```

### Check Infrastructure
```bash
# Terraform outputs
cd infrastructure
terraform output

# AWS EKS cluster
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1

# AWS LoadBalancers
aws elbv2 describe-load-balancers --region ap-south-1
```

---

## 🧹 Cleanup (Delete Everything)

### Automated Cleanup
```bash
bash scripts/cleanup-all.sh
```

### Manual Cleanup
```bash
# 1. Delete Kubernetes resources
kubectl delete namespace trend-app --force --grace-period=0
kubectl delete namespace monitoring --force --grace-period=0

# 2. Wait for LoadBalancers (IMPORTANT!)
sleep 300

# 3. Destroy Terraform
cd infrastructure
terraform destroy -auto-approve

# 4. Verify cleanup
aws eks list-clusters --region us-east-1
aws ec2 describe-vpcs --region us-east-1
```

### Verify AWS Costs
```bash
# Check current costs in AWS Console
# Billing → Cost Explorer
```

---

## 📁 Project Structure

```
trend-app-devops/
├── START_HERE.md           ← YOU ARE HERE (only file you need!)
├── README.md               ← Project overview
├── Dockerfile              ← Container definition
├── Jenkinsfile             ← CI/CD pipeline
├── package.json            ← Node.js dependencies
│
├── scripts/                ← Automation scripts
│   ├── setup-wizard.sh     ← Interactive setup
│   ├── validate-prerequisites.sh
│   ├── apply-config.sh
│   ├── deploy-all.sh       ← Main deployment
│   └── cleanup-all.sh      ← Delete everything
│
├── infrastructure/         ← Terraform (AWS)
│   ├── main.tf             ← Main infrastructure
│   ├── variables.tf        ← Configuration
│   ├── outputs.tf          ← Outputs (URLs, IDs)
│   └── modules/            ← Reusable modules
│       ├── vpc/            ← Network
│       ├── eks/            ← Kubernetes cluster
│       ├── jenkins/        ← CI/CD server
│       ├── iam/            ← Permissions
│       └── security-groups/← Firewall
│
├── k8s/                    ← Kubernetes manifests
│   ├── namespace.yaml      ← Namespace
│   ├── deployment.yaml     ← App deployment
│   ├── service.yaml        ← LoadBalancer
│   └── hpa.yaml            ← Auto-scaling
│
└── monitoring/             ← Prometheus + Grafana
    ├── install-monitoring.sh
    ├── prometheus-values.yaml
    └── grafana-values.yaml
```

---

## 🎯 What You'll Learn

By completing this project, you'll understand:

✅ **Docker** - Containerizing applications  
✅ **Terraform** - Infrastructure as Code  
✅ **AWS EKS** - Managed Kubernetes  
✅ **Jenkins** - CI/CD pipelines  
✅ **Kubernetes** - Container orchestration  
✅ **GitHub Webhooks** - Auto-deployment  
✅ **Monitoring** - Prometheus & Grafana  
✅ **DevOps** - End-to-end workflow  

---

## 📸 Screenshots to Take

For your submission, capture:

1. ✅ AWS Console - EKS Cluster running
2. ✅ `kubectl get nodes` - 3 nodes ready
3. ✅ `kubectl get pods -n trend-app` - Pods running
4. ✅ `kubectl get svc -n trend-app` - LoadBalancer with external IP
5. ✅ Browser - Application running on LoadBalancer URL
6. ✅ Jenkins UI - Pipeline configured
7. ✅ Jenkins - Successful build
8. ✅ GitHub - Webhook configured
9. ✅ Grafana - Monitoring dashboard (optional)
10. ✅ Terraform output - Infrastructure details

---

## 🎓 Submission Checklist

- [ ] GitHub repository with all code
- [ ] README.md with setup instructions
- [ ] Screenshots of deployment
- [ ] LoadBalancer ARN/URL documented
- [ ] Jenkins pipeline working
- [ ] GitHub webhook configured
- [ ] Application accessible via LoadBalancer
- [ ] Monitoring setup (optional but recommended)

---

## 💡 Pro Tips

1. **Save your config.yaml** - Backup after setup wizard
2. **Check logs** - Always check `logs/deployment-*.log` if issues
3. **Wait for LoadBalancer** - Takes 5-10 minutes to provision
4. **Use t3.large** - Better performance for learning
5. **Delete when done** - Run cleanup script to avoid AWS charges
6. **Take screenshots** - Document everything for submission
7. **Test locally first** - Build Docker image locally before deploying

---

## 🚨 Important Notes

- **Cost**: ~$2-5/day with t3.large instances
- **Time**: 20-30 minutes for full deployment
- **Region**: Use us-east-1 for best availability
- **Cleanup**: Always run cleanup script when done
- **Learning**: This is for education, not production

---

## 🆘 Still Stuck?

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review deployment logs: `cat logs/deployment-*.log`
3. Check pod status: `kubectl get pods -n trend-app`
4. Check events: `kubectl get events -n trend-app --sort-by='.lastTimestamp'`
5. Verify AWS credentials: `aws sts get-caller-identity`

---

## ✅ Success Criteria

Your deployment is successful when:

✅ EKS cluster shows 3 nodes in Ready state  
✅ Pods are Running in trend-app namespace  
✅ Service has an EXTERNAL-IP (LoadBalancer)  
✅ Application is accessible via LoadBalancer URL  
✅ Jenkins can deploy to Kubernetes  
✅ GitHub webhook triggers builds  

---

**🎉 You're ready to start! Follow the steps above and you'll have a production-ready deployment in 30 minutes!**

**Questions? Check the Troubleshooting section or review the logs!**
