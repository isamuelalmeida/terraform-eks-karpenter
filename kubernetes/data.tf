data "terraform_remote_state" "eks" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket  = "infra-sam-terraform-state"
    key     = "infra-sam-eks.tfstate"
    region  = "us-east-1"
    profile = "samuel"
  }
}

data "aws_ssm_parameter" "grafana_admin_password" {
  name = "/${terraform.workspace}/grafana_admin_password"
}

data "aws_ssm_parameter" "grafana_database_username" {
  name = "/${terraform.workspace}/grafana_database_username"
}

data "aws_ssm_parameter" "grafana_database_password" {
  name = "/${terraform.workspace}/grafana_database_password"
}

data "aws_ssm_parameter" "infra_s3_access_key_id" {
  name = "/infra_s3_access_key_id"
}

data "aws_ssm_parameter" "infra_s3_secret_access_key" {
  name = "/infra_s3_secret_access_key"
}