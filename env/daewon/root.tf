data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}


module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = "my-unique-bucket-name"
  bucket_acl  = "public-read-write"
}