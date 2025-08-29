# IBoA-Terraform

# Infrastructure Deployment Guide

## Prerequisites
Before launching the infrastructure, ensure the following resources are created:

1. **S3 Bucket**: Create an S3 bucket with versioning enabled to store Terraform state files.

---

## Steps for Launching Infrastructure

### 1. Configure AWS CLI Profile
   ```sh
   aws --profile iboa-aws-user configure
   ```

### 2. Update Environment Variables
   - Ensure that the required environment variables are set for common infrastructure.
   
### 3. Remove Remote State File & Initialize Terraform
   ```sh
   rm -rf .terraform/terraform.tfstate
   ```
   - Initialize and apply Terraform for the respective environment (UAT/PROD).

### 4. Update DNS Records
   - Point DNS for both backend and frontend services as needed.

---

## Run Commands

### Deploy to Development Environment
```sh
rm -rf .terraform/terraform.tfstate
terraform init -backend-config="infra_env_variables/dev/tfstate.conf"
terraform fmt && terraform validate
terraform plan --var-file="infra_env_variables/dev/infra_env.tfvars"
terraform apply --var-file="infra_env_variables/dev/infra_env.tfvars"
```

#### Uncomment the following line to destroy the environment
```sh
#terraform destroy --var-file="infra_env_variables/dev/infra_env.tfvars"
```

### Deploy to Production Environment
```sh
rm -rf .terraform/terraform.tfstate
terraform init -backend-config="infra_env_variables/production/tfstate.conf"
terraform fmt && terraform validate
terraform plan --var-file="infra_env_variables/production/infra_env.tfvars"
terraform apply --var-file="infra_env_variables/production/infra_env.tfvars"
```

#### Uncomment the following line to destroy the environment
```sh
#terraform destroy --var-file="infra_env_variables/production/infra_env.tfvars"
```

---

## Known Issues
- Ensure AWS credentials are correctly configured before running Terraform commands.
- Verify that the S3 bucket before initializing Terraform.
- DNS updates may take time to propagate; verify using `dig` or `nslookup`.

---

## Notes
- This guide assumes you have Terraform installed.
- Ensure you have the necessary IAM permissions to manage AWS resources.
- For troubleshooting, refer to Terraform logs or AWS CloudTrail for audit logs.

---

## FAQ
- How to run a single module
   terraform plan -target=module.acm --var-file="infra_env_variables/production/infra_env.tfvars"
   terraform apply -target=module.acm --var-file="infra_env_variables/production/infra_env.tfvars"

**Author**: Bazil Joseph 
**Last Updated**: 29 August 2025