variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "project_env" {
  description = "Environment of the project (e.g., prod, qa, dev)"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the certificate (e.g., *.iboa.com.au)"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names for the certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
