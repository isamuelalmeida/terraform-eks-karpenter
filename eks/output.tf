## NETWORK
output "vpc_id" { value = module.vpc.vpc_id }
output "vpc_default_security_group_id" { value = module.vpc.default_security_group_id }
output "vpc_database_subnet_group_name" { value = module.vpc.database_subnet_group_name }
output "vpc_database_subnets" { value = module.vpc.database_subnets }
output "private_route_table_ids" { value = module.vpc.private_route_table_ids }
output "route_table_cidr_block" { value = module.vpc.vpc_cidr_block }
output "aws_azs" { value = module.vpc.azs }
output "aws_public_subnets" { value = module.vpc.public_subnets }
output "aws_private_subnets" { value = module.vpc.private_subnets }
output "aws_cidr" { value = module.vpc.vpc_cidr_block }

## EKS
output "eks_cluster_id" { value = module.eks.cluster_id }
output "eks_load_balancer_controller_role_arn" { value = module.iam_assumable_role_alb.iam_role_arn }
output "eks_cluster_primary_security_group_id" { value = module.eks.cluster_primary_security_group_id }