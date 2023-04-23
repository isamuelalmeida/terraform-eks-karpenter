module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "18.31.0"

  cluster_name = module.eks.cluster_name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = false
  iam_role_arn    = module.eks_managed_node_group_initial.iam_role_arn
}


data "aws_ecrpublic_authorization_token" "token" {}

resource "helm_release" "karpenter" {
  depends_on = [
    module.eks,
    module.eks_managed_node_group_initial
  ]

  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.20.0"

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "tolerations[0].key"
    value = "karpenter"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "tolerations[0].value"
    value = "allowed"
  }
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }  
}


resource "kubectl_manifest" "karpenter_provisioner_general" {
  depends_on = [ helm_release.karpenter ]
  
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: ${module.eks.cluster_name}-gen
    spec:
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
      limits:
        resources:
          cpu: 100
      providerRef:
        name: ${module.eks.cluster_name}-gen
      ttlSecondsAfterEmpty: 10
      labels:
        nodeTypeClass: General
  YAML
}

# Nodegroup general
resource "kubectl_manifest" "karpenter_node_template_general" {
  depends_on = [ helm_release.karpenter ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: ${module.eks.cluster_name}-gen
    spec:
      subnetSelector:
        karpenter.sh/discovery: "true"
      securityGroupSelector:
        karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
        managed-by: "Terraform"
  YAML    
}


# Nodegroup observability
resource "kubectl_manifest" "karpenter_provisioner_observability" {
  depends_on = [ helm_release.karpenter ]
  
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: ${module.eks.cluster_name}-obs
    spec:
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["t4g"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
      limits:
        resources:
          cpu: 100
      providerRef:
        name: ${module.eks.cluster_name}-obs
      ttlSecondsAfterEmpty: 10
      labels:
        nodeTypeClass: observability
  YAML
}

resource "kubectl_manifest" "karpenter_node_template_observability" {
  depends_on = [ helm_release.karpenter ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: ${module.eks.cluster_name}-obs
    spec:
      subnetSelector:
        karpenter.sh/discovery: "true"
      securityGroupSelector:
        karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
        managed-by: "Terraform"
  YAML    
}