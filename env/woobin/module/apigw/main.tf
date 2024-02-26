resource "aws_api_gateway_rest_api" "dga-apigw" {
  name = "dga-apigw"

  tags = {
    name = "dga-apigw"
  }
}

resource "aws_api_gateway_vpc_link" "dga-vpclink" {
  name        = "dga-vpclink"
  description = "dga-vpclink"
  target_arns = [var.dga-nlb-id]
}

module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  api_resource_id = aws_api_gateway_rest_api.dga-apigw.root_resource_id
}

# /boards
resource "aws_api_gateway_resource" "boards" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  parent_id   = aws_api_gateway_rest_api.dga-apigw.root_resource_id
  path_part   = "boards"
}
module "community_cors2" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  api_resource_id = aws_api_gateway_resource.boards.id
}
resource "aws_api_gateway_method" "boards" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.boards.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id
}

resource "aws_api_gateway_integration" "boards" {
  http_method = aws_api_gateway_method.boards.http_method
  resource_id = aws_api_gateway_resource.boards.id
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  type                    = "HTTP"
  uri                     = var.dga-nlb-id + "/boards"
  integration_http_method = "GET"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.dga-vpclink.id
}


/*
# /boards/write
resource "aws_api_gateway_resource" "write" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  parent_id   = aws_api_gateway_resource.boards.id
  path_part   = "write"
}
module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  api_resource_id = aws_api_gateway_resource.write.id
}
resource "aws_api_gateway_method" "write" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
}
resource "aws_api_gateway_integration" "example" {
  http_method = aws_api_gateway_method.example.http_method
  resource_id = aws_api_gateway_resource.example.id
  rest_api_id = aws_api_gateway_rest_api.example.id
  type        = "MOCK"
}


resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example.id,
      aws_api_gateway_method.example.id,
      aws_api_gateway_integration.example.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "example"
}
*/