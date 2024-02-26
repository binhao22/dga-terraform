resource "aws_api_gateway_rest_api" "dga-apigw" {
  name = "dga-apigw"

  tags = {
    name = "dga-apigw"
  }
}

module "community_cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.dga-apigw.id
  api_resource_id = [aws_api_gateway_rest_api.dga-apigw.root_resource_id, aws_api_gateway_resource.dga-apigw-boards.id]
}

resource "aws_api_gateway_resource" "dga-apigw-boards" {
  parent_id   = aws_api_gateway_rest_api.dga-apigw.root_resource_id
  path_part   = "boards"
  rest_api_id = aws_api_gateway_rest_api.dga-apigw.id
}