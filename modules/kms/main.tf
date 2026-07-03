locals {
  common_tags = var.tags
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "tf_kms_key_policy" {
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCrossAccountS3Uploads"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::228886154405:role/cede-irsa-role",
        "arn:aws:iam::507217480696:role/s3_access_role_cede"
      ]
    }

    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowEBSUsageViaEC2"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "tf_kms_key" {
  description         = "KMS Key"
  enable_key_rotation = true
  key_usage           = "ENCRYPT_DECRYPT"
  policy              = data.aws_iam_policy_document.tf_kms_key_policy.json

  tags = merge(local.common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-key" }))
}

resource "aws_kms_alias" "tf_kms_alias" {
  name          = "alias/${var.project_name}-${var.project_segment}-${var.project_env}-key-alias"
  target_key_id = aws_kms_key.tf_kms_key.key_id
}