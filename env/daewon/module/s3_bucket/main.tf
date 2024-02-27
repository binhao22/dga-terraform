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

# --------------------------- 1 트 -----------------------
# # AWS 리전
# provider "aws" {
#   region = var.region
# }

# # 버킷 이름 지정 및 객체 소유권
# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "test.brokennose.shop"  # 생성할 S3 버킷의 이름을 지정합니다.

#   website {
#     index_document = "index.html"  # 인덱스 문서 설정
#     error_document = "error.html"  # 오류 문서 설정
#   }
# }

# resource "aws_s3_bucket_public_access_block" "aws_s3_bucket-public-access-block-test" {
#   bucket                  = aws_s3_bucket.my_bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_ownership_controls_test" {
#   bucket = aws_s3_bucket.my_bucket.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# # aws s3 bucket acl
# resource "aws_s3_bucket_acl" "my_bucket_acl" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.aws_s3_bucket_ownership_controls_test,
#     aws_s3_bucket_public_access_block.aws_s3_bucket-public-access-block-test,
#   ]

#   bucket = aws_s3_bucket.example.id
#   acl    = "public-read"
# }

# # resource "aws_s3_bucket_policy" "my_bucket_policy" {
# #   bucket = aws_s3_bucket.my_bucket.id

# #   policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect    = "Allow"
# #         Principal = "*"
# #         Action    = ["s3:GetObject"]
# #         Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
# #       }
# #     ]
# #   })
# # }

# resource "aws_s3_bucket_cors_rule" "cors_rule" {
#   bucket = aws_s3_bucket.my_bucket.id
#   allowed_origins = ["*"]  # 모든 출처 허용, 필요에 따라 수정
#   allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]  # 허용된 HTTP 메서드 설정
#   allowed_headers = ["*"]  # 모든 헤더 허용, 필요에 따라 수정
# }


# -------------------- 2트 ---------------------------------------

# aws s3 rm s3://saju-front-prod --recursive
# terraform destroy 를 하기전에 S3 버킷 내용이 삭제되어야 한다.
# s3 버킷 생성시 AWS를 이용하는 모든 사용자들의 s3 버킷 이름과 중복해서 사용할 수 없습니다.

# AWS 리전
provider "aws" {
  region = "ap-northeast-2"
}

# S3 버킷
# 위치 : s3 > 버킷
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "create_bucket_test" {
  bucket = "test.brokennose.shop"


  tags = {
    Name = "create-bucket-test"
    Service = "create-test"
  }
}

resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = "test.brokennose.shop"   //버킷 이름

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


resource "aws_s3_bucket_ownership_controls" "create_bucket_test" {
  bucket = aws_s3_bucket.create_bucket_test.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block" {
  bucket = aws_s3_bucket.create_bucket_test.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.create_bucket_test,
    aws_s3_bucket_public_access_block.s3_block,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}


# S3 정적 웹 호스팅 엔드포인트
output "s3_endpoint" {
  value = aws_s3_bucket_website_configuration.s3.website_endpoint
}