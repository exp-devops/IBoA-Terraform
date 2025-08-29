output "kms_key" {
  description = "The KMS key object containing ARN and ID"
  value = {
    arn = aws_kms_key.tf_kms_key.arn
    id  = aws_kms_key.tf_kms_key.key_id
  }
}
