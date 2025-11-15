# Trend App - Production Ready AWS EKS Deployment

Complete DevOps project deploying a React application to AWS EKS with Jenkins CI/CD pipeline.

## 🎯 What This Project Does

- ✅ Deploys React app to AWS EKS (Kubernetes 1.31)
- ✅ Automated CI/CD with Jenkins
- ✅ Infrastructure as Code with Terraform
- ✅ Docker containerization
- ✅ Auto-scaling with HPA
- ✅ Monitoring with Prometheus & Grafana
- ✅ GitHub webhook integration

**Application**: https://github.com/Vennilavan12/Trend.git  
**Port**: 3000  
**Infrastructure**: 3x t3.large nodes on AWS EKS

---

## 🚀 Quick Start

```bash
# 1. Configure (interactive wizard)
bash scripts/setup-wizard.sh

# 2. Validate tools and AWS access
bash scripts/validate-prerequisites.sh

# 3. Deploy everything (20-30 minutes)
bash scripts/deploy-all.sh
```

**That's it!** Your application will be deployed to AWS with full CI/CD.

---

## 📖 Complete Documentation

**👉 [START_HERE.md](START_HERE.md) - COMPLETE SETUP GUIDE**

This single file contains:
- ✅ Step-by-step installation
- ✅ Detailed explanations of every command
- ✅ Troubleshooting for common issues
- ✅ Jenkins configuration
- ✅ GitHub webhook setup
- ✅ Useful commands reference
- ✅ Cleanup instructions

**Everything you need is in START_HERE.md!**

---

## 📋 Prerequisites

- Git Bash (Windows) or Bash (Linux/Mac)
- AWS CLI v2
- Terraform >= 1.5.0
- Docker Desktop
- kubectl >= 1.27.0
- AWS Account with admin access
- DockerHub account

**Installation instructions in [START_HERE.md](START_HERE.md)**

---

## 🏗️ What Gets Deployed

### AWS Infrastructure (Terraform)
- VPC with public/private subnets
- EKS Cluster (Kubernetes 1.31)
- 3x t3.large worker nodes
- Jenkins EC2 instance (t3.large)
- Security groups & IAM roles
- Application LoadBalancer

### Kubernetes Resources
- Namespace: `trend-app`
- Deployment with 3 replicas
- LoadBalancer service
- Horizontal Pod Autoscaler
- Resource quotas & limits

### CI/CD Pipeline
- Jenkins with Docker, kubectl, AWS CLI
- Automated build on GitHub push
- Docker image build & push
- Kubernetes deployment
- GitHub webhook integration

### Monitoring (Optional)
- Prometheus for metrics
- Grafana for dashboards
- Cluster & application monitoring

---

## 📊 Project Structure

```
trend-app-devops/
├── START_HERE.md          ← Complete setup guide (READ THIS!)
├── README.md              ← This file
├── Dockerfile             ← Container definition
├── Jenkinsfile            ← CI/CD pipeline
├── scripts/               ← Automation scripts
├── infrastructure/        ← Terraform (AWS)
├── k8s/                   ← Kubernetes manifests
└── monitoring/            ← Prometheus + Grafana
```

---

## ✅ Verify Deployment

```bash
# Check cluster
kubectl get nodes

# Check application
kubectl get pods -n trend-app
kubectl get svc -n trend-app

# Get application URL
kubectl get svc trend-app-service -n trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Get Jenkins URL
cd infrastructure && terraform output jenkins_url
```

---

## 🧹 Cleanup

```bash
# Delete everything
bash scripts/cleanup-all.sh
```

This removes all AWS resources to avoid charges.

---

## 🎓 Learning Objectives

This project teaches:
- Docker containerization
- Terraform infrastructure as code
- AWS EKS (managed Kubernetes)
- Jenkins CI/CD pipelines
- Kubernetes deployments
- Auto-scaling & monitoring
- DevOps best practices

---

## 📸 Screenshots for Submission

1. EKS cluster in AWS Console
2. `kubectl get nodes` output
3. `kubectl get pods -n trend-app` output
4. Application running in browser
5. Jenkins pipeline success
6. GitHub webhook configured
7. LoadBalancer URL/ARN

---

## 🆘 Need Help?

**Check [START_HERE.md](START_HERE.md)** - It has:
- Detailed troubleshooting section
- Common issues & solutions
- Useful commands
- Step-by-step fixes

---

## 📝 Configuration

All configuration is done via the setup wizard:
```bash
bash scripts/setup-wizard.sh
```

This creates `config.yaml` with:
- AWS Account ID & Region
- DockerHub repository
- Instance types (t3.large)
- Node count (3 nodes)
- Monitoring settings

---

## 🚨 Important Notes

- **Cost**: ~$2-5/day with t3.large instances
- **Time**: 20-30 minutes for deployment
- **Region**: ap-south-1 (Mumbai) - default
- **Cleanup**: Always delete resources when done
- **Purpose**: Learning project, not production-ready

---

## 📦 What's Included

- ✅ Complete Terraform infrastructure
- ✅ Kubernetes manifests
- ✅ Jenkins pipeline (Jenkinsfile)
- ✅ Docker configuration
- ✅ Automated deployment scripts
- ✅ Monitoring setup
- ✅ Complete documentation

---

## 🎯 Success Criteria

Your deployment is successful when:
- ✅ 3 EKS nodes in Ready state
- ✅ Pods running in trend-app namespace
- ✅ LoadBalancer has external IP
- ✅ Application accessible via browser
- ✅ Jenkins can deploy to Kubernetes
- ✅ GitHub webhook triggers builds

---

## 🔗 Links

- **Application Repo**: https://github.com/Vennilavan12/Trend.git
- **Complete Guide**: [START_HERE.md](START_HERE.md)
- **AWS EKS Docs**: https://docs.aws.amazon.com/eks/
- **Terraform Docs**: https://www.terraform.io/docs/
- **Kubernetes Docs**: https://kubernetes.io/docs/

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

**🚀 Ready to start? Open [START_HERE.md](START_HERE.md) and follow the steps!**
