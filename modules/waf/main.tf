resource "aws_wafv2_web_acl" "alb_waf" {
  count = local.waf_enabled ? 1 : 0
  name  = "${local.name_prefix}-alb-waf"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ALB_WAF"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "geo-restriction"
    priority = 0

    action {
      allow {}
    }

    statement {
      geo_match_statement {
        country_codes = ["AU", "IN"] # Allow only Australia and India traffic
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "geo-restriction"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
  # Multi-tier DDoS Protection Rate Limiting
  rule {
    name     = "ip-based-rate-limiting-challenge"
    priority = 6

    action {
      challenge {}
    }

    statement {
      rate_based_statement {
        limit              = 1000 # Architectural requirement: 1,000 requests per 5-minute window
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-challenge"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-based-rate-limiting-captcha"
    priority = 7

    action {
      captcha {}
    }

    statement {
      rate_based_statement {
        limit              = 2000 # Second tier: CAPTCHA for higher traffic
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-captcha"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-based-rate-limiting-block"
    priority = 8

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 5000 # Final tier: Hard block for excessive traffic
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-block"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection Protection (OWASP Top 10 not available in us-east-2)
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 9
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Linux-specific Protection for RHEL9 servers
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 10
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Bot Control Protection
  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 11
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesBotControlRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Core Rule Set (most commonly available)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 12
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "waf" {
  count             = local.waf_enabled ? 1 : 0
  name              = "aws-waf-logs-${local.name_prefix}-alb-waf"
  retention_in_days = var.project_env == "prd" ? 30 : 14

  tags = merge(local.common_tags, {
    Name          = "${local.name_prefix}-waf-logs"
    ResourceGroup = "alb"
  })
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "alb_waf_logging" {
  count                   = local.waf_enabled ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.alb_waf[0].arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]

  depends_on = [
    aws_wafv2_web_acl.alb_waf,
    aws_cloudwatch_log_group.waf
  ]
}

resource "aws_wafv2_web_acl_association" "alb_waf_association" {
  count        = local.waf_enabled ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf[0].arn

  depends_on = [
    aws_wafv2_web_acl.alb_waf
  ]
}