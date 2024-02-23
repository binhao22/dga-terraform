data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

## test_create_ec2
resource "aws_instance" "test_tf" {

  subnet_id = data.tfe_outputs.woobin.values.dga-pub-1-id
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.nano"
  associate_public_ip_address = true

  tags = {
    Name = "test_tf"
  }
}