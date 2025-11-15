# 🌏 Region Configuration - ap-south-1 (Mumbai)

## ✅ Default Region Changed

Your project is now configured for **ap-south-1 (Mumbai, India)**

### What Changed

**Before:**
- Default region: us-east-1 (US East - Virginia)
- Availability zones: us-east-1a, us-east-1b

**After:**
- Default region: **ap-south-1** (Asia Pacific - Mumbai)
- Availability zones: **ap-south-1a, ap-south-1b**

---

## 📍 Region Details

**Region Code:** `ap-south-1`  
**Location:** Mumbai, India  
**Availability Zones:** 3 (using 2: ap-south-1a, ap-south-1b)

### Why ap-south-1?

- ✅ Lower latency for India-based users
- ✅ Data residency in India
- ✅ Full EKS support
- ✅ All required AWS services available

---

## 🚀 How to Deploy

### Option 1: Use Default (ap-south-1)

Just run the setup wizard and press Enter when asked for region:

```bash
bash scripts/setup-wizard.sh
# When asked for region, press Enter to use ap-south-1
```

### Option 2: Change Region

If you want a different region:

```bash
bash scripts/setup-wizard.sh
# When asked for region, type: us-east-1 (or any other)
```

**Supported regions:**
- `ap-south-1` (Mumbai) - **DEFAULT**
- `us-east-1` (Virginia)
- `us-east-2` (Ohio)
- `us-west-1` (California)
- `us-west-2` (Oregon)
- `eu-west-1` (Ireland)
- `eu-west-2` (London)
- `eu-central-1` (Frankfurt)
- `ap-southeast-1` (Singapore)
- `ap-southeast-2` (Sydney)
- `ap-northeast-1` (Tokyo)

---

## ⚙️ Configuration Files Updated

All these files now default to ap-south-1:

1. ✅ `infrastructure/variables.tf`
   - `aws_region = "ap-south-1"`
   - `availability_zones = ["ap-south-1a", "ap-south-1b"]`

2. ✅ `scripts/setup-wizard.sh`
   - Default region prompt: ap-south-1

3. ✅ `config.yaml.example`
   - Region: ap-south-1

4. ✅ `START_HERE.md`
   - All examples use ap-south-1

5. ✅ `README.md`
   - Region info updated

---

## 🔧 AWS CLI Configuration

Make sure your AWS CLI is configured for ap-south-1:

```bash
# Configure AWS CLI
aws configure

# When prompted:
Default region name: ap-south-1
```

**Verify:**
```bash
aws configure get region
# Should show: ap-south-1
```

---

## 📊 Region-Specific Commands

### Check EKS Cluster
```bash
aws eks list-clusters --region ap-south-1
aws eks describe-cluster --name trend-app-eks-by-abhi --region ap-south-1
```

### Update Kubeconfig
```bash
aws eks update-kubeconfig --name trend-app-eks-by-abhi --region ap-south-1
```

### Check Resources
```bash
# List VPCs
aws ec2 describe-vpcs --region ap-south-1

# List EC2 instances
aws ec2 describe-instances --region ap-south-1

# List Load Balancers
aws elbv2 describe-load-balancers --region ap-south-1
```

---

## 💰 Cost Considerations

**ap-south-1 pricing is similar to us-east-1:**

- t3.large: ~$0.0832/hour
- EKS Control Plane: $0.10/hour
- LoadBalancer: ~$0.0225/hour
- Data Transfer: Standard rates

**Total: ~$2-5/day** (same as other regions)

---

## 🆘 Troubleshooting

### Issue: Region Not Available
**Symptom:** AWS says region not available

**Fix:**
```bash
# Check if you have access to ap-south-1
aws ec2 describe-regions --region ap-south-1

# If not, use a different region in setup wizard
```

### Issue: EKS Version Not Available
**Symptom:** EKS 1.31 not available in ap-south-1

**Fix:**
```bash
# Check available versions
aws eks describe-addon-versions --region ap-south-1

# Update infrastructure/variables.tf if needed
# Change eks_cluster_version to available version
```

### Issue: Instance Type Not Available
**Symptom:** t3.large not available in ap-south-1

**Fix:**
```bash
# Check available instance types
aws ec2 describe-instance-types --region ap-south-1 --filters "Name=instance-type,Values=t3.*"

# t3.large is available in ap-south-1, but if issues:
# Update infrastructure/variables.tf to use t3.medium
```

---

## ✅ Verification

After deployment, verify region:

```bash
# Check Terraform
cd infrastructure
terraform output

# Check EKS cluster region
kubectl config view --minify | grep server
# Should show ap-south-1 in the URL

# Check AWS CLI
aws configure get region
# Should show: ap-south-1
```

---

## 🌍 Want to Change Region Later?

### Before Deployment
Just run setup wizard again:
```bash
bash scripts/setup-wizard.sh
# Enter different region when prompted
```

### After Deployment
1. Cleanup existing resources:
   ```bash
   bash scripts/cleanup-all.sh
   ```

2. Update config:
   ```bash
   bash scripts/setup-wizard.sh
   # Enter new region
   ```

3. Deploy again:
   ```bash
   bash scripts/deploy-all.sh
   ```

---

## 📝 Summary

✅ **Default region:** ap-south-1 (Mumbai)  
✅ **All files updated**  
✅ **Ready to deploy**  
✅ **Same cost as other regions**  
✅ **Full EKS support**  

**Just run the setup wizard and deploy!**

```bash
bash scripts/setup-wizard.sh
bash scripts/validate-prerequisites.sh
bash scripts/deploy-all.sh
```

---

**Your project is configured for ap-south-1 and ready to deploy! 🚀**
