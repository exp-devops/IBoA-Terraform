variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "solviprod"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "solvi-sa"
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for deployment role policy"
  type        = string
}