provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks_cluster/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
    command     = "aws"
  }
}

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }
