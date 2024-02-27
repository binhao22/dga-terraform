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

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"  # 생성할 S3 버킷의 이름을 지정합니다.
  acl    = "public-read-write"                # 버킷의 액세스 제어를 설정합니다.
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
