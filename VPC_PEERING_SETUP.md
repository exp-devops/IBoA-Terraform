# Cross-Account VPC Peering Setup Instructions

## Summary
This configuration enables Jenkins server (in AWS account 796973480744) to access your EKS cluster API endpoint through cross-account VPC peering.

## Jenkins Account Details
- **Account ID**: 796973480744
- **VPC ID**: vpc-057dedf7580220880
- **VPC CIDR**: 10.15.0.0/16
- **Region**: ap-southeast-2
- **Jenkins EC2 IP**: 10.15.0.115

## EKS Account Details (This Account)
- **VPC CIDR**: 10.0.0.0/16
- **Region**: ap-southeast-2
- **EKS Endpoint**: Private only (endpoint_public_access = false)

## Step-by-Step Setup

### Step 1: Create VPC Peering Connection from Jenkins Account

Login to Jenkins AWS account (796973480744) and run:

```bash
aws ec2 create-vpc-peering-connection \
  --vpc-id vpc-057dedf7580220880 \
  --peer-vpc-id <YOUR_EKS_VPC_ID> \
  --peer-owner-id <YOUR_EKS_ACCOUNT_ID> \
  --peer-region ap-southeast-2 \
  --region ap-southeast-2 \
  --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=jenkins-to-eks-peering}]'
```

**Note the VPC Peering Connection ID** from the output (e.g., pcx-xxxxxxxxxxxxx)

### Step 2: Update tfvars File in EKS Account

Add to your `infra_env.tfvars`:

```hcl
vpc_peering_connection_id = "pcx-xxxxxxxxxxxxx"  # Replace with actual connection ID
jenkins_vpc_cidr          = "10.15.0.0/16"
```

### Step 3: Apply Terraform in EKS Account

```bash
cd d:\iboa_terraform_new\IBoA-Terraform
terraform init
terraform plan -var-file="infra_env_variables/prod/infra_env.tfvars"
terraform apply -var-file="infra_env_variables/prod/infra_env.tfvars"
```

This will:
- Accept the VPC peering connection
- Add routes in both public and private route tables pointing to Jenkins VPC (10.15.0.0/16)
- Add security group rule to allow Jenkins VPC CIDR access to EKS cluster on port 443

### Step 4: Add Routes in Jenkins Account

In Jenkins account, add route to EKS VPC in relevant route tables:

```bash
# Get your route table IDs first
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-057dedf7580220880" --region ap-southeast-2

# Add route to EKS VPC (replace <ROUTE_TABLE_ID> and <EKS_VPC_CIDR>)
aws ec2 create-route \
  --route-table-id <ROUTE_TABLE_ID> \
  --destination-cidr-block 10.0.0.0/16 \
  --vpc-peering-connection-id pcx-xxxxxxxxxxxxx \
  --region ap-southeast-2
```

### Step 5: Configure Jenkins EC2 Security Group

In Jenkins account, ensure Jenkins EC2 security group allows outbound HTTPS (443):

```bash
# If not already present, add outbound rule
aws ec2 authorize-security-group-egress \
  --group-id <JENKINS_SG_ID> \
  --protocol tcp \
  --port 443 \
  --cidr 10.0.0.0/16 \
  --region ap-southeast-2
```

### Step 6: Update EKS Kubeconfig on Jenkins Server

SSH to Jenkins server (10.15.0.115) and update kubeconfig:

```bash
# Assuming cross-account IAM role is already configured
aws eks update-kubeconfig \
  --name <EKS_CLUSTER_NAME> \
  --region ap-southeast-2 \
  --role-arn arn:aws:iam::<EKS_ACCOUNT_ID>:role/<EKS_DEPLOYMENT_ROLE>
```

### Step 7: Test Connectivity

From Jenkins server:

```bash
# Test DNS resolution
nslookup <EKS_API_ENDPOINT>

# Test connectivity
curl -k https://<EKS_API_ENDPOINT>

# Test kubectl
kubectl get nodes
kubectl get pods -A
```

## Troubleshooting

If connection fails:

1. **Check VPC Peering Status**:
   ```bash
   aws ec2 describe-vpc-peering-connections --vpc-peering-connection-ids pcx-xxxxxxxxxxxxx
   ```
   Status should be "active"

2. **Verify Routes** in both accounts:
   - Jenkins account routes should have 10.0.0.0/16 → pcx-xxx
   - EKS account routes should have 10.15.0.0/16 → pcx-xxx

3. **Check Security Groups**:
   - EKS cluster security group should allow 443 from 10.15.0.0/16 ✓ (configured by Terraform)
   - Jenkins EC2 security group should allow outbound 443

4. **Verify IAM Access**:
   - Jenkins role must be in EKS access entry ✓ (already configured)
   - RBAC must be configured in cluster ✓ (already done)

5. **Test Network Path**:
   ```bash
   # From Jenkins server
   traceroute <EKS_PRIVATE_IP>
   nc -zv <EKS_API_ENDPOINT> 443
   ```

## Architecture

```
Jenkins Account (796973480744)          EKS Account (Your Account)
VPC: 10.15.0.0/16                      VPC: 10.0.0.0/16
┌─────────────────────┐                ┌──────────────────────┐
│  Jenkins EC2        │                │   EKS Cluster        │
│  10.15.0.115        │                │   (Private Endpoint) │
│                     │                │   Port 443           │
└──────────┬──────────┘                └─────────┬────────────┘
           │                                     │
           │  VPC Peering Connection             │
           │  (pcx-xxxxxxxxxxxxx)                │
           └─────────────────────────────────────┘
                Route: 10.0.0.0/16 → pcx-xxx
                Route: 10.15.0.0/16 → pcx-xxx
                SG Rule: Allow 10.15.0.0/16:443
```

## Files Modified

1. **modules/vpc_peering/** (NEW)
   - main.tf - VPC peering accepter resource
   - routes.tf - Route table entries
   - variables.tf - Module variables
   - outputs.tf - Module outputs

2. **modules/eks/main.tf**
   - Added security group rule for Jenkins VPC CIDR access

3. **modules/eks/variables.tf**
   - Added jenkins_vpc_cidr variable

4. **modules/vpc/output.tf**
   - Added route table outputs

5. **module.tf**
   - Added vpc_peering module

6. **variables.tf**
   - Added VPC peering variables

## Important Notes

- The VPC peering connection must be created from the requester (Jenkins) account first
- You cannot apply Terraform until you have the VPC peering connection ID
- The module will accept the peering connection automatically
- Both VPCs must have non-overlapping CIDR blocks ✓ (10.0.0.0/16 vs 10.15.0.0/16)
- EKS private endpoint requires network path through VPC peering for cross-account access
