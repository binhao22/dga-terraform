data "tfe_outputs" "dev" {
  organization = "DGA-PROJECT"
  workspace = "dga-terraform"
}

## test_create_ec2
resource "aws_instance" "test_tf" {

  subnet_id = data.tfe_outputs.dev.values.dga-pub-1_id
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.nano"
  associate_public_ip_address = true

  tags = {
    Name = "test_daewon"
  }
}
### 