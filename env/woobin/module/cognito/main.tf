# 자격 증명 공급자 지정
resource "aws_cognito_identity_provider" "dga-provider" {
  user_pool_id  = module.dga-userpool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = ["profile", "email", "openid"]
    client_id        = var.google_id
    client_secret    = var.google_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

# 유저풀 생성
module "dga-userpool" {

  source  = "lgallard/cognito-user-pool/aws"

  user_pool_name           = "dga-userpool"
  auto_verified_attributes = ["email"]

  admin_create_user_config = {
    email_subject = "Welcome to Daddy Go Again !!"
  }
  # 가입 인증 이메일 전송
  email_configuration = {
    email_sending_account  = "COGNITO_DEFAULT"
    reply_to_email_address = "no-reply@verificationemail.com"
  }
  # 사용자 계정 복구 방법
  recovery_mechanisms = [
     {
      name     = "verified_email"
      priority = 1
    }
  ]

  tags = {
    Name       = "dga-userpool"
  }
}

# Cognito 도메인 생성
resource "aws_cognito_user_pool_domain" "dga-dom" {
  domain       = "dga-dom"
  user_pool_id = module.dga-userpool.id
}

# 유저 풀 클라이언트 생성
resource "aws_cognito_user_pool_client" "userpool-client" {
  name                                 = "userpool-client"
  user_pool_id                         = module.dga-userpool.id
  callback_urls                        = ["https://www.daddygo.vacations/success"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers         = ["Google"]
  explicit_auth_flows                  = ["ALOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  enable_token_revocation              = true
  prevent_user_existence_errors        = true
}