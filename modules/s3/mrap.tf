# Get current AWS account ID
data "aws_caller_identity" "current" {}
resource "aws_s3control_multi_region_access_point" "qaiboadocuments_mrap" {
  details {
    name = "qaiboadocuments-mrap"

    region {
      bucket = aws_s3_bucket.tf_s3_bucket_qaiboadocuments.id
    }

    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
}