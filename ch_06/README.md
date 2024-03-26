```bash
cd ch_06

# 환경변수 지정
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export REGION={YOUR_REGION}
export BUCKET={YOUR_BUCKET}

## EKS Install
cd terraform-primary
# var 수정 terraform-primary 내에 variables.tf 파일에서 region과 s3 bucket name을 본인에 맞게 수정 후
terraform init
terraform validate
terraform plan
# 대기한 후 설치가 완료되면 velero 설치 15~20분 소요
terraform apply -auto-approve

# terraform apply가 완료되면 출력되는 output을 바탕으로 아래 코드 실행

aws eks --region ap-northeast-1 update-kubeconfig --name {ClusterName}
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.8.0 \
    --bucket $BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --pod-annotations iam.amazonaws.com/role=arn:aws:iam::$ACCOUNT:role/velero-access \
    --no-secret

# 잠시 대기한 후 velero pod가 running이 되는지 확인
k get all -n velero

# 아래 명령어를 통해 PHASE가 Available인지 확인
# 만약 오류가 있다면 velero backup-location get -o json으로 연결되지않는 이유를 확인하거나
# velero pod log를 확인
velero backup-location get

## ECR && Deploy Application
# aws ecr login
# 이미지를 푸쉬하려는 Amazon ECR 레지스트리에 대해 Docker 클라이언트 인증. 인증 토큰은 레지스트리마다 필요하며, 12시간동안 유효함.
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

----
## Window
# docker build
docker build --tag test-app .
# ECR push
# image 조회
docker images
# image의 tag를 ECR 주소와 이미지가 저장될 tag로 변경
docker tag {IMAGE_ID} ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/{YOUR_ECR_REPO}:{TAG}
# 변경한 태그를 이용해 push
docker push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/{YOUR_ECR_REPO}:{TAG}
----
## Mac
# mac m1 이상 사용자의 경우 buildx를 사용해야 eks의 운영체제에 맞는 이미지 빌드 가능
docker buildx version # 없다면 설치
docker buildx create --name ${BulderName} --use
docker buildx inspect ${BulderName} --bootstrap
docker buildx build --platform linux/amd64 -t {myrepo/myimage:mytag} . --push
# EX docker buildx build --platform linux/amd64 -t 000982191218.dkr.ecr.ap-northeast-1.amazonaws.com/test-ecr:testing-app-amd . --push
----

# push한 이미지 주소를 yaml로 옮긴다.
vim ./yaml/app.yaml
# spec.template.spec.containers.image 수정

# velero 정상 설치가 확인되면 test app 배포
# ecr 레지스트리에 있는 어플리케이션 배포
kubectl apply -n test-namespace -f app.yaml

# 생성된 svc EXTERNAL-IP로 웹사이트 정상 접속 확인 확인 후 Router 53 연결
# Router 53 Record 생성 -> LB 연결 후 정상 접속 확인

# velero backup 생성
velero backup create primary-backup

# 정상적으로 백업이 진행됐는지 확인
velero backup describe primary-cluster
```
