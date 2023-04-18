module "env_info" {
  source = "../env_info"
}

variable "aws_auth_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "968644489163"
  ]
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::968644489163:user/admin-eks"
      username = "admin-eks"
      groups   = ["system:masters"]
    }
  ]
}

variable "aws_auth_roles" {
  description = "Additional IAM groups to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::968644489163:role/RoleAdministratorAccess"
      username = "RoleAdministratorAccess"
      groups   = ["system:masters"]
    }
  ]
}