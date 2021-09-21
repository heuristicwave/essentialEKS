# Provision your EKS with the Terraform Kubernetes & Helm provider

참고 Reference : [Deploy Applications with the Helm Provider](https://learn.hashicorp.com/tutorials/terraform/helm-provider)



## Provisioning  후, 수행 작업

Metrics server 설치 (`manifests` 폴더 아래에서 진행)

```shell
kubectl get deployment metrics-server -n kube-system
```



## Issue

### kubectl provider Issue

Manifest Yaml 파일 apply 시, list 형식으로 여러개의 yaml 을 한꺼번에 적용시키는 것이 불가 👉 helm 사용으로 대체 

```terraform
provider "kubectl" {
  load_config_file       = false
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
    command     = "aws"
  }
}

resource "kubectl_manifest" "test" {
  yaml_body = <<YAML
${file("./eks-manifests/metrics-server.yaml")}  
YAML
}
```

<br>



### helm provider Issue

Metrics server 설치 에러 👉 yaml 파일 설치로 대체

> *"Failed probe" probe="metric-storage-ready" err="not metrics to serve"*

```terraform
resource "helm_release" "metrics_server" {
  repository = "https://charts.bitnami.com/bitnami"
  name       = "metrics-server" # helm_release_name
  chart      = "metrics-server" # helm_chart_name
  namespace  = "kube-system"
}
```

