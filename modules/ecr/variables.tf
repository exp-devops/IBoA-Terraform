variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_segment" {
  description = "The segment of the project"
  type        = string
}

variable "project_env" {
  description = "The environment of the project"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
