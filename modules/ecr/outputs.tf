# Output all repository URLs
output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for repo in local.repositories :
    repo => aws_ecr_repository.repositories[repo].repository_url
  }
}

# Output all repository ARNs
output "ecr_repository_arns" {
  description = "Map of ECR repository ARNs"
  value = {
    for repo in local.repositories :
    repo => aws_ecr_repository.repositories[repo].arn
  }
}

# Output all repository names
output "ecr_repository_names" {
  description = "Map of ECR repository names"
  value = {
    for repo in local.repositories :
    repo => aws_ecr_repository.repositories[repo].name
  }
}

# Individual service repository URLs for easy access
output "cedebe_integration_service_url" {
  description = "ECR URL for cedebe-integration-service"
  value       = aws_ecr_repository.repositories["cedebe-integration-service"].repository_url
}

output "cede_ui_url" {
  description = "ECR URL for cede-ui"
  value       = aws_ecr_repository.repositories["cede-ui"].repository_url
}

output "account_service_url" {
  description = "ECR URL for account-service"
  value       = aws_ecr_repository.repositories["account-service"].repository_url
}

output "card_service_url" {
  description = "ECR URL for card-service"
  value       = aws_ecr_repository.repositories["card-service"].repository_url
}

output "cede_integration_service_url" {
  description = "ECR URL for cede-integration-service"
  value       = aws_ecr_repository.repositories["cede-integration-service"].repository_url
}

output "cede_liquibase_url" {
  description = "ECR URL for cede-liquibase"
  value       = aws_ecr_repository.repositories["cede-liquibase"].repository_url
}

output "customer_service_url" {
  description = "ECR URL for customer-service"
  value       = aws_ecr_repository.repositories["customer-service"].repository_url
}

output "decta_adaptor_service_url" {
  description = "ECR URL for decta-adaptor-service"
  value       = aws_ecr_repository.repositories["decta-adaptor-service"].repository_url
}

output "decta_mock_service_url" {
  description = "ECR URL for decta-mock-service"
  value       = aws_ecr_repository.repositories["decta-mock-service"].repository_url
}

output "direct_debit_service_url" {
  description = "ECR URL for direct-debit-service"
  value       = aws_ecr_repository.repositories["direct-debit-service"].repository_url
}

output "fineract_adaptor_service_url" {
  description = "ECR URL for fineract-adaptor-service"
  value       = aws_ecr_repository.repositories["fineract-adaptor-service"].repository_url
}

output "fineract_be_url" {
  description = "ECR URL for fineract-be"
  value       = aws_ecr_repository.repositories["fineract-be"].repository_url
}

output "fineract_webhook_service_url" {
  description = "ECR URL for fineract-webhook-service"
  value       = aws_ecr_repository.repositories["fineract-webhook-service"].repository_url
}

output "ledger_fineract_webapp_url" {
  description = "ECR URL for ledger-fineract-webapp"
  value       = aws_ecr_repository.repositories["ledger-fineract-webapp"].repository_url
}

output "liquibase_url" {
  description = "ECR URL for liquibase"
  value       = aws_ecr_repository.repositories["liquibase"].repository_url
}

output "loan_service_url" {
  description = "ECR URL for loan-service"
  value       = aws_ecr_repository.repositories["loan-service"].repository_url
}

output "notification_service_url" {
  description = "ECR URL for notification-service"
  value       = aws_ecr_repository.repositories["notification-service"].repository_url
}

output "portal_url" {
  description = "ECR URL for portal"
  value       = aws_ecr_repository.repositories["portal"].repository_url
}

output "portal_engine_url" {
  description = "ECR URL for portal-engine"
  value       = aws_ecr_repository.repositories["portal-engine"].repository_url
}

output "rest_api_service_url" {
  description = "ECR URL for rest-api-service"
  value       = aws_ecr_repository.repositories["rest-api-service"].repository_url
}

output "rule_engine_service_url" {
  description = "ECR URL for rule-engine-service"
  value       = aws_ecr_repository.repositories["rule-engine-service"].repository_url
}

output "splitpayment_adaptor_service_url" {
  description = "ECR URL for splitpayment-adaptor-service"
  value       = aws_ecr_repository.repositories["splitpayment-adaptor-service"].repository_url
}

output "splitpayment_webhook_service_url" {
  description = "ECR URL for splitpayment-webhook-service"
  value       = aws_ecr_repository.repositories["splitpayment-webhook-service"].repository_url
}

output "stc_engine_url" {
  description = "ECR URL for stc-engine"
  value       = aws_ecr_repository.repositories["stc-engine"].repository_url
}

output "transaction_report_service_url" {
  description = "ECR URL for transaction-report-service"
  value       = aws_ecr_repository.repositories["transaction-report-service"].repository_url
}

output "transaction_service_url" {
  description = "ECR URL for transaction-service"
  value       = aws_ecr_repository.repositories["transaction-service"].repository_url
}
