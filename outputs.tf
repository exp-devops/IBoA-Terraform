output "ses_domain_verification_tokens" {
  description = "SES domain verification tokens"
  value       = module.ses.domain_verification_tokens
}

output "ses_domain_dkim_tokens" {
  description = "SES domain DKIM tokens"
  value       = module.ses.domain_dkim_tokens
}

output "ses_email_identities" {
  description = "SES email identities created"
  value       = module.ses.email_identities
}

output "ses_smtp_user_name" {
  description = "SES SMTP IAM user name"
  value       = module.ses.smtp_user_name
}

output "ses_smtp_access_key_id" {
  description = "SES SMTP access key ID (SMTP username)"
  value       = module.ses.smtp_access_key_id
}

output "ses_smtp_secret_access_key" {
  description = "SES SMTP secret access key"
  value       = module.ses.smtp_secret_access_key
  sensitive   = true
}

output "ses_smtp_password_v4" {
  description = "SES SMTP password"
  value       = module.ses.smtp_password_v4
  sensitive   = true
}