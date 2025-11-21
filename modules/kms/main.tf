locals {
  common_tags = var.tags
}

resource "aws_kms_key" "tf_kms_key" {
  description         = "KMS Key"
  enable_key_rotation = true
  key_usage           = "ENCRYPT_DECRYPT"

  tags = merge(local.common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-key" }))
}

resource "aws_kms_alias" "tf_kms_alias" {
  name          = "alias/${var.project_name}-${var.project_segment}-${var.project_env}-key-alias"
  target_key_id = aws_kms_key.tf_kms_key.key_id
}
