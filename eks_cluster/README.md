# EKS Getting Started Guide Configuration

Unmanaged NodeGroup : https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

### 구축방법

```shell
terraform init
terraform plan
terraform apply
```

**aws loadbalancer controller 를 위한 정책 만들기**

아래 명령어는 [iam.tf](./iam.tf) 에 기재된 cluster autoscaler를 정의한 부분과 같이 IaC로 정의해도 되지만, 다음과 같은 명령어로도 생성이 가능하다.

```shell
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

AWSLoadBalancerControllerIAMPolicy 정책 생성

```shell
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

생성한 정책 assume role에 부여하기 (여기서는 eks_assume_role 이라 명명)

```shell
aws iam attach-role-policy \
--policy-arn arn:aws:iam::{AccountNumber}:policy/AWSLoadBalancerControllerIAMPolicy \
--role-name {eks_assume_role}
```

<br>

### kubectl 설정 하기

아래 2가지 방법 중 하나로 가능, 2번 추천

1. `terraform output`으로 `.kube`의 `config` 수정

```shell
mkdir ~/.kube/
terraform output kubeconfig > ~/.kube/config
```

2. awscli로 `.kube`의 `config` 수정 (리전 생략 가능)

Terraform Output 이용 `aws eks --region <region-code> update-kubeconfig --name <cluster_name>`

```shell
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

> `-raw` string => raw

`kubectl version`으로 확인 하기

<br>

### Trouble Shooting

- [kubectl server 인증 문제](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
