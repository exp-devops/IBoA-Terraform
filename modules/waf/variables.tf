variable "project_env" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "waf_enabled" {
  description = "Enable WAF resources"
  type        = bool
  default     = true
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate with WAF"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}