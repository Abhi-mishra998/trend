# Quick Start Guide - Trend App Deployment

Get your project running in minutes with these essential commands.

## 🎯 Pre-Deployment Checklist

```powershell
# 1. Verify tools are installed
node --version          # Should be v18+
npm --version
docker --version
aws --version
terraform --version
kubectl version         # If using EKS

# 2. Verify AWS credentials
aws sts get-caller-identity

# 3. Set your AWS account ID (save it!)
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
echo "Your AWS Account ID: $ACCOUNT_ID"

# 4. Create EC2 key pair (one-time)
aws ec2 create-key-pair --key-name trend-app-key --region us-east-1 `
  --query 'KeyMaterial' --output text | Out-File -Encoding ASCII trend-app-key.pem
```

## 📦 Step 1: Prepare React App (5 minutes)

**If you have existing React source:**

```powershell
# Just build it
npm install
npm run build
```

**If creating new React app:**

```powershell
# Create new React app
npx create-react-app .

# Install and build
npm install
npm run build

# Test locally
docker build -t trend-app:test .
docker run -p 3000:3000 trend-app:test
```

## 🏗️ Step 2: Deploy Infrastructure (10 minutes)

```powershell
# 1. Create terraform.tfvars with YOUR values
$tfvars = @"
aws_region              = "us-east-1"
aws_account_id          = "$ACCOUNT_ID"
jenkins_key_pair_name   = "trend-app-key"
eks_cluster_version     = "1.31"
"@
$tfvars | Out-File infrastructure/terraform.tfvars

# 2. Deploy infrastructure
cd infrastructure
terraform init
terraform plan
terraform apply

# 3. Save outputs (you'll need them)
terraform output -raw eks_cluster_name > cluster_name.txt
terraform output -raw jenkins_public_ip > jenkins_ip.txt

# 4. Update kubeconfig
$CLUSTER_NAME = Get-Content cluster_name.txt
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-1
```

## 🐳 Step 3: Deploy Kubernetes Resources (5 minutes)

```powershell
# Apply in order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/resource-quota.yaml
kubectl apply -f k8s/network-policy.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployment
kubectl get pods -n trend-app
kubectl get svc -n trend-app
```

## 🚀 Step 4: Configure Jenkins (15 minutes)

```powershell
# 1. Get Jenkins IP
$JENKINS_IP = Get-Content jenkins_ip.txt
Write-Host "Jenkins URL: http://$($JENKINS_IP):8080"

# 2. SSH to Jenkins instance to get initial password
ssh -i trend-app-key.pem ec2-user@$JENKINS_IP
# On Jenkins:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
exit

# 3. Configure via browser (follow JENKINS_SETUP.md):
# - http://<JENKINS_IP>:8080
# - Paste initial password
# - Install suggested plugins
# - Create DockerHub credential (ID: dockerhub-creds)
# - Create Kubeconfig credential (ID: kubeconfig-creds)
# - Create Pipeline job from Jenkinsfile
```

## ✅ Step 5: Verify Everything Works (5 minutes)

```powershell
# 1. Check pods
kubectl get pods -n trend-app -w

# 2. Check service
kubectl get svc -n trend-app

# 3. Check logs
kubectl logs -n trend-app deployment/trend-app-deployment -f

# 4. Run first pipeline build in Jenkins
# - Go to Jenkins → TrendApp → Build Now
# - Check console output for errors

# 5. Verify image in DockerHub
# - Visit https://hub.docker.com/r/abhishek8056/trend-app

# 6. Test application
# - Get service IP: kubectl get svc -n trend-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
# - Visit that IP in browser
```

## 📊 Monitoring (Optional - 5 minutes)

```powershell
# Deploy Prometheus + Grafana
bash monitoring/install-monitoring.sh

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Visit http://localhost:3000 (admin/prom-operator)
```

## 🛠️ Common Commands

```powershell
# View application logs
kubectl logs -n trend-app -l app=trend-app -f

# Scale deployment
kubectl scale deployment trend-app-deployment -n trend-app --replicas=5

# Restart pods
kubectl rollout restart deployment/trend-app-deployment -n trend-app

# Update image
kubectl set image deployment/trend-app-deployment `
  trend-app=abhishek8056/trend-app:v2.0 -n trend-app

# View pod events
kubectl describe pod -n trend-app

# Execute command in pod
kubectl exec -it <pod-name> -n trend-app -- /bin/sh

# Port forward for testing
kubectl port-forward svc/trend-app 3000:80 -n trend-app
# Visit http://localhost:3000

# Check resource usage
kubectl top nodes
kubectl top pods -n trend-app

# Get service external IP
kubectl get svc trend-app -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 🗑️ Cleanup (if needed)

```powershell
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete monitoring (if deployed)
helm uninstall prometheus-community/kube-prometheus-stack -n monitoring

# Destroy infrastructure
cd infrastructure
terraform destroy

# Delete local files
rm trend-app-key.pem
rm cluster_name.txt
rm jenkins_ip.txt
```

## 📚 Need More Details?

- **Full Deployment Steps**: See `DEPLOYMENT_GUIDE.md`
- **Jenkins Configuration**: See `JENKINS_SETUP.md`
- **All Fixes Applied**: See `FIXES_APPLIED.md`
- **Original Setup**: See `SETUP_GUIDE.md`
- **Project Issues & Solutions**: See `FIXES_APPLIED.md`

## ⚠️ Important Notes

1. **Save your AWS Account ID** - You'll need it for Terraform
2. **Keep trend-app-key.pem safe** - This is your SSH key to Jenkins
3. **DockerHub account required** - Push images to `abhishek8056/trend-app`
4. **AWS billing** - EKS and EC2 charges apply (see `terraform output` for costs)
5. **Kubeconfig permissions** - Ensure kubectl can access EKS cluster

## 🎯 Expected Timeline

| Phase                     | Time       | Notes                                  |
| ------------------------- | ---------- | -------------------------------------- |
| React app setup           | 5 min      | Skip if using existing app             |
| Infrastructure deployment | 10 min     | Terraform provisions all AWS resources |
| Kubernetes resources      | 5 min      | Apply manifests to cluster             |
| Jenkins configuration     | 15 min     | Set up credentials and pipeline        |
| Verification              | 5 min      | Test entire stack                      |
| **Total**                 | **40 min** | First-time setup                       |

## ✨ Success Indicators

✅ All pods running: `kubectl get pods -n trend-app` shows `1/1 Running`
✅ Service has IP: `kubectl get svc -n trend-app` shows external IP
✅ Jenkins accessible: Can reach Jenkins UI at public IP:8080
✅ Pipeline works: Jenkins build completes successfully
✅ Image pushed: `abhishek8056/trend-app:latest` visible on DockerHub
✅ App responds: Can access application via service URL
✅ Logs clean: `kubectl logs -n trend-app` shows no errors

---

**Quick Check**: Run this to verify everything is working:

```powershell
kubectl get all -n trend-app
kubectl get resourcequota -n trend-app
kubectl get networkpolicy -n trend-app
```

You're ready to deploy! 🚀
