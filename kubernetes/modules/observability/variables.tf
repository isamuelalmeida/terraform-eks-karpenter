variable "environment" {
  type = string
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "grafana_admin_password" {
  type = string
}

variable "grafana_database_name" {
  type = string
}

variable "grafana_database_username" {
  type = string
}

variable "grafana_database_password" {
  type = string
}

variable "ingress_group_name" {
  type = string
}

variable "ingress_group_order" {
  type = string
}

variable "vpc_default_security_group_id" {
  type = string
}

variable "eks_cluster_primary_security_group_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list
}

variable "agent" {

  default = {
    traces = {
      name      = "agent-traces"
      namespace = "observability"
    }
  }
}