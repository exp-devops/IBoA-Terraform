# # Output all repository URLs
# output "ecr_repository_urls" {
#   description = "Map of ECR repository URLs"
#   value = {
#     for repo in local.repositories :
#     repo => aws_ecr_repository.repositories[repo].repository_url
#   }
# }

# # Output all repository ARNs
# output "ecr_repository_arns" {
#   description = "Map of ECR repository ARNs"
#   value = {
#     for repo in local.repositories :
#     repo => aws_ecr_repository.repositories[repo].arn
#   }
# }

# Output all repository names
output "ecr_repository_names" {
  description = "Map of ECR repository names"
  value = {
    for repo in local.repositories :
    repo => aws_ecr_repository.repositories[repo].name
  }
}

# Individual service repository URLs for easy access
# output "cedebe_integration_service_url" {
#   description = "ECR URL for cedebe-integration-service"
#   value       = aws_ecr_repository.repositories["cedebe-integration-service"].repository_url
# }

# output "cede_ui_url" {
#   description = "ECR URL for cede-ui"
#   value       = aws_ecr_repository.repositories["cede-ui"].repository_url
# }

output "palms_account_service_url" {
  description = "ECR URL for palms-account-service"
  value       = aws_ecr_repository.repositories["palms-account-service"].repository_url
}

output "palms_card_service_url" {
  description = "ECR URL for palms-card-service"
  value       = aws_ecr_repository.repositories["palms-card-service"].repository_url
}

output "palms_cede_integration_service_url" {
  description = "ECR URL for palms-cede-intg-service"
  value       = aws_ecr_repository.repositories["palms-cede-intg-service"].repository_url
}

output "palms_customer_service_url" {
  description = "ECR URL for palms-customer-service"
  value       = aws_ecr_repository.repositories["palms-customer-service"].repository_url
}

output "palms_decta_adaptor_service_url" {
  description = "ECR URL for palms-decta-adaptor-service"
  value       = aws_ecr_repository.repositories["palms-decta-adaptor-service"].repository_url
}

output "palms_decta_mock_service_url" {
  description = "ECR URL for palms-decta-mock-service"
  value       = aws_ecr_repository.repositories["palms-decta-mock-service"].repository_url
}

output "palms_direct_debit_service_url" {
  description = "ECR URL for palms-direct-debit-service"
  value       = aws_ecr_repository.repositories["palms-direct-debit-service"].repository_url
}

output "palms_fineract_adaptor_service_url" {
  description = "ECR URL for palms-fineract-adaptor-service"
  value       = aws_ecr_repository.repositories["palms-fineract-adaptor-service"].repository_url
}

output "palms_fineract_be_url" {
  description = "ECR URL for palms-fineract-be"
  value       = aws_ecr_repository.repositories["palms-fineract-be"].repository_url
}

output "palms_fineract_webhook_service_url" {
  description = "ECR URL for palms-fineract-webhook-service"
  value       = aws_ecr_repository.repositories["palms-fineract-webhook-service"].repository_url
}

output "palms_ledger_fineract_webapp_url" {
  description = "ECR URL for palms-ledger-fineract-webapp"
  value       = aws_ecr_repository.repositories["palms-ledger-fineract-webapp"].repository_url
}

# output "palms_liquibase_url" {
#   description = "ECR URL for palms-liquibase"
#   value       = aws_ecr_repository.repositories["palms-liquibase"].repository_url
# }

output "palms_loan_service_url" {
  description = "ECR URL for palms-loan-service"
  value       = aws_ecr_repository.repositories["palms-loan-service"].repository_url
}

output "palms_notification_service_url" {
  description = "ECR URL for palms-notification-service"
  value       = aws_ecr_repository.repositories["palms-notification-service"].repository_url
}

output "palms_portal_url" {
  description = "ECR URL for palms-portal"
  value       = aws_ecr_repository.repositories["palms-portal"].repository_url
}

output "palms_portal_engine_url" {
  description = "ECR URL for palms-portal-engine"
  value       = aws_ecr_repository.repositories["palms-portal-engine"].repository_url
}

output "palms_rest_api_service_url" {
  description = "ECR URL for palms-rest-api-service"
  value       = aws_ecr_repository.repositories["palms-rest-api-service"].repository_url
}

output "palms_rule_engine_service_url" {
  description = "ECR URL for palms-rule-engine-service"
  value       = aws_ecr_repository.repositories["palms-rule-engine-service"].repository_url
}

output "palms_splitpayment_adaptor_service_url" {
  description = "ECR URL for palms-splitpayment-adaptor-service"
  value       = aws_ecr_repository.repositories["palms-splitpayment-adaptor-service"].repository_url
}

output "palms_splitpayment_webhook_service_url" {
  description = "ECR URL for palms-splitpayment-webhook-service"
  value       = aws_ecr_repository.repositories["palms-splitpayment-webhook-service"].repository_url
}

output "palms_stc_engine_url" {
  description = "ECR URL for palms-stc-engine"
  value       = aws_ecr_repository.repositories["palms-stc-engine"].repository_url
}

output "palms_transaction_report_service_url" {
  description = "ECR URL for palms-transaction-report-service"
  value       = aws_ecr_repository.repositories["palms-transaction-report-service"].repository_url
}

output "palms_transaction_service_url" {
  description = "ECR URL for palms-transaction-service"
  value       = aws_ecr_repository.repositories["palms-transaction-service"].repository_url
}

output "palms_liquibase_url" {
  description = "ECR URL for palms-liquibase"
  value       = aws_ecr_repository.repositories["palms-liquibase"].repository_url
}

output "palms_delinquency_service_url" {
  description = "ECR URL for palms-delinquency-service"
  value       = aws_ecr_repository.repositories["palms-delinquency-service"].repository_url
}