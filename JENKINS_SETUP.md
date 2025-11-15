# Jenkins CI/CD Setup Guide

## Overview

This guide walks you through setting up Jenkins to deploy the Trend App to Kubernetes using the provided Jenkinsfile.

---

## Prerequisites

- Jenkins EC2 instance running (deployed by Terraform)
- DockerHub account with username and password/token
- AWS credentials configured
- EKS cluster running
- kubeconfig file for EKS access

---

## Step 1: Access Jenkins

### Get Jenkins URL

```bash
cd infrastructure
terraform output jenkins_url
# Output: http://<jenkins-public-ip>:8080
```

### Get Initial Admin Password

```bash
# SSH into Jenkins EC2
aws ec2-instance-connect send-ssh-public-key \
  --instance-id <jenkins-instance-id> \
  --os-user ec2-user \
  --ssh-public-key file://~/.ssh/id_rsa.pub \
  --region us-east-1

# Or use Session Manager if configured
aws ssm start-session --target <jenkins-instance-id>

# Get password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### First Login

1. Open Jenkins URL in browser: `http://<jenkins-public-ip>:8080`
2. Paste the initial admin password
3. Click "Install suggested plugins"
4. Create first admin user
5. Start using Jenkins

---

## Step 2: Configure Jenkins Plugins

### Required Plugins (should be installed by default)

- Docker Pipeline
- Git
- Kubernetes
- Pipeline
- Credentials Binding
- CloudBees Docker Build and Publish

### Check Installed Plugins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search for and ensure these are installed:
   - Docker Pipeline
   - Kubernetes
   - Pipeline
   - Git
3. If missing, install them and restart Jenkins

---

## Step 3: Create DockerHub Credentials

### Create DockerHub Username/Password Credential

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click on **System** in left panel
3. Click on **Global credentials (unrestricted)**
4. Click **Add Credentials** on the left
5. Fill in the form:
   - **Kind**: Username with password
   - **Username**: `abhishek8056` (your DockerHub username)
   - **Password**: Your DockerHub password or access token
   - **ID**: `dockerhub-creds` ⚠️ **MUST match Jenkinsfile**
   - **Description**: DockerHub credentials for pushing images
6. Click **Create**

### Alternatively: Use Access Token (More Secure)

1. Create a Personal Access Token on DockerHub:
   - Go to DockerHub Account Settings → Security → New Access Token
   - Name: `jenkins-token`
   - Permissions: Read & Write
2. Copy the token
3. In Jenkins, create credential with:
   - **Username**: `abhishek8056`
   - **Password**: `<your-access-token>`
   - **ID**: `dockerhub-creds`

---

## Step 4: Create Kubeconfig Credentials

### Prepare Kubeconfig File

1. On your local machine, generate kubeconfig for the EKS cluster:

```bash
aws eks update-kubeconfig \
  --name trend-app-eks-by-abhi \
  --region us-east-1 \
  --kubeconfig ./kubeconfig-jenkins
```

2. Copy the kubeconfig file contents:

```bash
cat ./kubeconfig-jenkins
```

### Add Kubeconfig as Jenkins Credential

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click on **System** → **Global credentials (unrestricted)**
3. Click **Add Credentials** on the left
4. Fill in the form:
   - **Kind**: Secret file
   - **File**: Upload the `kubeconfig-jenkins` file
   - **ID**: `kubeconfig-creds` ⚠️ **MUST match Jenkinsfile**
   - **Description**: EKS kubeconfig for Kubernetes deployments
5. Click **Create**

### Alternative: Paste Kubeconfig Content

If upload doesn't work:

1. Kind: **Secret text**
2. Secret: Paste the entire content of kubeconfig file
3. ID: `kubeconfig-creds`
4. Description: EKS kubeconfig
5. Click **Create**

---

## Step 5: Configure AWS Credentials (Optional but Recommended)

### Add AWS Credentials to Jenkins

If Jenkins will deploy Terraform or manage AWS resources:

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click on **System** → **Global credentials (unrestricted)**
3. Click **Add Credentials**
4. Fill in the form:
   - **Kind**: AWS Credentials
   - **Access Key ID**: Your AWS access key
   - **Secret Access Key**: Your AWS secret key
   - **ID**: `aws-credentials`
   - **Description**: AWS credentials for Terraform/AWS operations
5. Click **Create**

---

## Step 6: Create Pipeline from Jenkinsfile

### Create New Pipeline Job

1. Click **New Item** on Jenkins home page
2. Enter job name: `trend-app-pipeline`
3. Select **Pipeline**
4. Click **OK**

### Configure Pipeline

1. Scroll down to **Pipeline** section
2. **Definition**: Select "Pipeline script from SCM"
3. **SCM**: Select **Git**
4. **Repository URL**: Your GitHub repo URL
   - Example: `https://github.com/yourusername/Trend-by-Abhi.git`
5. **Credentials**: Select your GitHub credentials (or create new)
6. **Branch Specifier**: `*/main` (or your default branch)
7. **Script Path**: `Jenkinsfile` (default location)
8. Click **Save**

### Alternative: Paste Jenkinsfile Directly

1. In **Pipeline** section
2. **Definition**: Select "Pipeline script"
3. Copy entire Jenkinsfile content into the text area
4. Click **Save**

---

## Step 7: Run the Pipeline

### Trigger Pipeline Manually

1. Open the `trend-app-pipeline` job
2. Click **Build Now**
3. Watch the build progress in **Build History**
4. Click the build number to view logs

### Expected Pipeline Stages

1. ✅ **Checkout** - Clone Git repo
2. ✅ **Lint & Validate** - Check Dockerfile, Terraform, K8s manifests
3. ✅ **Build Docker Image** - Build and tag image
4. ✅ **Test Docker Image** - Run container and test endpoint
5. ✅ **Push to DockerHub** - Login and push image to DockerHub
6. ✅ **Deploy to Kubernetes** - Update K8s deployment or apply manifests
7. ✅ **Verify Deployment** - Check pod status and service

### View Build Logs

1. Click **Console Output** to see full logs
2. Search for errors: Look for `ERROR` or `failed`
3. Common issues:
   - `Permission denied` → Check DockerHub credentials
   - `Unauthorized` → Check kubeconfig credentials
   - `ImagePullBackOff` → Image not pushed to DockerHub

---

## Step 8: Troubleshooting

### Credential Verification

```bash
# Verify DockerHub login works locally
docker login -u abhishek8056

# Verify kubeconfig access
kubectl --kubeconfig=./kubeconfig-jenkins get pods -n trend-app

# Verify AWS access
aws sts get-caller-identity
```

### Jenkins Debug Mode

1. Go to Jenkins home
2. Click **Manage Jenkins** → **System Log**
3. Set log level to DEBUG
4. Re-run pipeline and check logs

### Common Issues & Fixes

| Issue                           | Cause                           | Fix                                                                                                                                |
| ------------------------------- | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `dockerhub-creds not found`     | Credential ID mismatch          | Check Jenkins credential ID matches `dockerhub-creds` in Jenkinsfile                                                               |
| `kubeconfig-creds not found`    | Credential ID mismatch          | Check Jenkins credential ID matches `kubeconfig-creds` in Jenkinsfile                                                              |
| `docker: command not found`     | Docker not installed in Jenkins | Reinstall Docker via user-data or manually on Jenkins EC2                                                                          |
| `kubectl: command not found`    | kubectl not installed           | Install kubectl: `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` |
| `Permission denied (publickey)` | SSH key not configured          | Generate EC2 key pair and add to Jenkins variable                                                                                  |
| `ImagePullBackOff`              | Image not in DockerHub          | Check `docker push` succeeded in build logs                                                                                        |
| `CrashLoopBackOff`              | App failing to start            | Check app logs: `kubectl logs -f <pod-name> -n trend-app`                                                                          |

---

## Step 9: Set Up GitHub Webhook (Optional - Auto-trigger)

### In GitHub Repository

1. Go to your repo **Settings** → **Webhooks**
2. Click **Add webhook**
3. **Payload URL**: `http://<jenkins-public-ip>:8080/github-webhook/`
4. **Content type**: `application/json`
5. **Events**: Select "Push events"
6. Click **Add webhook**

### In Jenkins

1. Go to Pipeline job → **Configure**
2. Under **Build Triggers**, check "GitHub hook trigger for GITScm polling"
3. Click **Save**

### Now, every `git push` will automatically trigger the pipeline!

---

## Step 10: Monitor Deployment

### View Deployment Status

```bash
# Check pods
kubectl get pods -n trend-app -w

# Check service
kubectl get svc -n trend-app

# View logs
kubectl logs -f deployment/trend-app-deployment -n trend-app

# Get app URL
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Jenkins Pipeline Environment Variables

The pipeline uses:

- `DOCKERHUB_REPO`: Image registry (abhishek8056/trend-app)
- `IMAGE_TAG`: Git commit hash (short form)
- `NAMESPACE`: K8s namespace (trend-app)

---

## Next Steps

1. ✅ Run first pipeline build
2. ✅ Verify image is pushed to DockerHub
3. ✅ Check pods are running in Kubernetes
4. ✅ Access app via LoadBalancer URL
5. ✅ Set up GitHub webhook for auto-deploy
6. ✅ Configure Prometheus/Grafana monitoring
7. ✅ Set up failure alerts/notifications

---

## Jenkins Restart/Recovery

### Restart Jenkins

```bash
# SSH into Jenkins EC2
sudo systemctl restart jenkins

# Check status
sudo systemctl status jenkins
```

### Backup Jenkins Config

```bash
# Backup jobs and configs
sudo tar -czf ~/jenkins-backup.tar.gz /var/lib/jenkins

# Download locally
scp -i <key.pem> ec2-user@<jenkins-ip>:~/jenkins-backup.tar.gz ./
```

---

**Questions?** Check logs in Jenkins UI or SSH into Jenkins EC2 for `/var/log/jenkins/jenkins.log`
