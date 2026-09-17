variable "api_name" {
  description = "API Gateway API name"
  type        = string
}

variable "api_version" {
  description = "Version string to include in the OpenAPI info block"
  type        = string
  default     = "1.0.0"
}

variable "description" {
  description = "API Gateway API description"
  type        = string
  default     = null
}

variable "stage_name" {
  description = "Stage name for the HTTP API"
  type        = string
  default     = "$default"
}

variable "webhook_integration_uri" {
  description = "Integration URI for /webhook/{proxy+}"
  type        = string
  default     = null
}

variable "default_proxy_integration_uri" {
  description = "Integration URI for /{proxy+}"
  type        = string
  default     = null
}

variable "additional_paths" {
  description = "Additional OpenAPI path definitions to merge with the default exported paths"
  type        = map(any)
  default     = {}
}

variable "include_default_paths" {
  description = "Whether to include the module's built-in exported paths (/webhook/{proxy+} and /{proxy+})"
  type        = bool
  default     = true
}

variable "disable_execute_api_endpoint" {
  description = "Whether clients can invoke the API by using the default execute-api endpoint"
  type        = bool
  default     = false
}

variable "fail_on_warnings" {
  description = "Whether to roll back API creation when API Gateway import emits warnings"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}