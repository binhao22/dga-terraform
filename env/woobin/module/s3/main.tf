# 버킷 생성
resource "aws_s3_bucket" "dga-s3" {
  bucket = "brokennose.shop"
  force_destroy = true

  tags = {
    Name = "dga-s3"
  }
}

# 퍼블릭 액세스 설정
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.dga-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CORS 설정
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.dga-s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

# 정적 웹 호스팅
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.dga-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# 버킷 정책 생성
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.dga-s3.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "${aws_s3_bucket.dga-s3.arn}/*"
        }
      ]
    }
  )
}

resource "aws_s3_bucket_metric" "metric" {
  bucket = aws_s3_bucket.dga-s3.id
  name   = "dga-s3-metric"
}