# EKS Getting Started Guide Configuration

Unmanaged NodeGroup : https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

### 구축방법

```shell
terraform init
terraform plan
terraform apply
```

<br>

### AWS Loadbalancer Controller 설치

[iam.tf](./iam.tf) 에 기재된 cluster autoscaler를 정의한 부분과 같이 IaC로 정의해도 되지만, 공식 문서에 기재된 [Installation Guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/#iam-permissions)의 방법 대로 설치해보자.

1. IAM OIDC provider 생성

2. IAM policy (AWS Load Balancer Controller) 생성

3. CLI로 IAM policy에 Custom Policy(AWSLoadBalancerControllerIAMPolicy, 2번) 부착

4. eksctl로 iamserviceaccount 생성 (IRSA, IAM Roles for Service Accounts)

5. - helm으로 설치하기

     1. Helm chart 추가
     2. TargetGroupBinding CRDs 설치
     3. Helm 명령어로 설치 (옵션 : 사용하는 IRSA 부여)

   - YAML manifests로 설치하기

     1. Cert-manager 설치

     2. kubernetes-sigs/aws-load-balancer-controller의 YAML 파일 다운

        1. Cluster-name 변경
        2. IRSA을 사용하므로, 기존 yaml에 기재된 ServiceAccount 삭제

     3. 배포후 검증

        ```shell
        kubectl get deployment -n kube-system aws-load-balancer-controller
        ```

        로그 확인

        ```shell
        ALBPOD=$(kubectl get pod -n kube-system | egrep -o "aws-load-balancer[a-zA-Z0-9-]+")
        kubectl describe pod -n kube-system ${ALBPOD}
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

---

### Reference

[kubernetes-sigs/aws-load-balancer-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/8db51cb82370fba5e25e470829520e1da219776f/docs/deploy)
