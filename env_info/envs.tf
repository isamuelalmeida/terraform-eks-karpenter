locals {
  envs = {
    default = {
      region = "us-east-1"
    }

    dev = {
      environment = "dev"
      region      = "us-east-1"
      domain          = "dev.samweb.link"
      certificate_arn = "arn:aws:acm:us-east-1:968644489163:certificate/50ac7c72-e446-43cf-bfa3-c44b7709dbac"

      vpc = {
        vpc_name         = "sam-eks-dev"
        azs              = ["us-east-1a", "us-east-1b"]
        private_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
        public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
        database_subnets = ["10.0.5.0/25", "10.0.5.128/25"]
        cidr             = "10.0.0.0/20"
      }

      eks = {
        cluster_name = "sam-eks-dev"
        cluster_version = "1.23"

        node_group_general = {
          min_size       = 0
          max_size       = 4
          desired_size   = 0
          disk_size      = 30
          instance_types = ["t3a.medium"]
          ami_type       = "AL2_x86_64"
          capacity_type  = "ON_DEMAND"
          labels = {
            nodeTypeClass = "geral"
          }
        }

        node_group_initial = {
          min_size       = 1
          max_size       = 4
          desired_size   = 1
          disk_size      = 20
          instance_types = ["t3a.medium"]
          ami_type       = "AL2_x86_64"
          capacity_type  = "SPOT"
          labels = {
            nodeTypeClass = "karpenter"
          }
        }

      }

      grafana = {
        database = {
          dbname         = "grafana"
        }
      }

    }

    stage = {
      environment = "stage"
      region      = "us-east-1"
      domain          = "stage.samweb.link"
      certificate_arn = "arn:aws:acm:us-east-1:703669458031:certificate/2d21659a-9a04-4a87-8d30-c81dac0a0ddb"

      vpc = {
        vpc_name         = "sam-eks-stage"
        azs              = ["us-east-1a", "us-east-1b"]
        private_subnets  = ["10.100.0.0/24", "10.100.1.0/24"]
        public_subnets   = ["10.100.3.0/24", "10.100.4.0/24"]
        database_subnets = ["10.100.5.0/25", "10.100.5.128/25"]
        cidr             = "10.100.0.0/20"
      }

      eks = {
        cluster_name = "sam-eks-stage"

        node_group_microservices = {
          min_size       = 1
          max_size       = 4
          desired_size   = 2
          disk_size      = 50
          instance_types = ["t3a.small"]
          ami_type       = "AL2_x86_64"
          capacity_type  = "ON_DEMAND"
          labels = {
            nodeTypeClass = "stage"
          }
        }

      }

      grafana = {
        database = {
          dbname         = "grafana"
          instance_class = "db.t3.micro"
        }
      }
    }

    prod = {
      environment = "prod"
      region      = "us-east-1"
      domain          = "samweb.link"
      certificate_arn = "arn:aws:acm:us-east-1:703669458031:certificate/2d21659a-9a04-4a87-8d30-c81dac0a0ddb"

      vpc = {
        vpc_name         = "sam-eks-prod"
        azs              = ["us-east-1a", "us-east-1b"]
        private_subnets  = ["10.200.0.0/24", "10.200.1.0/24"]
        public_subnets   = ["10.200.3.0/24", "10.200.4.0/24"]
        database_subnets = ["10.200.5.0/25", "10.200.5.128/25"]
        cidr             = "10.200.0.0/20"
      }

      eks = {
        cluster_name = "sam-eks-prod"

        node_group_microservices = {
          min_size       = 1
          max_size       = 4
          desired_size   = 2
          disk_size      = 50
          instance_types = ["t3a.small"]
          ami_type       = "AL2_x86_64"
          capacity_type  = "ON_DEMAND"
          labels = {
            nodeTypeClass = "production"
          }
        }

      }

      grafana = {
        database = {
          dbname         = "grafana"
          instance_class = "db.t3.micro"
        }
      }
    }

    alb = {
      ingress = {
        group_orders = {
          grafana = "1"
        }
      }
    }

    default_tags = {
      "contato" = "samuelsaiwmon@gmail.com"
      "iac"     = "Terraform"
      "repo"    = "https://github.com/teste"
    }
    default_tag_estagio_by_env = {
      "default" = "DEV"
      "dev"     = "DEV"
      "stage"   = "HML"
      "prod"    = "PRD"
    }

  }
}