output "s3-id" {
  value = aws_s3_bucket.dga-s3.bucket_regional_domain_name
}