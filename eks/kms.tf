resource "aws_kms_key" "eks" {
  description = module.env_info.envs[terraform.workspace].eks.cluster_name
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${module.env_info.envs[terraform.workspace].eks.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}