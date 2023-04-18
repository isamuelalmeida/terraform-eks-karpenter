module "rds_grafana" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.7.0"

  identifier = "grafana-${terraform.workspace}"

  engine            = "postgres"
  engine_version    = "13.7"
  instance_class    = "db.t4g.micro"
  allocated_storage = 100

  db_name  = var.grafana_database_name
  username = var.grafana_database_username
  password = var.grafana_database_password

  create_random_password = false

  vpc_security_group_ids = [
    var.vpc_default_security_group_id,
    var.eks_cluster_primary_security_group_id
  ]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  db_subnet_group_name = var.db_subnet_group_name
  subnet_ids           = var.subnet_ids

  family = "postgres13"

  major_engine_version = "13.7"

  deletion_protection = false

  backup_retention_period = 0

  skip_final_snapshot = true
}

