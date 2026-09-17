locals {
  selected_default_paths = var.include_default_paths ? local.default_paths : {}

  default_paths = {
    "/webhook/{proxy+}" = {
      parameters = [
        {
          name        = "proxy+"
          in          = "path"
          description = "Generated path parameter for proxy+"
          required    = true
          schema = {
            type = "string"
          }
        }
      ]
      "x-amazon-apigateway-any-method" = {
        responses = {
          default = {
            description = "Default response for ANY /webhook/{proxy+}"
          }
        }
        "x-amazon-apigateway-integration" = {
          payloadFormatVersion = "1.0"
          type                 = "http_proxy"
          httpMethod           = "ANY"
          uri                  = var.webhook_integration_uri
          connectionType       = "INTERNET"
        }
      }
    }
    "/{proxy+}" = {
      parameters = [
        {
          name        = "proxy+"
          in          = "path"
          description = "Generated path parameter for proxy+"
          required    = true
          schema = {
            type = "string"
          }
        }
      ]
      "x-amazon-apigateway-any-method" = {
        responses = {
          default = {
            description = "Default response for ANY /{proxy+}"
          }
        }
        "x-amazon-apigateway-integration" = {
          payloadFormatVersion = "1.0"
          type                 = "http_proxy"
          httpMethod           = "ANY"
          uri                  = var.default_proxy_integration_uri
          connectionType       = "INTERNET"
        }
      }
    }
  }

  openapi_document = {
    openapi = "3.0.1"
    info = {
      title   = var.api_name
      version = var.api_version
    }
    paths = merge(local.selected_default_paths, var.additional_paths)
    "x-amazon-apigateway-importexport-version" = "1.0"
  }
}

resource "aws_apigatewayv2_api" "this" {
  name              = var.api_name
  protocol_type     = "HTTP"
  description       = var.description
  body              = jsonencode(local.openapi_document)
  fail_on_warnings  = var.fail_on_warnings
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  tags              = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true
  tags        = var.tags
}