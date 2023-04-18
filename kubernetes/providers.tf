terraform {
  required_version = "~> 1.0"

  backend "s3" {
    bucket  = "infra-sam-terraform-state"
    key     = "infra-sam-kubernetes.tfstate"
    region  = "us-east-1"
    profile = "samuel"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

provider "aws" {
  region  = module.env_info.envs[terraform.workspace].region
  profile = "samuel"

  default_tags {
    tags = merge(
      module.env_info.envs.default_tags,
      { "estagio" = module.env_info.envs.default_tag_estagio_by_env[terraform.workspace] }
    )
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}