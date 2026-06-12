output "ses_qa_secret_access_key" {
  description = "Secret access key for ses_qa user"
  value       = module.iam.ses_qa_secret_access_key
  sensitive   = true
}

output "ses_qa_access_key_id" {
  description = "Access key ID for ses_qa user"
  value       = module.iam.ses_qa_access_key_id
}