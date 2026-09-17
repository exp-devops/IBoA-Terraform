output "api_id" {
  description = "API Gateway HTTP API ID"
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "API Gateway HTTP API ARN"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Default invoke endpoint for API Gateway HTTP API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "stage_invoke_url" {
  description = "Invoke URL for the configured stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "execution_arn" {
  description = "Execution ARN of API Gateway HTTP API"
  value       = aws_apigatewayv2_api.this.execution_arn
}