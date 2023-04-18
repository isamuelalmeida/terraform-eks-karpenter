module "load_balancer_controller" {
  source = "./modules/load-balancer-controller"

  vpc_id       = data.terraform_remote_state.eks.outputs.vpc_id
  cluster_name = module.env_info.envs[terraform.workspace].eks.cluster_name
  region       = module.env_info.envs[terraform.workspace].region
  role_arn     = data.terraform_remote_state.eks.outputs.eks_load_balancer_controller_role_arn
}

module "observability" {
  source = "./modules/observability"

  certificate_arn = module.env_info.envs[terraform.workspace].certificate_arn
  domain          = module.env_info.envs[terraform.workspace].domain
  environment     = module.env_info.envs[terraform.workspace].environment

  # Ingress
  ingress_group_name  = module.env_info.envs[terraform.workspace].eks.cluster_name
  ingress_group_order = lookup(module.env_info.envs.alb.ingress.group_orders, "grafana")

  # Access Key - S3
  aws_access_key_id     = data.aws_ssm_parameter.infra_s3_access_key_id.value
  aws_secret_access_key = data.aws_ssm_parameter.infra_s3_secret_access_key.value

  # RDS
  grafana_admin_password    = data.aws_ssm_parameter.grafana_admin_password.value
  grafana_database_name     = module.env_info.envs[terraform.workspace].grafana.database.dbname
  grafana_database_username = data.aws_ssm_parameter.grafana_database_username.value
  grafana_database_password = data.aws_ssm_parameter.grafana_database_password.value

  vpc_default_security_group_id         = data.terraform_remote_state.eks.outputs.vpc_default_security_group_id
  eks_cluster_primary_security_group_id = data.terraform_remote_state.eks.outputs.eks_cluster_primary_security_group_id

  db_subnet_group_name = data.terraform_remote_state.eks.outputs.vpc_database_subnet_group_name
  subnet_ids           = data.terraform_remote_state.eks.outputs.vpc_database_subnets
}