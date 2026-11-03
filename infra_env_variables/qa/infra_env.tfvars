############################### Common Variables ###############################
project_name         = "iboa"
project_segment      = "solvi"
project_env          = "qa"
aws_region           = "ap-southeast-2"
aws_cli_profile_name = "iboasolviqa"

tags = {
  "Project" = "iboa-solvi"
}

############################### VPC Variables ###############################
network_cidr           = "10.3.0.0/16"
public_subnet_01_cidr  = "10.3.1.0/24"
public_subnet_02_cidr  = "10.3.2.0/24"
private_subnet_01_cidr = "10.3.3.0/24"
private_subnet_02_cidr = "10.3.4.0/24"

############################### RDS Database ###############################
rdsProperty = {
  "ENGINE"                     = "postgres"
  "ENGINE_VERSION"             = "14.19"
  "INSTANCE_CLASS"             = "db.t3.small"
  "BACKUP_RETENTION_PERIOD"    = "7"
  "MULTI_AZ"                   = false
  "PORT"                       = "5432"
  "DELETION_PROTECTION"        = false
  "USERNAME"                   = "solviqadbuser"
  "DATABASE_NAME"              = "solviqadb"
  "ALLOCATED_STORAGE"          = "100"
  "STORAGE_TYPE"               = "gp3"
  "MAX_ALLOCATED_STORAGE"      = "1000"
  "BACKUP_WINDOW"              = "15:00-15:30"
  "MAINTENANCE_WINDOW"         = "Mon:16:00-Mon:17:30"
  "AUTO_MINOR_VERSION_UPGRADE" = "false"
  "SKIP_FINAL_SNAPSHOT"        = false
  "FINAL_SNAPSHOT_IDENTIFIER"  = "terraform-finalisnapshot"
  #"parameterGroupFamily"      = "postgres14"
}

# rdsProperty_mysql = {
#   "ENGINE"                     = "mysql"
#   "ENGINE_VERSION"             = "8.0.42"
#   "INSTANCE_CLASS"             = "db.t3.micro"
#   "BACKUP_RETENTION_PERIOD"    = "7"
#   "MULTI_AZ"                   = false
#   "PORT"                       = "3306"
#   "DELETION_PROTECTION"        = false
#   "USERNAME"                   = "fineractadmin"
#   "DATABASE_NAME"              = "fineractDB"
#   "ALLOCATED_STORAGE"          = "20"
#   "STORAGE_TYPE"               = "gp3"
#   "MAX_ALLOCATED_STORAGE"      = "100"
#   "BACKUP_WINDOW"              = "18:00-18:30"
#   "MAINTENANCE_WINDOW"         = "Tue:16:00-Tue:17:30"
#   "AUTO_MINOR_VERSION_UPGRADE" = "false"
#   "SKIP_FINAL_SNAPSHOT"        = false
#   "FINAL_SNAPSHOT_IDENTIFIER"  = "terraform-finalisnapshot-mysql"
# }

palms_rds_allowed_ips = {
  "103.121.27.178/32" = "experion_tvm_forticlient_primary"
  "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
  "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
  "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
}

# fineract_rds_allowed_ips = {
#   "103.121.27.178/32" = "experion_tvm_forticlient_primary"
#   "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
#   "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
#   "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
# }

############################### EKS ###############################
eksProperty = {
  "CLUSTER_VERSION"       = "1.35"
  "NODE_INSTANCE_TYPE"    = "t3a.medium"
  "NODE_DISK_SIZE"        = "30"
  "SOLVIGENERAL_DESIRED_SIZE"    = "2"
  "SOLVIGENERAL_MAX_SIZE"        = "3"
  "SOLVIGENERAL_MIN_SIZE"        = "2"
  "SOLVIDEDICATED_DESIRED_SIZE"  = "3"
  "SOLVIDEDICATED_MAX_SIZE"      = "7"
  "SOLVIDEDICATED_MIN_SIZE"      = "3"
  "FINERACT_DESIRED_SIZE" = "1"
  "FINERACT_MAX_SIZE"     = "2"
  "FINERACT_MIN_SIZE"     = "1"
  # "FINECTE_DESIRED_SIZE"  = "0"
  # "FINECTE_MAX_SIZE"      = "1"
  # "FINECTE_MIN_SIZE"      = "0"
}

############################### EC2 ###############################
bastionEC2 = {
  "ami"                   = "ami-0bf1982bfc7bbc490"
  "instance_type"         = "t3a.micro"
  "volume_size"           = "8"
  "volume_type"           = "gp3"
  "encrypted"             = "true"
  "delete_on_termination" = "true"
}

bastion_ssh_allowed_ips = {
  "103.121.27.178/32" = "experion_tvm_forticlient_primary"
  "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
  "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
  "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
}

# RabbitMQ EC2
# rabbitmqEC2 = {
#   "ami"                   = "ami-0deeb71371199f16f" # 
#   "instance_type"         = "t3.micro"
#   "volume_size"           = "8"
#   "volume_type"           = "gp3"
#   "delete_on_termination" = true
# }

############################### ACM Certificate ###############################
domain_name               = "*.iboa.com.au"
subject_alternative_names = ["iboa.com.au"]
# Note: DNS is managed externally. After terraform apply, use the output
# 'validation_records' to manually create DNS CNAME records in your DNS provider.

############################### SES ###############################
ses_domains                  = ["qaemail.iboa.com.au"]
ses_verified_email_addresses = ["bhaskar.nandagopal@experionglobal.com", "reshma.reghu@experionglobal.com", "steffin.tomy@experionglobal.com", "neethu.k@experionglobal.com", "billy.wang@iboa.com.au", "eelin.sim@iboa.com.au", "jennifer.jin@eurusam.com.au", "cindy.lui@iboa.com.au", "huey.chew@iboa.com.au", "akhil.ramagiri@iboa.com.au" ]
# Optional: Override default SMTP IAM username.
ses_smtp_user_name = "ses-qa-smtp"

############################### API Gateway ###############################
api_gateways = {
  zepto = {
    api_name                     = "Zepto API"
    api_version                  = "2026-07-16 06:21:36UTC"
    description                  = "Zepto API HTTP proxy"
    stage_name                   = "$default"
    include_default_paths        = true
    webhook_integration_uri      = "https://qa-solvi.iboa.com.au:9095/{proxy}"
    default_proxy_integration_uri = "https://api.sandbox.zeptopayments.com/{proxy}"
    additional_paths             = {}
    disable_execute_api_endpoint = false
    fail_on_warnings             = false
    tags                         = {}
  }

  zoho = {
    api_name                      = "Zoho API"
    api_version                   = "2026-07-16 09:27:11UTC"
    description                   = "Zoho API HTTP proxy"
    stage_name                    = "$default"
    include_default_paths         = false
    webhook_integration_uri       = null
    default_proxy_integration_uri = null
    additional_paths = {
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
            uri                  = "https://sign.zoho.com.au/api/v1/{proxy}"
            connectionType       = "INTERNET"
            timeoutInMillis      = 30000
          }
        }
      }
    }
    disable_execute_api_endpoint = false
    fail_on_warnings             = false
    tags                         = {}
  }

  gocardless = {
    api_name                      = "GoCardless"
    api_version                   = "2026-09-28 13:08:11UTC"
    description                   = "GoCardless API HTTP proxy"
    stage_name                    = "$default"
    include_default_paths         = false
    webhook_integration_uri       = null
    default_proxy_integration_uri = null
    additional_paths = {
      "/api/gocardless/payments/{paymentId}" = {
        get = {
          responses = {
            default = {
              description = "Default response for GET /api/gocardless/payments/{paymentId}"
            }
          }
          "x-amazon-apigateway-integration" = {
            payloadFormatVersion = "1.0"
            type                 = "http_proxy"
            httpMethod           = "GET"
            uri                  = "https://api-sandbox.gocardless.com/payments/{paymentId}"
            connectionType       = "INTERNET"
          }
        }
        parameters = [
          {
            name        = "paymentId"
            in          = "path"
            description = "Generated path parameter for paymentId"
            required    = true
            schema = {
              type = "string"
            }
          }
        ]
      }
      "/api/gocardless/webhook" = {
        post = {
          responses = {
            default = {
              description = "Default response for POST /api/gocardless/webhook"
            }
          }
          "x-amazon-apigateway-integration" = {
            payloadFormatVersion = "1.0"
            type                 = "http_proxy"
            httpMethod           = "POST"
            uri                  = "https://qa-solvi.iboa.com.au/api/spw/api/gocardless/webhook"
            connectionType       = "INTERNET"
          }
        }
      }
    }
    disable_execute_api_endpoint = false
    fail_on_warnings             = false
    tags                         = {}
  }
}

############################### VPC Peering for Jenkins ###############################
vpc_peering_connection_id = "pcx-01fdf51ffe6439c30"
jenkins_vpc_cidr          = "10.15.0.0/16"

