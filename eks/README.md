# kubeconfig

aws eks update-kubeconfig --region us-east-1 --name sam-eks-dev --profile samuel

## Desprovisionar Nós gerenciados pelo Karpenter
kubectl delete node -l karpenter.sh/provisioner-name=sam-eks-dev-gen