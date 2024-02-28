resource "aws_s3_bucket" "dga-s3" {
  bucket = "daddygoagain.vacations"
  force_destroy = true

  tags = {
    Name = "dga-s3"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.dga-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.dga-s3]
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.dga-s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }

  depends_on = [aws_s3_bucket.dga-s3]
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.dga-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  depends_on = [aws_s3_bucket.dga-s3]
}

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"
}

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
            "s3:PutObject",
            "s3:ListObject"
          ],
          "Resource" : "${aws_s3_bucket.dga-s3.arn}/*"
        }
      ]
    }
  )
  depends_on = [aws_s3_bucket.dga-s3]
}

resource "aws_s3_bucket_metric" "metric" {
  bucket = aws_s3_bucket.dga-s3.id
  name   = "dga-s3-metric"

  depends_on = [aws_s3_bucket.dga-s3]
}