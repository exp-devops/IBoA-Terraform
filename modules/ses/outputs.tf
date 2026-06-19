output "domain_identity_arns" {
	description = "ARNs of SES domain identities"
	value       = { for domain, identity in aws_ses_domain_identity.this : domain => identity.arn }
}

output "domain_verification_tokens" {
	description = "SES verification token per domain for manual DNS configuration"
	value       = { for domain, identity in aws_ses_domain_identity.this : domain => identity.verification_token }
}

output "domain_dkim_tokens" {
	description = "SES DKIM tokens per domain for manual DNS CNAME records"
	value       = { for domain, dkim in aws_ses_domain_dkim.this : domain => dkim.dkim_tokens }
}

output "email_identities" {
	description = "Verified SES email identities created by Terraform"
	value       = [for identity in aws_ses_email_identity.this : identity.email]
}

output "smtp_user_name" {
	description = "SMTP IAM username"
	value       = try(aws_iam_user.smtp[0].name, null)
}

output "smtp_user_arn" {
	description = "SMTP IAM user ARN"
	value       = try(aws_iam_user.smtp[0].arn, null)
}

output "smtp_access_key_id" {
	description = "SMTP IAM access key ID (SMTP username)"
	value       = try(aws_iam_access_key.smtp[0].id, null)
}

output "smtp_secret_access_key" {
	description = "SMTP IAM secret access key"
	value       = try(aws_iam_access_key.smtp[0].secret, null)
	sensitive   = true
}

output "smtp_password_v4" {
	description = "SES SMTP password derived from IAM secret key"
	value       = try(aws_iam_access_key.smtp[0].ses_smtp_password_v4, null)
	sensitive   = true
}
