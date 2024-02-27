# # 다른 워크스페이스의 variables 값 사용을 위해
# data "tfe_outputs" "woobin" {
#   organization = "DGA-PROJECT"
#   workspace = "woobin"
# }




# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "brokennosetest.shop"
#   acl    = "public-read-write"

#   control_object_ownership = true
#   object_ownership         = "ObjectWriter"

#   versioning = {
#     enabled = true
#   }
# }

# AWS 리전
provider "aws" {
  region = var.region
}

# 버킷 이름 지정 및 객체 소유권
resource "aws_s3_bucket" "my_bucket" {
  bucket = "test.brokennose.shop"  # 생성할 S3 버킷의 이름을 지정합니다.
  acl    = "public-read-write"     # 버킷의 액세스 제어를 설정합니다.

  website {
    index_document = "index.html"  # 인덱스 문서 설정
    error_document = "error.html"  # 오류 문서 설정
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access-block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_cors_rule" "cors_rule" {
  bucket = aws_s3_bucket.my_bucket.id

  allowed_origins = ["*"]  # 모든 출처 허용, 필요에 따라 수정
  allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]  # 허용된 HTTP 메서드 설정
  allowed_headers = ["*"]  # 모든 헤더 허용, 필요에 따라 수정
}


