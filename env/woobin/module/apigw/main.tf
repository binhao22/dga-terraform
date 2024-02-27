# REST API 게이트웨이 생성
resource "aws_api_gateway_rest_api" "dga-apigw" {
  name = "dga-apigw"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    name = "dga-apigw"
  }
}

# VPC Link 생성
resource "aws_api_gateway_vpc_link" "dga-vpclink" {
  name        = "dga-vpclink"
  description = "dga-vpclink"
  target_arns = [var.dga-nlb-id]
}

# CORS 설정
module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  for_each = toset( [aws_api_gateway_rest_api.dga-apigw.root_resource_id, aws_api_gateway_resource.boards.id] )
  api_resource_id = each.key
}

# /{proxy+} 리소스 생성
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  parent_id   = aws_api_gateway_rest_api.dga-apigw.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "any" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id
}
resource "aws_api_gateway_integration" "proxy" {
  http_method = aws_api_gateway_method.proxy.http_method
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  type                    = "HTTP"
  uri                     = format("%s%s%s", "http://", var.dga-nlb-dns, "/{proxy}")
  integration_http_method = "ANY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.dga-vpclink.id
}



/*
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