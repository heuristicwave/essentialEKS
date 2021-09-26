provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
      command     = "aws"
    }
  }
}

# resource "helm_release" "aws-load-balancer-controller" {
#   # This config works like `helm repo add [repo-name] [url]` command
#   repository = "https://aws.github.io/eks-charts"
#   name       = "aws-load-balancer-controller"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   values = [
#     templatefile("./helm-values/aws-load-balancer-controller.yaml", {
#       AWS_REGION      = var.aws_region,
#       CLUSTER_NAME    = data.terraform_remote_state.eks.outputs.cluster_name,
#       SERVICE_ACCOUNT = data.terraform_remote_state.eks.outputs.service_account
#     })
#   ]
# }

resource "helm_release" "aws-node-termination-handler" {
  repository = "https://aws.github.io/eks-charts"
  name       = "eks"
  chart      = "aws-node-termination-handler"
  namespace  = "kube-system"
  values = [
    templatefile("./helm-values/node-termination-handler.yaml", {})
  ]
}

// Something problem with installing CA using helm-chart
# resource "helm_release" "cluster-autoscaler" {
#   # This config works like `helm repo add [repo-name] [url]` command
#   repository = "https://kubernetes.github.io/autoscaler"
#   name       = "autoscaler"

#   chart = "cluster-autoscaler"

#   values = [
#     templatefile("./helm-values/cluster-autoscaler.yaml", {
#       AWS_REGION      = var.aws_region,
#       CLUSTER_NAME    = data.terraform_remote_state.eks.outputs.cluster_name,
#       SERVICE_ACCOUNT = data.terraform_remote_state.eks.outputs.service_account
#     })
#   ]
# }

# resource "helm_release" "kubewatch" {
#   name       = "kubewatch"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "kubewatch"

#   values = [
#     file("${path.module}/kubewatch-values.yaml")
#   ]

#   set_sensitive {
#     name  = "slack.token"
#     value = var.slack_app_token
#   }
# }
