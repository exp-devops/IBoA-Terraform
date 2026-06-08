output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_id" {
  description = "ID of the ACM certificate"
  value       = aws_acm_certificate.main.id
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.main.status
}

output "domain_validation_options" {
  description = "Domain validation options for the certificate - Use these to create DNS records in your DNS provider"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "validation_records" {
  description = "DNS validation records that need to be added to your DNS provider (formatted for easy use)"
  value = [
    for dvo in aws_acm_certificate.main.domain_validation_options : {
      domain_name  = dvo.domain_name
      record_name  = dvo.resource_record_name
      record_type  = dvo.resource_record_type
      record_value = dvo.resource_record_value
    }
  ]
}
