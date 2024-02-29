# S3 버킷 id
output "s3-id" {
  value = aws_s3_bucket.dga-s3.website_endpoint
}