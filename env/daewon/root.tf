data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "test.brokennosetest.shop"
#   acl    = "public-read-write"

  # control_object_ownership = true
  # object_ownership         = "ObjectWriter"

  # versioning = {
  #   enabled = true
  # }
# }

# module "s3_bucket" {
#   source = "./module/s3_bucket"
#   bucket_name = "test.brokennose.shop"
#   bucket_acl  = "public-read-write"
# }

#  -------------- 2트 -----------

module "s3_bucket" {
  source = "./modules/s3_bucket"  // 하위 모듈의 경로 지정
}