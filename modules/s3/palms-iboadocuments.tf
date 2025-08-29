# S3 Bucket for iboadocuments
resource "aws_s3_bucket" "tf_s3_bucket_iboadocuments" {
  bucket = "${var.project_name}-${var.project_segment}-${var.project_env}-iboadocuments"

  tags = merge(
    local.static_data_common_tags, tomap({Name = "${var.project_name}-${var.project_segment}-${var.project_env}-iboadocuments"})
  )
}

# Server-side encryption with AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_s3_bucket_iboadocuments_encryption" {
  bucket = aws_s3_bucket.tf_s3_bucket_iboadocuments.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "tf_s3_bucket_public_access_block_iboadocumets" {
  bucket = aws_s3_bucket.tf_s3_bucket_iboadocuments.id

   block_public_acls       = true
   block_public_policy     = true
   ignore_public_acls      = true
   restrict_public_buckets = true
}

# Create LoanDocuments folder
resource "aws_s3_object" "loan_documents_folder" {
  bucket  = aws_s3_bucket.tf_s3_bucket_iboadocuments.id
  key     = "LoanDocuments/"
  content = ""  # Empty content
}

# Create vendor-documents folder
resource "aws_s3_object" "vendor_documents_folder" {
  bucket  = aws_s3_bucket.tf_s3_bucket_iboadocuments.id
  key     = "vendor-documents/"
  content = ""  # Empty content
}
