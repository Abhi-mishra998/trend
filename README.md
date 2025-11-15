# Trend App - AWS EKS Deployment (Learning Project)

Simple AWS EKS deployment for learning DevOps on Windows.

## For Abhishek (Windows User)

**👉 See `QUICK_SETUP.md` for personalized setup instructions!**

## Quick Start (Git Bash)

```bash
# 1. Configure
bash scripts/setup-wizard.sh

# 2. Validate
bash scripts/validate-prerequisites.sh

# 3. Deploy
bash scripts/deploy-all.sh
```

**Time:** ~30 minutes

## Prerequisites (Windows)

- **Git Bash** (comes with Git for Windows)
- **AWS CLI** configured (`aws configure`)
- **Terraform** >= 1.5.0
- **Docker Desktop** running
- **kubectl** >= 1.27.0
- **DockerHub** account

### Install on Windows

```powershell
# Using Chocolatey (recommended)
choco install awscli terraform kubernetes-cli

# Or download installers:
# AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi
# Terraform: https://www.terraform.io/downloads
# Docker: https://www.docker.com/products/docker-desktop
# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

## What You Get

- AWS EKS Cluster (Managed Kubernetes)
- Jenkins CI/CD Server
- Auto-Scaling Application
- Monitoring (Prometheus + Grafana)
- Multi-AZ High Availability

## Project Structure

```
trend-app-devops/
├── README.md                    # This file
├── config.yaml                  # Your settings (generated)
├── Dockerfile                   # Container build
├── Jenkinsfile                  # CI/CD pipeline
├── scripts/                     # Automation scripts
│   ├── setup-wizard.sh          # Configure
│   ├── validate-prerequisites.sh # Check tools
│   ├── deploy-all.sh            # Deploy everything
│   └── cleanup-all.sh           # Delete everything
├── infrastructure/              # Terraform (AWS)
│   ├── main.tf
│   ├── variables.tf
│   └── modules/                 # VPC, EKS, Jenkins, IAM
├── k8s/                         # Kubernetes configs
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── hpa.yaml
└── monitoring/                  # Prometheus + Grafana
```

## Configuration

The `config.yaml` file (created by setup wizard) contains:
- AWS Account ID, Region, Profile
- DockerHub Username and Repository
- Infrastructure Sizing (instance types, node counts)
- Monitoring Settings

## Common Commands

### Deploy
```bash
bash scripts/deploy-all.sh
```

### Check Status
```bash
kubectl get pods -n trend-app
kubectl get svc -n trend-app
```

### View Logs
```bash
kubectl logs -f deployment/trend-app-deployment -n trend-app
```

### Scale Application
```bash
kubectl scale deployment trend-app-deployment --replicas=5 -n trend-app
```

### Cleanup (Delete Everything)
```bash
bash scripts/cleanup-all.sh
```

## Troubleshooting

### Deployment Fails
- Check logs in `logs/deployment-*.log`
- Verify AWS credentials: `aws sts get-caller-identity`

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n trend-app
kubectl logs <pod-name> -n trend-app
```

### Can't Access Application
```bash
kubectl get svc trend-app-service -n trend-app
```
Wait 5-10 minutes for LoadBalancer to provision.

## What You'll Learn

- Docker containerization
- Kubernetes deployment
- Terraform infrastructure as code
- Jenkins CI/CD pipelines
- AWS cloud services (EKS, EC2, VPC)
- Monitoring with Prometheus + Grafana
- DevOps best practices

## Files You Can Edit

- `config.yaml` - Change settings
- `k8s/deployment.yaml` - Change replicas, resources
- `infrastructure/variables.tf` - Change defaults
- `Dockerfile` - Change app build

## Important Notes

- This is for **learning purposes**
- Remember to **delete resources** when done (run cleanup script)
- Check AWS console to verify resources are deleted
- Logs are saved in `logs/` directory

## License

MIT License

---

**Simple, clean, and ready for learning!**
