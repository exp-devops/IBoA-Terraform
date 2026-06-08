# ACM Certificate Module

This module creates an AWS Certificate Manager (ACM) certificate for the domain `*.iboa.com.au` with DNS validation for externally managed DNS.

## Features

- Creates an ACM certificate for wildcard domain (`*.iboa.com.au`)
- Supports Subject Alternative Names (SANs)
- DNS validation method (manual DNS record creation required)
- Certificate auto-renewal before expiration once DNS records are in place

## Prerequisites

1. **External DNS Provider**: Your DNS for `iboa.com.au` is managed outside AWS Route53
2. **DNS Access**: You need access to create CNAME records in your DNS provider

## Important Note

**Since your DNS is managed externally (not Route53), you must manually create DNS validation records in your DNS provider.** The certificate will remain in "Pending Validation" status until the DNS records are added and propagated.

## Usage

The module is already configured in the root `module.tf` file:

```hcl
module "acm" {
  source                    = "./modules/acm"
  tags                      = var.tags
  project_name              = var.project_name
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  project_env               = var.project_env
}
```

## Configuration

The variables are already configured in your `infra_env_variables/{env}/infra_env.tfvars` file:

```hcl
domain_name               = "*.iboa.com.au"
subject_alternative_names = ["iboa.com.au"]
```

## DNS Validation Process

### Step 1: Apply Terraform
Run terraform to create the ACM certificate:

```bash
terraform plan -var-file=infra_env_variables/prod/infra_env.tfvars
terraform apply -var-file=infra_env_variables/prod/infra_env.tfvars
```

### Step 2: Get DNS Validation Records
After applying, Terraform will output the DNS validation records needed:

```bash
terraform output validation_records
```

The output will look like:
```
[
  {
    "domain_name" = "*.iboa.com.au"
    "record_name" = "_abc123.iboa.com.au"
    "record_type" = "CNAME"
    "record_value" = "_xyz456.acm-validations.aws."
  },
  {
    "domain_name" = "iboa.com.au"
    "record_name" = "_def789.iboa.com.au"
    "record_type" = "CNAME"
    "record_value" = "_uvw012.acm-validations.aws."
  }
]
```

### Step 3: Add DNS Records to Your DNS Provider
For each validation record, create a CNAME record in your DNS provider:

- **Record Type**: CNAME
- **Name/Host**: Use the `record_name` value (e.g., `_abc123.iboa.com.au`)
- **Value/Points to**: Use the `record_value` value (e.g., `_xyz456.acm-validations.aws.`)
- **TTL**: 300 seconds (5 minutes) or your provider's default

**Example for common DNS providers:**

**GoDaddy / Namecheap / Others:**
- Type: CNAME
- Host: `_abc123`
- Points to: `_xyz456.acm-validations.aws.`
- TTL: Automatic or 300

### Step 4: Wait for Validation
- DNS propagation typically takes 5-30 minutes
- AWS will automatically detect the DNS records and validate the certificate
- You can check the status in AWS Certificate Manager console
- Once validated, the certificate status will change from "Pending Validation" to "Issued"

## Outputs

The module provides the following outputs:

- `acm_certificate_arn` - ARN of the certificate (use this in ALB/CloudFront)
- `acm_certificate_id` - ID of the certificate
- `acm_certificate_domain_name` - Domain name of the certificate
- `acm_certificate_status` - Status of the certificate (will show "PENDING_VALIDATION" until DNS records are added)
- `validation_records` - **Important**: Formatted DNS records to add to your DNS provider

## Using the Certificate

Once the certificate is validated, you can use it in other modules:

```hcl
# Example: Using in ALB module
alb_certificate_arn = module.acm.acm_certificate_arn

# Example: Using in CloudFront module (requires certificate in us-east-1)
viewer_certificate {
  acm_certificate_arn = module.acm.acm_certificate_arn
  ssl_support_method  = "sni-only"
}
```

## Certificate Coverage

- The wildcard certificate `*.iboa.com.au` covers all subdomains (e.g., `app.iboa.com.au`, `api.iboa.com.au`)
- The root domain `iboa.com.au` is added as a Subject Alternative Name (SAN)
- Both the wildcard and root domain require separate DNS validation records

## Checking Certificate Status

### Using AWS Console:
1. Go to AWS Certificate Manager (ACM) console
2. Select the appropriate region
3. Find the certificate for `*.iboa.com.au`
4. Check the validation status

### Using AWS CLI:
```bash
# List certificates
aws acm list-certificates --profile your-profile --region ap-southeast-2

# Describe specific certificate
aws acm describe-certificate --certificate-arn <arn> --profile your-profile --region ap-southeast-2
```

### Using Terraform:
```bash
terraform output acm_certificate_status
```

## Troubleshooting

### Certificate Stuck in "Pending Validation"
1. **Verify DNS records are correctly added** to your DNS provider
2. **Check DNS propagation**: Use tools like `nslookup` or `dig`
   ```bash
   nslookup -type=CNAME _abc123.iboa.com.au
   ```
3. **Wait for DNS propagation**: Can take up to 48 hours (typically 5-30 minutes)
4. **Verify CNAME values match exactly** (including trailing dot if present)

### Wrong DNS Records
If you need to check the validation records again:
```bash
terraform output validation_records
```

### Certificate Renewal
- ACM automatically renews certificates before expiration
- Ensure DNS records remain in place for automatic renewal
- AWS will use the same DNS validation records for renewal

## Important Security Note

- ACM certificates in `us-east-1` are required for CloudFront distributions
- For ALB, use certificates in the same region as the load balancer
- This module creates the certificate in the region specified in your provider configuration
