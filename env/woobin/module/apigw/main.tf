# REST API 게이트웨이 생성
resource "aws_api_gateway_rest_api" "dga-apigw" {
  name = "dga-apigw"
  endpoint_configuration {
    # 동일 리전 서비스에 적합
    types = ["REGIONAL"]
  }
  # 모든 파일을 허용
  binary_media_types = ["*/*"]
  tags = {
    name = "dga-apigw"
  }
}

# 권한부여자 생성
resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "authorizer"
  type                   = "COGNITO_USER_POOLS"
  # 위에 생성한 REST API 와 연동
  rest_api_id            = aws_api_gateway_rest_api.dga-apigw.id
  # 코그니토를 권한부여자로 지정
  provider_arns          = [var.cognito-arn]
}

# VPC Link 생성
resource "aws_api_gateway_vpc_link" "dga-vpclink" {
  name        = "dga-vpclink"
  description = "dga-vpclink"
  # VPC Link + NLB 통합
  target_arns = [var.dga-nlb-id]

  tags = {
    name = "dga-vpclink"
  }
}

# CORS 설정
module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  # APIGW 의 모든 리소스 (루트 경로와 프록시 경로 모두 CORS 허용)
  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  for_each = {
    resource1 = aws_api_gateway_rest_api.dga-apigw.root_resource_id
    resource2 = aws_api_gateway_resource.proxy.id
  }
  api_resource_id = each.value
}

# /{proxy+} 리소스 생성
# API URI 를 일일이 지정하지않고, 프록시 통합으로 모든 요청을 파라미터로 처리
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  # 루트 경로 하위에 포함
  parent_id   = aws_api_gateway_rest_api.dga-apigw.root_resource_id
  path_part   = "{proxy+}"
}

# /{proxy+}/ 메서드 생성
resource "aws_api_gateway_method" "any" {
  # 코그니토 인증을 거치도록 설정
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
  # 모든 HTTP 요청을 허용
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id
  # proxy 파라미터 값을 추가
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# 메서드 통합
resource "aws_api_gateway_integration" "proxy" {
  http_method = aws_api_gateway_method.any.http_method
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  # 프록시 통합 설정
  type                    = "HTTP_PROXY"
  # NLB 엔드포인트 설정
  uri                     = format("%s%s%s", "http://", var.dga-nlb-dns, "/{proxy}")
  integration_http_method = "ANY"
  # VPC Link 를 통해 통합
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.dga-vpclink.id
  cache_key_parameters = ["method.request.path.proxy"]

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# API 게이트웨이 배포
resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
  # 트리거를 설정해 자동 배포 설정
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.any.id,
      aws_api_gateway_integration.proxy.id,
    ]))
  }

  # 리소스 재생성 전 우선 삭제
  lifecycle {
    create_before_destroy = true
  }
}

# API 게이트웨이 배포 스테이지 생성
resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.dep.id
  rest_api_id   = aws_api_gateway_rest_api.dga-apigw.id
  # 도메인/api 의 요청은 API 게이트웨이가 처리
  stage_name    = "api"
}