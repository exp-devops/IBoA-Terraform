# API Gateway Module

Creates an AWS API Gateway HTTP API using an OpenAPI definition generated in Terraform.

Set `include_default_paths = false` when you want to define a completely custom API via `additional_paths`.

## Default routes from exported API

- `ANY /webhook/{proxy+}` -> `webhook_integration_uri`
- `ANY /{proxy+}` -> `default_proxy_integration_uri`

## Add more APIs later

Use `additional_paths` to merge extra OpenAPI path definitions.

Example:

```hcl
api_gateway_additional_paths = {
  "/health" = {
    "x-amazon-apigateway-any-method" = {
      responses = {
        default = {
          description = "Default response"
        }
      }
      "x-amazon-apigateway-integration" = {
        payloadFormatVersion = "1.0"
        type                 = "http_proxy"
        httpMethod           = "ANY"
        uri                  = "https://example.com/health"
        connectionType       = "INTERNET"
      }
    }
  }
}
```
