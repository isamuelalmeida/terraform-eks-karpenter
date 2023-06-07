resource "kubectl_manifest" "karpenter_provisioner_general" {
  depends_on = [helm_release.karpenter]

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
        - key: karpenter.k8s.aws/instance-cpu
          operator: In
          values: ["2", "4"]
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
  depends_on = [helm_release.karpenter]

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
  depends_on = [helm_release.karpenter]

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
  depends_on = [helm_release.karpenter]

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