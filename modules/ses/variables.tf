variable "project_name" {
	description = "Project name used for naming resources"
	type        = string
}

variable "project_env" {
	description = "Environment name used for naming resources"
	type        = string
}

variable "tags" {
	description = "Common tags to apply"
	type        = map(string)
	default     = {}
}

variable "domains" {
	description = "List of SES domain identities to create"
	type        = list(string)
	default     = []
}

variable "verified_email_addresses" {
	description = "List of SES email identities to verify"
	type        = list(string)
	default     = []
}

variable "create_smtp_user" {
	description = "Whether to create an SMTP IAM user for SES sending"
	type        = bool
	default     = true
}

variable "smtp_user_name" {
	description = "Optional explicit SMTP IAM username"
	type        = string
	default     = null
}

variable "secret_readonly_policy_arn" {
	description = "Optional IAM policy ARN to attach to the SMTP IAM user"
	type        = string
	default     = null
}

variable "kms_readonly_policy_arn" {
	description = "Optional KMS readonly IAM policy ARN to attach to the SMTP IAM user"
	type        = string
	default     = null
}
