# ACM Certificate for the domain
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_env}-certificate"
    }
  )
}

# Note: Since DNS is managed outside Route 53, you need to manually create
# the DNS validation records in your DNS provider using the output values.
# The certificate will remain in "Pending Validation" state until the DNS
# records are added and propagated.
