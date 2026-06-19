# S3 Bucket for iboadocuments
// Preserve state when renaming the Terraform resource address.
moved {
  from = aws_s3_bucket.tf_s3_bucket_iboadocuments
  to   = aws_s3_bucket.tf_s3_bucket_qaiboadocuments
}

resource "aws_s3_bucket" "tf_s3_bucket_qaiboadocuments" {
  bucket = "qaiboadocuments"

  tags = merge(
    local.static_data_common_tags, tomap({ Name = "qaiboadocuments" })
  )
}

# Server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_s3_bucket_qaiboadocuments_encryption" {
  bucket = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "tf_s3_bucket_qaiboadocuments_versioning" {
  bucket = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "tf_s3_bucket_public_access_block_qaiboadocuments" {
  bucket = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy to enforce encryption
resource "aws_s3_bucket_policy" "tf_s3_bucket_qaiboadocuments_policy" {
  bucket = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowMRAPAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:*"]
        Resource = [
          aws_s3_bucket.tf_s3_bucket_qaiboadocuments.arn,
          "${aws_s3_bucket.tf_s3_bucket_qaiboadocuments.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "s3:DataAccessPointAccount" : data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "DenyIncorrectEncryptionHeader"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.tf_s3_bucket_qaiboadocuments.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.tf_s3_bucket_qaiboadocuments.arn}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = true
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.tf_s3_bucket_public_access_block_qaiboadocuments]
}

# # Create LoanDocuments folder
# resource "aws_s3_object" "loan_documents_folder" {
#   bucket  = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id
#   key     = "LoanDocuments/"
#   content = "" # Empty content
# }

# # Create vendor-documents folder
# resource "aws_s3_object" "vendor_documents_folder" {
#   bucket  = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id
#   key     = "vendor-documents/"
#   content = "" # Empty content
# }
