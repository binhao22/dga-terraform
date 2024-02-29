# REST API 게이트웨이 생성
resource "aws_api_gateway_rest_api" "dga-apigw" {
  name = "dga-apigw"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  binary_media_types = ["*/*"]
  tags = {
    name = "dga-apigw"
  }
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "authorizer"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.dga-apigw.id
  provider_arns          = [var.cognito-arn]
}

# VPC Link 생성
resource "aws_api_gateway_vpc_link" "dga-vpclink" {
  name        = "dga-vpclink"
  description = "dga-vpclink"
  target_arns = [var.dga-nlb-id]

  tags = {
    name = "dga-vpclink"
  }
}

# CORS 설정
module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  for_each = {
    resource1 = aws_api_gateway_rest_api.dga-apigw.root_resource_id
    resource2 = aws_api_gateway_resource.proxy.id
  }
  api_resource_id = each.value
}

# /{proxy+} 리소스 생성
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  parent_id   = aws_api_gateway_rest_api.dga-apigw.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "any" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "proxy" {
  http_method = aws_api_gateway_method.any.http_method
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  type                    = "HTTP_PROXY"
  uri                     = format("%s%s%s", "http://", var.dga-nlb-dns, "/{proxy}")
  integration_http_method = "ANY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.dga-vpclink.id
  cache_key_parameters = ["method.request.path.proxy"]

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.any.id,
      aws_api_gateway_integration.proxy.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.dep.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id
  stage_name    = "api"
}