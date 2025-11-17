# ECR Repositories for all services

locals {
  repositories = [
    "cede-integration-service",
    "cede-ui",
    "palms-account-service",
    "palms-card-service",
    "palms-cede-intg-service",
    "palms-cede-liquibase",
    "palms-customer-service",
    "palms-decta-adaptor-service",
    "palms-decta-mock-service",
    "palms-direct-debit-service",
    "palms-fineract-adaptor-service",
    "palms-fineract-be",
    "palms-fineract-webhook-service",
    "palms-ledger-fineract-webapp",
    "palms-liquibase",
    "palms-loan-service",
    "palms-notification-service",
    "palms-portal",
    "palms-portal-engine",
    "palms-rest-api-service",
    "palms-rule-engine-service",
    "palms-splitpayment-adaptor-service",
    "palms-splitpayment-webhook-service",
    "palms-stc-engine",
    "palms-transaction-report-service",
    "palms-transaction-service"
  ]
}

resource "aws_ecr_repository" "repositories" {
  for_each = toset(local.repositories)

  name                 = "${var.project_name}-${var.project_segment}-${var.project_env}-${each.value}"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.project_segment}-${var.project_env}-${each.value}"
      Service     = each.value
      Environment = var.project_env
    }
  )
}

# Lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "repositories_policy" {
  for_each   = toset(local.repositories)
  repository = aws_ecr_repository.repositories[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
