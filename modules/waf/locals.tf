locals {
  name_prefix = "${var.project_name}-${var.project_env}"
  waf_enabled = var.waf_enabled
  common_tags = merge(var.tags, {
    Environment = var.project_env
  })
}