variable "aws_region" {
  default = "ap-northeast-2"
}

variable "cluster_name" {
  default = "terraform-eks-cluster"
  type    = string
}

variable "instance_type" {
  default = "t3.large"
  type    = string
}

locals {
  cluster_id       = aws_eks_cluster.eks_cluster.id
  cluster_endpoint = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca       = aws_eks_cluster.eks_cluster.certificate_authority.0.data
  service_account  = aws_iam_role.eks_assume_role.arn
}
