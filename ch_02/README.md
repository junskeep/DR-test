### 전제조건

• 서비스 계정을 생성하고 관리할 수 있는 권한이 있는 AWS 계정

• EKS 클러스터(2개의 EKS 클러스터: Primary 및 Recovery)

• eksctl v0.123.0 이상

• AWS CLI 버전 2+

• kubectl, helm v3+

## 실습 환경 구성

### EKS 생성

사전에 구성된 Repository를 clone해서 terraform으로 eks 생성

20~30분 소요

# 생성 알림 나오면 y

```bash
git clone {repositoryURL}
cd ch_02/terraform-provision-eks
terraform init
terraform plan
terraform apply --auto-approve
```

### S3 and policy

1. **S3 install**

    ```bash
    # Bucket 이름과 리전을 환경변수로 선언
    export BUCKET=<YOUR_BUCKET_NAME>
    export REGION=<YOUR_AWS_REGION>
    
    # S3 Bucket 생성
    aws s3api create-bucket \
        --bucket $BUCKET \
        --region $REGION \
        --create-bucket-configuration LocationConstraint=$REGION
    
    # 정상 출력예시
    make_bucket: eks-velero-backups-eks-velero-backups
    ```

   버킷이 생성될 위치를 등록 선택하지 않으면 us-east-1에 자동 생성됨
   만약 us-east-1에 생성을 원하면 해당 옵션 제외하고 생성
   --create-bucket-configuration LocationConstraint=$REGION

   api 정보 https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3api/create-bucket.html

2. **velero policy**

   정책을 만드는 방법은 크게 두가지로 AWS에서 IAM 유저를 생성해서 권한을 부여하는 방식과

   **OpenID Connect(OIDC)를 사용해서 기존 IAM 계정을 사용하는 방법 - 여기서는 이방법으로 진행**

   추가로 velero 공식 문서에서 kube2iam을 통한 방법도 소개하고 있음.

   참고 : https://github.com/jtblin/kube2iam

   https://github.com/vmware-tanzu/velero-plugin-for-aws/tree/release-1.8

    ```bash
    cd ch_02/iam
    # 텍스트 편집기 또는 IDE를 사용해서 velero_test_policy.json 파일 편집
    
    ----
    
    # 진한 글씨로 되어있는 부분 사용자에 맞게 수정
    # BUCKET_NAME을 백업을 저장하려는 S3 버킷의 실제 이름으로 변경
    # ACCOUNT_ID를 계정 ID로 바꾸고 ROLE_NAME을 사용자 롤 네임으로 변경
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots",
            "ec2:CreateTags",
            "ec2:CreateVolume",
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot"
          ],
          "Resource": [
                    "arn:aws:ec2:**REGION**:**ACCOUNT_ID**:volume/*",
                    "arn:aws:ec2:**REGION**:**ACCOUNT_ID**:snapshot/*"
                ]
        },
        {
          "Effect": "Allow",
          "Action": [
    				"s3:GetObject",
            "s3:PutObject",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetBucketLocation",
            "s3:ListBucketVersions"
          ],
          "Resource": [
            "arn:aws:s3:::**BUCKET_NAME**/*",
            "arn:aws:s3:::**BUCKET_NAME**"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket"
          ],
          "Resource": [
            "arn:aws:s3:::**BUCKET_NAME**"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:PassRole"
          ],
          "Resource": [
            "arn:aws:iam::A**CCOUNT_ID**:role/**ROLE_NAME**"
          ]
        }
      ]
    }
    
    ----
    
    # iam policy 생성
    # 출력된 ARN을 꼭 기억할것 잊을 시 aws 콘솔에서 조회 또는 aws iam list-policies --region ap-northeast-1 | grep Velero으로 조회
    aws iam create-policy --policy-name <YOUR_POLICY_NAME> \
    --policy-document file://test_velero_policy.json
    
    ----
    
    #OIDC값 출력해서 복사
    OIDC_ID=$(aws eks describe-cluster --name $PRIMARY_CLUSTER --region $REGION --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
    aws iam list-open-id-connect-providers | grep $OIDC_ID | cut -d "/" -f4
    
    ----
    
    # 텍스트 편집기 또는 IDE를 사용해서 velero_test_trust_policy.json 파일 편집
    # 진한 글씨로 되어있는 부분 사용자에 맞게 수정
    # NAMESPACE와 SA_NAME는 velero가 설치될 Namespace와 생성될 ServiceAccount Name 
    # velero/velero로 설정 권장
    
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::**ACCOUNT_ID**:oidc-provider/oidc.eks.**REGION**.amazonaws.com/id/**OIDC_ID**"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "oidc.eks.**REGION**.amazonaws.com/id/**OIDC_ID**:aud": "sts.amazonaws.com",
              "oidc.**REGION**.amazonaws.com/id/**OIDC_ID**:sub": "system:serviceaccount:**NAMESPACE**:**SA_NAME**"
            }
          }
        }
      ]
    }
    ----
    
    # Role 생성
    aws iam create-role --role-name <ROLE_NAME> \
    --assume-role-policy-document file://velero_test_trust_policy.json
    
    # Role과 Policy attach 앞에서 생성한 POLICY_ARN
    aws iam attach-role-policy --role-name <ROLE_NAME> --policy-arn <POLICY_ARN>
    ```


1. S3 추가 권한 설명
    1. S3 권한 추가:
        - `s3:GetBucketLocation`: S3 버킷의 리전을 확인하기 위해 필요합니다.
        - `s3:ListBucketVersions`: 백업 중에 삭제된 객체를 포함하기 위해 필요할 수 있습니다.
    2. EC2 권한 추가 (EBS 볼륨 스냅샷 백업을 위한 경우):
        - `ec2:DescribeRegions`: 사용 가능한 모든 리전의 EBS 볼륨과 스냅샷을 나열하기 위해 필요할 수 있습니다.
        - `ec2:DescribeAvailabilityZones`: 사용 가능한 가용 영역을 나열하기 위해 필요할 수 있습니다.
    3. STS (Security Token Service) 권한:
        - `sts:AssumeRole`: 다른 AWS 서비스에 대한 엑세스를 위해 필요할 수 있습니다. 이 권한은 IAM 역할을 통해 다른 AWS 서비스의 역할을 맡을 때 필요합니다.

### Create Velero SA

파라미터 설명

• --cluster=$PRIMARY_CLUSTER는 서비스 계정이 연결될 EKS 클러스터의 이름을 지정.  $PRIMARY_CLUSTER는 기본 클러스터 이름으로 설정한 환경 변수
• --name는 생성될 서비스 계정의 이름을 지정
• --namespace는 서비스 계정이 생성될 네임스페이스를 지정
• --role-name은 서비스 계정과 연결될 IAM 역할의 이름을 지정
• --role-only는 IAM 역할을 생성하지만 이를 서비스 계정과 연결하지 않는 플래그
• --attach-policy-arn=arn:aws:iam::$ACCOUNT:policy/는 서비스 계정에 연결될 IAM 정책의 ARN을 지정 $ACCOUNT는 AWS ARN으로 설정한 환경 변수입니다.
• --approve는 서비스 계정 생성을 자동으로 승인합니다.

```bash
# 생성된 EKS CLUSTER 환경변수 설정
PRIMARY_CLUSTER=<PRIMARY_CLUSTER>
RECOVERY_CLUSTER=<RECOVERY_CLUSTER>
# Account ARN (선택사항)
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

# EKS 생성후 Primary cluster config 등록
aws eks --region $REGION update-kubeconfig --name <PRIMARY_CLUSTER>

# 클러스터에 OIDC 프로바이더 생성 - SA 생성하기 위해 필요
eksctl utils associate-iam-oidc-provider \
--cluster $PRIMARY_CLUSTER --region $REGION \
--approve

# recovery 클러스터도 동일하게 등록
aws eks --region ap-northeast-1 update-kubeconfig --name $RECOVERY_CLUSTER
eksctl utils associate-iam-oidc-provider \
--cluster $RECOVERY_CLUSTER --region $REGION
--approve

#생성
eksctl create iamserviceaccount --cluster=$PRIMARY_CLUSTER \
--region $REGION \
--name=<YOUR_SA_NAME> --namespace=<YOUR_SA_NAMESPACE> \
--role-name=<YOUR_ROLE_NAME>-primary \
--role-only --attach-policy-arn=arn:aws:iam::$ACCOUNT:policy/<YOUR_POLICY_NAME> \
--approve

eksctl create iamserviceaccount --cluster=$RECOVERY_CLUSTER \
--region $REGION \
--name=<YOUR_SA_NAME> --namespace=<YOUR_SA_NAMESPACE> \
--role-name=<YOUR_ROLE_NAME>-recovery \
--role-only --attach-policy-arn=arn:aws:iam::$ACCOUNT:policy/<YOUR_POLICY_NAME> \
--approve

# 조회
eksctl get iamserviceaccount --region $REGION --cluster=<YOUR_CLUSTER>
```


만약 알수없는 오류로 생성이 안되는 경우 policy나 role이 정확하게 생성되었는지 attach 되었는지

우선적으로 확인하고 이상이 없는 경우에는 CloudFormation의 Stack을 삭제하고 커멘드를 재입력 해보기.

### Install two cluster Velero

velero를 클러스터에 설치하는 방법은 2가지로

velero CLI를 이용해 설치하는 방법과

velero helm chart를 이용해 설치하는 방법 두가지이다.

간단한 테스트나 직관적인 수정을 원한다면 파라미터로 configuration을 할 수 있는 velero cli를 권장하고

helm chart의 value 파일에 많은 수정이 요구된다면 helm chart로 설치하는 것을 권장한다.

```bash
# 아래 명령을 통해 로컬에서 등록된 클러스터 중 명령을 실행할 클러스터로 변경 가능
kubectl config use-context arn:aws:eks:****$REGION::$ACCOUNT:****cluster/****$PRIMARY_CLUSTER****
kubectl config use-context arn:aws:eks:****$REGION::$ACCOUNT:****cluster/****$RECOVERY_CLUSTER****

# 출력 예시
Switched to context "arn:aws:eks:ap-northeast-2:0123456789:cluster/velero-recovery".

----

# install helm 
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
helm search repo vmware-tanzu

# 직접 value 파일 수정할 경우 로컬에 다운로드
helm pull vmware-tanzu/velero --untar

----

# or velero cli 아래의 커맨드를 Primary와 Recovery cluster에 각각 실행
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.8.0 \
    --bucket $BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --pod-annotations iam.amazonaws.com/role=arn:aws:iam::<AWS_ACCOUNT_ID>:role/<VELERO_ROLE_NAME> \
    --no-secret

# 성공적으로 연결됐는지 확인
velero backup-location get
```

참조 링크

https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/README.md - helm chart

https://github.com/vmware-tanzu/velero-plugin-for-aws/tree/release-1.8 - aws provider

### Velero Backup Test

설치가 잘되었다면 클러스터에서 앞에서 학습한 시나리오를 PrimaryCluster에서 테스트

```bash
# 백업 생성
velero backup create velero-backup

# 백업이 성공적으로 완료
Backup request "velero-backup" submitted successfully.
Run `velero backup describe velero-backup` or `velero backup logs velero-backup` for more details.

velero backup describe velero-backup
```


## Example pod를 생성하고 테스트

### Velero Basic Example

### ****Basic example (without PersistentVolumes)****

1. create example application pod

    ```bash
    mkdir example
    git clone https://github.com/vmware-tanzu/velero.git
    cd velero
    ```

1. Pod 검증과 백업

    ```bash
    # 해당 네임스페이스에 제대로 설치 되어 있는지 확인
    kubectl get all -n nginx-example
    # nginx-example ns만 백업
    velero backup create nginx-backup --include-namespaces nginx-example
    ```


2. 재해 시뮬레이션 및 복원 - without PV

    ```bash
    # ns 삭제
    kubectl delete namespaces nginx-example
    # 복구
    velero restore create --from-backup nginx-backup
    ```
--- 

### ****Snapshot example (with PersistentVolumes)****

```bash
kubectl apply -f examples/nginx-app/with-pv.yaml
k get all -n nginx-example
k get pv -n nginx-example
```


```bash
# create backup
velero backup create nginx-backup-pv --include-namespaces nginx-example --csi-snapshot-timeout=20m

#delete ns
kubectl delete namespaces nginx-example

# Restore resource
velero restore create --from-backup nginx-backup-pv
```

--csi-snapshot-timeout=20m는 스냅샷 생성전 대기시간
