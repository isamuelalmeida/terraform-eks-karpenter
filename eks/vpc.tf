module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = module.env_info.envs[terraform.workspace].vpc.vpc_name
  cidr = module.env_info.envs[terraform.workspace].vpc.cidr

  azs              = module.env_info.envs[terraform.workspace].vpc.azs
  private_subnets  = module.env_info.envs[terraform.workspace].vpc.private_subnets
  public_subnets   = module.env_info.envs[terraform.workspace].vpc.public_subnets
  database_subnets = module.env_info.envs[terraform.workspace].vpc.database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${module.env_info.envs[terraform.workspace].eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                                                     = "1"
    # Karpenter
    "karpenter.sh/discovery" = "true"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${module.env_info.envs[terraform.workspace].eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                                              = "1"
  }

}
