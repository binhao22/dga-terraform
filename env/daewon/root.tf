data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}


module "s3_bucket" {
  source = "./module/s3_bucket"

  bucket_name = "test.brokennose.shop"
  bucket_acl  = "public-read-write"
}