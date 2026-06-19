
/*output "alb_logs_S3_Bucket" {
  value = "${aws_s3_bucket.tf_s3_bucket_alb_logs}"
}*/
output "qaiboadocuments_S3_Bucket" {
  value = aws_s3_bucket.tf_s3_bucket_qaiboadocuments
}

output "qaiboadocuments_mrap_alias" {
  value = aws_s3control_multi_region_access_point.qaiboadocuments_mrap.alias
}

output "qaiboadocuments_mrap_arn" {
  value = "arn:aws:s3::${data.aws_caller_identity.current.account_id}:accesspoint/${aws_s3control_multi_region_access_point.qaiboadocuments_mrap.details[0].name}"
}