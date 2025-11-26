output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = local.waf_enabled ? aws_wafv2_web_acl.alb_waf[0].arn : null
}

output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = local.waf_enabled ? aws_wafv2_web_acl.alb_waf[0].id : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for WAF"
  value       = local.waf_enabled ? aws_cloudwatch_log_group.waf[0].name : null
}