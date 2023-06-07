module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.0"

  cluster_name    = module.env_info.envs[terraform.workspace].eks.cluster_name
  cluster_version = module.env_info.envs[terraform.workspace].eks.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  aws_auth_accounts = var.aws_auth_accounts
  aws_auth_users    = var.aws_auth_users
  aws_auth_roles    = var.aws_auth_roles

  # Karpenter
  enable_irsa = true

  node_security_group_additional_rules = {
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Node group for Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${module.env_info.envs[terraform.workspace].eks.cluster_name}" = null
  }

  tags = {
    "karpenter.sh/discovery" = module.env_info.envs[terraform.workspace].eks.cluster_name
  }

}


module "eks_managed_node_group_initial" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.31.0"

  name            = "${module.env_info.envs[terraform.workspace].eks.cluster_name}-initial"
  cluster_name    = module.env_info.envs[terraform.workspace].eks.cluster_name
  cluster_version = module.env_info.envs[terraform.workspace].eks.cluster_version

  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]

  min_size       = module.env_info.envs[terraform.workspace].eks.node_group_initial.min_size
  max_size       = module.env_info.envs[terraform.workspace].eks.node_group_initial.max_size
  desired_size   = module.env_info.envs[terraform.workspace].eks.node_group_initial.desired_size
  instance_types = module.env_info.envs[terraform.workspace].eks.node_group_initial.instance_types
  ami_type       = module.env_info.envs[terraform.workspace].eks.node_group_initial.ami_type
  capacity_type  = module.env_info.envs[terraform.workspace].eks.node_group_initial.capacity_type
  labels         = module.env_info.envs[terraform.workspace].eks.node_group_initial.labels

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = module.env_info.envs[terraform.workspace].eks.node_group_initial.disk_size
        volume_type           = "gp3"
        encrypted             = false
        delete_on_termination = true
      }
    }
  }

}