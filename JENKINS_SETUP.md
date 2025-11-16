# Jenkins Setup Guide - Step by Step

Complete guide to configure Jenkins for AWS EKS deployment with Docker and Kubernetes integration.

## 📋 Prerequisites

- Jenkins server deployed via Terraform (from infrastructure/)
- AWS CLI configured with EKS access
- DockerHub account
- kubectl configured for EKS cluster
- **Node.js installed on Jenkins server** (for React app build)

---

## 🚀 Step 1: Access Jenkins

### Get Jenkins URL

```bash
cd infrastructure
terraform output jenkins_url
# Example: ec2-13-234-56-789.ap-south-1.compute.amazonaws.com
```

### Access Jenkins Web UI

- Open browser: `http://YOUR_JENKINS_URL:8080`
- First time: Get initial admin password

```bash
# SSH to Jenkins EC2 (if needed)
ssh -i your-key.pem ubuntu@YOUR_JENKINS_URL

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## 🔧 Step 2: Install Required Plugins

### Access Plugin Manager

1. Jenkins Dashboard → **Manage Jenkins** → **Manage Plugins**
2. Go to **Available** tab

### Install These Plugins:

- ✅ **Docker Pipeline** (for docker commands)
- ✅ **Kubernetes CLI** (for kubectl)
- ✅ **GitHub Integration** (for webhooks)
- ✅ **Credentials Binding** (for secrets)
- ✅ **Pipeline** (for declarative pipelines)

### Install Process:

1. Search for each plugin
2. Check the box
3. Click **Install without restart**
4. Wait for installation to complete

---

## 🔐 Step 3: Configure Credentials

### Access Credentials Manager

1. Jenkins Dashboard → **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **Add Credentials**

### Add DockerHub Credentials

```
Kind: Username with password
Scope: Global
Username: your-dockerhub-username
Password: your-dockerhub-password
ID: dockerhub-creds
Description: DockerHub Credentials
```

### Add Kubeconfig Credentials

```
Kind: Secret file
Scope: Global
File: Upload your kubeconfig file (from EKS)
ID: kubeconfig-creds
Description: EKS Kubeconfig
```

**How to get kubeconfig:**

```bash
# Configure AWS CLI first (if not done)
aws configure

# Update kubeconfig for your EKS cluster
aws eks update-kubeconfig --region ap-south-1 --name trend-app-eks-by-abhi

# Verify connection
kubectl get nodes

# The kubeconfig is now at: ~/.kube/config (Linux/Mac) or C:\Users\USER\.kube\config (Windows)
# Upload this file to Jenkins credentials
```

**Important Notes:**

- The kubeconfig file contains sensitive cluster access information
- Make sure your AWS user has EKS permissions
- Test kubectl locally before uploading to Jenkins
- Jenkins will use this file to authenticate with your EKS cluster

---

## ⚙️ Step 4: Configure Global Tools

### Configure Docker

1. **Manage Jenkins** → **Global Tool Configuration**
2. Find **Docker** section
3. Click **Add Docker**
4. Name: `docker`
5. Install automatically: ✅ Checked

### Configure kubectl

1. In same page, find **Kubernetes CLI** section
2. Click **Add Kubernetes CLI**
3. Name: `kubectl`
4. Install automatically: ✅ Checked
5. Version: `1.31.0` (matches EKS version)

---

## 🔗 Step 5: Configure GitHub Integration

### Add GitHub Server

1. **Manage Jenkins** → **Configure System**
2. Scroll to **GitHub** section
3. Click **Add GitHub Server**
4. Name: `GitHub`
5. API URL: `https://api.github.com`
6. Credentials: Add GitHub Personal Access Token

### Create GitHub Token

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens**
2. Generate new token with `repo` and `admin:repo_hook` permissions
3. Copy token and add to Jenkins credentials:

```
Kind: Secret text
Secret: your-github-token
ID: github-token
Description: GitHub Personal Access Token
```

---

## 📦 Step 6: Create Pipeline Job

### Create New Job

1. Jenkins Dashboard → **New Item**
2. Enter name: `trend-app-pipeline`
3. Select **Pipeline**
4. Click **OK**

### Configure Pipeline

1. **General** tab:

   - ✅ GitHub project
   - Project url: `https://github.com/YOUR_USERNAME/YOUR_REPO`

2. **Build Triggers** tab:

   - ✅ GitHub hook trigger for GITScm polling

3. **Pipeline** tab:

   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. Click **Save**

---

## 🧪 Step 7: Test Pipeline

### Manual Build Test

1. Click **Build Now** on pipeline job
2. Monitor build progress
3. Check console output for errors

### Common Issues & Fixes

**Node.js not found (npm: command not found):**

```bash
# SSH to Jenkins server and install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

**Docker permission denied:**

```bash
# SSH to Jenkins server
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**kubectl connection failed:**

- Verify kubeconfig credentials are correct
- Test kubectl locally: `kubectl get nodes`
- Check if EKS cluster is running and accessible

**DockerHub push failed:**

- Verify DockerHub credentials
- Check repository name in Jenkinsfile matches your repo
- Ensure DockerHub repository exists and is public/private as needed

---

## 🔗 Step 8: Setup GitHub Webhook

### Get Jenkins URL Again

```bash
cd infrastructure
terraform output jenkins_url
```

### Configure Webhook in GitHub

1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. Payload URL: `http://YOUR_JENKINS_URL:8080/github-webhook/`
4. Content type: `application/json`
5. Events: Just the `push` event
6. Active: ✅ Checked
7. Click **Add webhook**

### Test Webhook

1. Make a small change to your code
2. Commit and push to GitHub
3. Jenkins should automatically start a build

---

## 📊 Step 9: Verify Complete Setup

### Check Jenkins Dashboard

- Pipeline job should show successful builds
- Console output should show all stages passing

### Check AWS EKS

```bash
kubectl get pods -n trend-app
kubectl get svc -n trend-app
```

### Check Application

- Get LoadBalancer URL from kubectl output
- Open in browser to verify app is running

---

## 🆘 Troubleshooting

### Jenkins Not Accessible

- Check Security Group allows port 8080
- Verify EC2 instance is running

### Pipeline Fails at Docker Stage

```bash
# On Jenkins server
sudo systemctl status docker
sudo systemctl start docker
```

### Pipeline Fails at Kubernetes Stage

```bash
# Test kubectl on Jenkins server
export KUBECONFIG=/path/to/kubeconfig
kubectl get nodes
```

### Webhook Not Triggering

- Check webhook URL format
- Verify GitHub token has correct permissions
- Check Jenkins logs for webhook reception

---

## ✅ Success Checklist

- [ ] Jenkins accessible at port 8080
- [ ] All required plugins installed
- [ ] DockerHub credentials configured
- [ ] Kubeconfig credentials uploaded
- [ ] GitHub integration configured
- [ ] Pipeline job created and configured
- [ ] Manual build test successful
- [ ] GitHub webhook configured
- [ ] Auto-build triggered on push

---

## 🎯 Next Steps

1. **Test the full pipeline** with a code change
2. **Monitor builds** in Jenkins dashboard
3. **Check application** is deployed correctly
4. **Take screenshots** for submission
5. **Document LoadBalancer ARN** for evaluation

Your Jenkins CI/CD pipeline is now ready for production deployment! 🚀
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version # Should show v18.x.x
npm --version # Should show 9.x.x
