# Velero 정리

## Velero란?

"Velero(이전엔 Heptio Ark)"는 백업 및 복구 솔루션으로, 주로 쿠버네티스(Kubernetes) 환경에서 사용됩니다. 

이 소프트웨어는 쿠버네티스 클러스터의 리소스와 데이터를 백업하고, 필요할 때 복구할 수 있는 기능을 제공합니다.

 Velero는 쿠버네티스의 워크로드, Pod, Service, Volume 등 다양한 컴포넌트의 상태를 저장하고, 클러스터가 손상되거나 중요 데이터가 손실될 경우 이를 복구할 수 있게 해줍니다.

### Velero 주요 기능

1. **백업 및 복구**: 쿠버네티스 클러스터의 전체 또는 일부를 백업하고, 이를 다른 클러스터에 복원할 수 있습니다.
2. **재해 복구**: 클러스터의 재해 발생 시, 백업 데이터를 사용하여 시스템을 빠르게 복구할 수 있습니다.
3. **스케줄링**: 정기적인 백업을 위해 스케줄을 설정할 수 있으며, 이를 통해 데이터의 일관성과 안정성을 유지할 수 있습니다.
4. **클라우드 통합**: AWS, GCP, Azure 등 다양한 클라우드 스토리지 서비스와 통합하여 백업 데이터를 저장할 수 있습니다.
5. **커스터마이징**: 사용자의 요구에 맞게 백업 정책을 설정하고, 특정 리소스에 대한 백업 및 복구를 제어할 수 있습니다.

Velero는 쿠버네티스 기반의 애플리케이션과 서비스를 운영하는 조직에게 중요한 도구로, 클러스터 관리 및 운영의 복잡성을 줄이고, 데이터 손실 위험을 최소화하는 데 도움을 줍니다.

### Velero의 장점

- Velero는 Cloud Provider나 On-Prem과 함께 사용할 수 있다.
- 백업과 클러스터 복원으로 손실을 최소화
- 클러스터의 리소스를 다른 클러스터에 마이그레이션
- 프로덕션 클러스터를 개발과 테스트 클러스터로 리플리케이션

# Velero CLI 설치

사전 구성

- 접근 가능한 Kubernetes cluster v1.18+ (DNS와 컨테이너 네트워킹 enabled)
    - 버전에 관한 추가 정보는 https://github.com/vmware-tanzu/velero#velero-compatibility-matrix
- 로컬에 설치된 kubectl

Velero는 백업과 관련 아티팩트를 저장하는 객체 저장소를 사용한다.

또한 선택적으로 지원되는 block storage system과 통합하여 Persistent volume(영구 볼륨)의 스냅샷을 생성 할 수 있다.

설치를 시작하기 전에 호환 가능한 목록에서 Object Storage Provide(ex : S3)와 Block Storage Provider(ex : EBS snapshot)를 식별해야한다.

Velero는 스토리지 프로바이더로 클라우드 환경과 온프레미스 환경을 모두 지원한다.

자세한 온프레미스 시나리오는 [on-premises documentation](https://velero.io/docs/v1.12/on-premises/).

### Velero CLI 개요

1. Mac OS - Homebrew
    
    ```go
    brew install velero
    ```
    

1. Github release
    1. 최신버전의 tarball을 다운로드 [latest release](https://github.com/vmware-tanzu/velero/releases/latest)
    2. 압축 해제
        
        ```go
        tar -xvf <RELEASE-TARBALL-NAME>.tar.gz
        ```
        
    3. velero 바이너리를 $PATH에 맞게 이동한다. (대부분 /usr/local/bin)
2. Windows - Chocolatey
    
    ```go
    choco install velero
    ```
    

# Velero 서버 설치

Velero Server 컴포넌트를 쿠버네티스에 설치 및 구성

Velero 서버 컴포넌트 설치에는 두가지 방법이 지원된다.

- velero install CLI command
- [Helm chart](https://vmware-tanzu.github.io/helm-charts/) https://github.com/vmware-tanzu/helm-charts
    
    `helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts`
    

Velero는 Storage Provider 플러그인을 사용하여 다양한 스토리지 시스템과 통합하여 백업 및 스냅샷 작업을 지원

적절한 플러그인과 함께 Velero 서버 구성요소를 설치하고 구성하는 단계는 선택한 스토리지 제공업체에 따라 다릅니다. 

선택한 스토리지 공급업체에 대한 설치 지침을 찾으려면 지원되는 스토리지 프로바이더의 [페이지](https://velero.io/docs/v1.12/supported-providers/)에서 

해당 공급업체의 문서 링크를 참조

참고: 오브젝트 스토리지 공급업체가 볼륨 스냅샷 공급업체와 다른 경우, 먼저 오브젝트 스토리지 프로바이더의 설치 지침을 따른 다음 여기로 돌아와 지침에 따라 [볼륨 스냅샷](https://velero.io/docs/v1.12/customize-installation/#install-an-additional-volume-snapshot-provider) 프로바이더를 추가

추가로 다양한 Customize Velero 설치

https://velero.io/docs/v1.12/customize-installation/

모든 Namespace에 Velero 설치

non-file-based 설치

file system backup 등등

### Velero Provider

• [Provider plugins maintained by the Velero maintainers](https://velero.io/docs/v1.12/supported-providers/#provider-plugins-maintained-by-the-velero-maintainers) - Provider 목록
• [Provider plugins maintained by the Velero community](https://velero.io/docs/v1.12/supported-providers/#provider-plugins-maintained-by-the-velero-community) - Community Provider 목록
• [S3-Compatible object store providers](https://velero.io/docs/v1.12/supported-providers/#s3-compatible-object-store-providers) - S3 호환 Object Storage 목록
• https://velero.io/docs/v1.12/file-system-backup/ - 원하는 SnapShot Provider가 없는 경우 file-system-backup을 고려해야함 But, AWS 기반의 강의이기 때문에 자세히 다루지 않음

Velero는 백업과 스냅샷 운영에 다양한 Storage Provider를 지원한다.

Velero는 누구나 코드베이스를 수정하지 않고도 추가 백업 및 Volume Storage 플랫폼에 대한 호환성을 추가할 수 있는 플러그인 시스템을 갖추고 있습니다.

### Object Storage Provider 예시

### **Provider plugins maintained by the Velero maintainers**

| Provider | Object Store | Volume Snapshotter | Plugin Provider Repo | Setup Instructions | Parameters |
| --- | --- | --- | --- | --- | --- |
| https://aws.amazon.com/ | AWS S3 | AWS EBS | https://github.com/vmware-tanzu/velero-plugin-for-aws | https://github.com/vmware-tanzu/velero-plugin-for-aws#setup | https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/backupstoragelocation.md https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/volumesnapshotlocation.md |
| https://cloud.google.com/ | https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/backupstoragelocation.md | https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/volumesnapshotlocation.md | https://github.com/vmware-tanzu/velero-plugin-for-gcp | https://github.com/vmware-tanzu/velero-plugin-for-gcp#setup | https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/backupstoragelocation.md https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/volumesnapshotlocation.md |
| https://azure.com/ | Azure Blob Storage | Azure Managed Disks | https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure | https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup | https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/main/backupstoragelocation.md https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/main/volumesnapshotlocation.md |
| https://www.vmware.com/ca/products/vsphere.html | 🚫 | vSphere Volumes | https://github.com/vmware-tanzu/velero-plugin-for-vsphere | https://github.com/vmware-tanzu/velero-plugin-for-vsphere#velero-plugin-for-vsphere-installation-and-configuration-details | 🚫 |
| https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/ | 🚫 | CSI Volumes | https://github.com/vmware-tanzu/velero-plugin-for-csi/ | https://github.com/vmware-tanzu/velero-plugin-for-csi#kinds-of-plugins-included | 🚫 |

### **Provider plugins maintained by the Velero community**

| Provider | Object Store | Volume Snapshotter | Plugin Documentation | Contact |
| --- | --- | --- | --- | --- |
| https://www.alibabacloud.com/ | Alibaba Cloud OSS | Alibaba Cloud | https://github.com/AliyunContainerService/velero-plugin | https://github.com/AliyunContainerService/velero-plugin/issues |
| https://www.digitalocean.com/ | DigitalOcean Object Storage | DigitalOcean Volumes Block Storage | https://github.com/StackPointCloud/ark-plugin-digitalocean |  |
| https://www.hpe.com/us/en/storage.html | 🚫 | HPE Storage | https://github.com/hpe-storage/velero-plugin | https://slack.hpedev.io/, https://github.com/hpe-storage/velero-plugin/issues |
| https://openebs.io/ | 🚫 | OpenEBS CStor Volume | https://github.com/openebs/velero-plugin | https://openebs-community.slack.com/, https://github.com/openebs/velero-plugin/issues |
| https://www.openstack.org/ | Swift | Cinder | https://github.com/Lirt/velero-plugin-for-openstack | https://github.com/Lirt/velero-plugin-for-openstack/issues |
| https://portworx.com/ | 🚫 | Portworx Volume | https://docs.portworx.com/scheduler/kubernetes/ark.html | https://portworx.slack.com/messages/px-k8s, https://github.com/portworx/ark-plugin/issues |
| https://storj.io/ | Storj Object Storage | 🚫 | https://github.com/storj-thirdparty/velero-plugin | https://github.com/storj-thirdparty/velero-plugin/issues |

### S3 호환 object store 프로바이더

Velero의 AWS Object Store 플러그인은 [Amazon’s Go SDK](https://github.com/aws/aws-sdk-go/aws)를 사용해 AWS S3 API와 연결 할 수 있다.

서드파티 스토리지 프로바이더는 S3 API를 지원하고 다음 프로바이더들은 Velero를 지원한다.

아래의 스토리지 프로바이더는 Velero 팀에서 직접 테스트 관리하지 않음

- [IBM Cloud](https://velero.io/docs/v1.12/contributions/ibm-config/)
- [Oracle Cloud](https://velero.io/docs/v1.12/contributions/oracle-config/)
- [Minio](https://velero.io/docs/v1.12/contributions/minio/)
- [DigitalOcean](https://github.com/StackPointCloud/ark-plugin-digitalocean)
- [NooBaa](http://www.noobaa.com/)
- [Tencent Cloud](https://velero.io/docs/v1.12/contributions/tencent-config/)
- Ceph RADOS v12.2.7
- Quobyte
- [Cloudian HyperStore](https://www.cloudian.com/)

### **Non-supported volume snapshots**

이 경우는 볼륨 스냅샷을 갖길 원하지만 프로바이더에 맞는 플러그인을 찾을 수 없을 때,

velero는 File System Backup을 사용하는 스냅샷을 지원한다. [File System Backup](https://velero.io/docs/v1.12/file-system-backup/)

# Velero CLI 주요 명령어 사용 시나리오

Velero 서버를 구축하고 나서 다음을 실행하여 다음 섹션에서 사용된 예제를 클론

(예시 Application이 있는 Repo Clone)

```go
git clone https://github.com/vmware-tanzu/velero.git
cd velero
```

### **Basic example (without PersistentVolumes)**

1. nginx 어플리케이션 배포
    
    ```bash
    kubectl apply -f examples/nginx-app/base.yml
    ```
    
2. 백업 생성
    
    ```bash
    velero backup create <생성 백업 명> --include-namespaces <백업 생성할 특정 Namespace>
    velero backup create nginx-backup --include-namespaces nginx-example
    ```
    
3. 장애 시뮬레이션 - 복원을 진행하기 위해 기존 Namespace 삭제
    
    ```bash
    kubectl delete namespaces nginx-example
    ```
    
4. 손실 리소스 복원 
    
    ```bash
    velero restore create --frem-backup <복원 진행할 백업 명>
    velero restore create --from-backup nginx-backup
    ```
    
5. Restore 명령어 사용 후 조회하면 삭제 했던 Namespace가 백업을 생성한 시점으로 복원

### Snapshot example (with PersistentVolumes)

참고 : Azure의 경우 kuberntes 버전이 1.7.2 이상만 PV 스냅샷이 지원된다.

1. nginx 어플리케이션 실행
    
    ```bash
    kubectl apply -f examples/nginx-app/with-pv.yaml
    ```
    
2. PV 스냅샷과 함께 백업 생성 —csi-snapshot-timeout은 CSI 스냅샷 생성 타임아웃의 셋업 타임을 사용 디폴트 값은 10분
    
    아래의 명령어를 통해 Pv가 있는 리소스를 백업시 AWS 기준 EBS Snapshot이 생성됨
    
    ```bash
    velero backup create nginx-backup --include-namespaces nginx-example --csi-snapshot-timeout=20m
    ```
    
3. 장애 시뮬레이션
    
    ```bash
    kubectl delete namespaces nginx-example
    ```
    
4. 손실 리소스 복원
    
    ```bash
    velero restore create --from-backup nginx-backup
    ```
    
5. Restore 명령어 사용 후 조회 시 삭제했던 리소스들과 EBS(EBS로 설정 시)가 복원

### Velero를 Cluster에서 삭제

```bash
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero

--- 또는
velero uninstall 명령어도 사용 가능
```

# Velero 재해복구 시나리오

## Disaster recovery

스케쥴과 읽기 전용 백업 스토리지 로케이션 사용

만약 주기적으로 클러스터 리소스에 대한 백업이 필요하면 서비스 중단과 같은 예기치 않은 사고 발생 시

이전 상태로 돌아갈 수 있다.

Velero로 백업하는 방법은 다음과 같다.

1. cluster에 velero 서버를 실행 시킨 뒤에 데일리 백업을 세팅한다. (<SCHEDULE NAME>을 원하는대로 수정)
    
    아래 첫 명령을 실행하면<SCHEDULE NAME>-<TIMESTAMP>라는 이름의 백업 개체가 생성됨
    
    TTL(time to live)로 표시되는 기본 백업 보존 기간은 30일(720시간)이며, 
    
    필요에 따라 —ttl<DURATION> 플래그를 사용하여 변경 가능
    
    백업 만료에 대한 자세한 내용은 [how velero works](https://velero.io/docs/v1.12/how-velero-works/#set-a-backup-to-expire)
    
    ```bash
    Velero 스케쥴 설정의 다양한 방법
    # general 
    velero schedule create <SCHEDULE NAME> --schedule "0 7 * * *"
    # create schedule로 생성
    velero create schedule <SCHEDULE NAME> --schedule="0 */6 * * *"
    # 꼭 Cron 표현식을 사용하지 않아도 무방
    velero create schedule <SCHEDULE NAME> --schedule="@every 6h"
    # 특정 네임스페이스만 백업할 경우
    velero create schedule <SCHEDULE NAME> --schedule="@every 24h" --include-namespaces web
    # ttl 시간 설정
    velero create schedule <SCHEDULE NAME> --schedule="@every 168h" --ttl 2160h0m0s
    ```
    
    이외에도 schedule 명령어에 다양한 파라미터 존재
    
2. 재해 발생 시 리소스의 재생성이 필요
3. 백업 스토리지 로케이션을 읽기전용 모드로 업데이트 
    
    (이렇게 하면 복원 중 백업 스토리지 로케이션에서 백업 개체가 생성되거나 삭제 되는 것을 방지)
    
    (아래에선 kubectl patch 명령어를 사용했으나 velero cli를 통해서도 가능 아래의 사항은 실습때 자세히)
    
    ```bash
    kubectl patch backupstoragelocation <STORAGE LOCATION NAME> \
        --namespace velero \
        --type merge \
        --patch '{"spec":{"accessMode":"ReadOnly"}}'
    ```
    
4. 최신에 백업으로 복원 만들기
    
    ```bash
    velero restore create --from-backup <SCHEDULE NAME>-<TIMESTAMP>
    ```
    
5. 준비되면 백업 스토리지 로케이션을 읽기 쓰기 모드로 되돌린다.
    
    ```bash
    kubectl patch backupstoragelocation <STORAGE LOCATION NAME> \
       --namespace velero \
       --type merge \
       --patch '{"spec":{"accessMode":"ReadWrite"}}'
    ```
    

# Cluster 마이그레이션

Velero의 백업과 복원 기능은 클러스터 간 데이터를 마이그레이션하는데 유용한 도구이다.

Velero를 사용한 클러스터 마이그레이션은 지정된 오브젝트 스토리지에서 클러스터로 Velero 리소스를 동기화하는 역할을 하는 Velero의 오브젝트 스토리지 동기화 기능을 기반으로 한다.

즉, Velero를 사용하여 클러스터 마이그레이션을 수행하면 관련된 클러스터에서 실행 중인 각 Velero 인스턴스를 동일한 클라우드 오브젝트 스토리지 로케이션으로 가리켜야 한다.

## Cluster를 마이그레이션 하기 전에

마이그레이션하기 전에 다음 사항을 고려해야 합니다 :

- Velero는 기본적으로 클라우드 프로바이더 간에 영구 볼륨 스냅샷 마이그레이션을 지원하지 않는다.
    
    클라우드 플랫폼 간에 볼륨 데이터를 마이그레이션 하려면 파일 시스템 수준에서 볼륨 콘텐츠를 백업하는 [파일 시스템 백업](https://velero.io/docs/v1.12/file-system-backup/)을 활성화 해야한다. 
    
- Velero는 백업을 수행한 곳 보다 더 낮은 Kubernetes 버전의 클러스터는 복원이 지원되지 않음
- 동일한 버전의 Kubernetes를 실행하지 않는 클러스터 간에 워크로드를 마이그레이션할 수 있지만,
    
    마이그레이션하기 전에 각 custom resource에 대한 클러스터 간 API 그룹의 호환성을 비롯한 몇 가지 요소를 고려해야 한다.
    
    API 그룹의 호환성이 깨지는 경우, 영향을 받는 사용자 정의 리소스를 업데이트하지 않고는 Velero로 마이그레이션할 수 없다. API 그룹 버전에 대한 자세한 내용은 [EnableAPIGroupVersions](https://velero.io/docs/v1.12/enable-api-group-versions-feature/).
    
- AWS 및 Azur용 velero 플러그인은 리전 간 데이터 마이그레이션을 지원하지 않는다. 이 작업을 수행하는 경우에는 파일 시스템 백업을 사용해야한다.

## 마이그레이션 시나리오

이 시나리오에서는 cluster 1에서 cluster 2로 리소스를 마이그레이션하는 과정을 단계별로 설명한다.

두 클러스터 모두 동일한 클라우드 공급자인 AWS와 Velero의 AWS 플러그인을 사용합니다.

1. Cluster 1에서 Velero CLI가 설치되어 있고 
    
    —bucket 플래그를 사용하여 Object Storage Location을 확인한다.
    
    아래는 단순 예시
    
    ```bash
    velero install --provider aws \ # provider 선택
    --image velero/velero:v1.8.0 \ # velero version
    --plugins velero/velero-plugin-for-aws:v1.4.0 \ # plugin version
    --bucket velero-migration-demo \ # bucket name ex)aws=s3
    --secret-file xxxx/aws-credentials-cluster1 \ # secret AWS Access Key로 인증 시
    --backup-location-config region=us-east-2 \ # backup이 저장될 bucket의 리전
    --snapshot-location-config region=us-east-2 # Snapshot이 저장될 리전
    ```
    
    설치하는 동안 Velero는 설치 명령에서 제공한 —bucket(이 경우 velero-migration-demo) 내에 default라는 백업 스토리지 로케이션을 만든다. 
    
    이 로케이션은 Velero가 백업을 저장하는데 사용할 로케이션이다. 
    
    `velero backup-location get` 을 실행하면 cluster 1의 백업 로케이션이 표시된다. 
    
    * 입력안했을시 us-west-1 default
    
    ```bash
    velero backup-location get 
    NAME      PROVIDER   BUCKET/PREFIX           PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
    default   aws        velero-migration-demo   Available   2023-10-13 13:41:30 +0800 CST   ReadWrite     true
    ```
    
2. 여전히 cluster 1에 있는 경우 클러스터의 백업이 있는지 확인한다.
    
    ```bash
    velero backup create <BACKUP-NAME>
    ```
    
    또는 Velero 예약 작업을 통해 데이터의 예약 백업을 만들 수 있다.  (앞에서 설명한 부분)
    
    이 방법은 정의한 일정에 따라 데이터가 자동으로 백업되도록 하는 방법이다. 
    
3. Cluster 2에서 Velero가 설치되어 있는지 확인한다. 
    
    아래의 설치 명령은 Cluster 1의 설치 명령과 리전 및 —bucket 로케이션이 동일해야 한다. 
    
    *AWS용 Velero 플러그인은 리전간 데이터 마이그레이션을 지원하지 않는다.
    
    Cluster 2에도 동일하게 설치
    
    ```bash
    velero install --provider aws \
    --image velero/velero:v1.8.0 \
    --plugins velero/velero-plugin-for-aws:v1.4.0 \
    --bucket velero-migration-demo \
    --secret-file xxxx/aws-credentials-cluster**2** \
    --backup-location-config region=us-east-2 \
    --snapshot-location-config region=us-east-2
    ```
    
    또는 cluster 2에 Velero를 설치한 후 cluster 1에서 사용하는 —bucket 로케이션 및 리전을 가리키도록 BackupStorageLocations 및 VolumeSnapshotLocations를 구성할 수 있다.
    
    이 작업을 수행하려면 `velero backup-location create` 와 
    
    `velero snapshot-location create` 커멘드를 사용할 수 있다.
    
    install로 생성된 default location 외에 추가 구성 가능
    
    ```bash
    velero backup-location create <NAME> \
    --provider aws --bucket velero-migration-demo \
    --config region=us-east-2 --access-mode=ReadOnly
    ```
    
    velero backup-location create에 -access-mode=ReadOnly 플래그를 사용하여 BackupStorageLocations를 읽기 전용으로 구성하는 것이 좋다.
    
    이렇게 하면 복원 중 실수로 개체 저장소에서 백업이 삭제되지 않게 한다.
    
    플래그에 대한 자세한 설명은 velero backup-location –help을 참조
    
    Snapshot location도 동일하게 추가 구성 가능
    
    ```bash
    velero snapshot-location create <NAME> \
    --provider aws --config region=us-east-2
    ```
    
    velero snapshot-location –help를 보면 이 커멘드에 사용가능한 플래그들의 정보를 확인할 수 있다.
    
4. Cluster 2에서 지속적으로 Cluster 1에서 생성된 Velero 백업 오브적트를 사용할 수 있는지 확인한다. 

    
    ```bash
    velero backup describe <BACKUP-NAME>
    ```
    
    Velero 리소스는 오브젝트 스토리지의 백업 파일과 동기화 된다. 
    
    cluster 1의 백업으로 생성된 Velero 리소스는 공유된 백업 스토리지 로케이션을 통해 Cluster 2에 동기화 
    
    동기화과 완료되면 cluster 2에서 Velero 명령을 사용하여 cluster 1의 백업에 액세스 가능 
    기본 동기화 간격은 1분이며 백업 가용성을 확인하기 전에 대기해야 할 수도 있다. 
    
    cluster 2의 Velero 서버에 —backup-sync-period 플래그를 사용하여 동기화 간격을 조정할 수 있다.
    
5. Cluster 2에서 올바른 백업을 사용할 수 있다면, 모든것을 cluster 2로 복원 할 수 있다.
    
    ```bash
    velero restore create --from-backup <BACKUP-NAME>
    ```
    
    <BACKUP-NAME>이 Cluster 1의 백업 이름과 동일 해야한다.
    

## 클러스터 검증

Cluster 2가 예상대로 잘 작동하는지 확인한다.

1. Cluster 2에서 실행
    
    ```bash
    velero restore get
    ```
    
2. 그런다음 실행
    
    ```bash
    velero restore describe <RESTORE-NAME-FROM-GET-COMMAND>
    ```
    
    이제 cluster 1에서 백업한 데이터를 cluster 2에서 사용할 수 있어야 함.
    
    Velero가 두 클러스터에서 동일한 Namespace에 위치한 것이 아니라면 문제가 발생할 수 있음.
    

# Velero AWS 크로스리전

추후 챕터에서 다룰 내용

AWS(Amazon Web Services) 환경에서 **`Velero`**를 사용할 때 크로스 리전(Cross-Region) 클러스터에 대한 지원 여부는 **`Velero`**의 구성과 AWS 서비스의 특성에 따라 달라질 수 있습니다.

일반적으로, **`Velero`**는 클러스터의 리소스와 퍼시스턴트 볼륨(Persistent Volumes)의 스냅샷을 백업할 수 있으며, 이러한 백업을 다른 리전으로 복사하거나 이동시키는 것은 **AWS의 S3 버킷과 같은 스토리지 서비스의 기능에 의존**

AWS S3는 크로스 리전 복제를 지원하기 때문에, 이론적으로는 **`Velero`**를 사용하여 한 리전에서 백업을 수행하고 다른 리전의 클러스터에서 이를 복구하는 것이 가능합니다.

하지만, 크로스 리전 복구는 다음과 같은 몇 가지 중요한 고려 사항을 포함합니다:

1. **리전 간 네트워크 지연**: 다른 리전 간의 데이터 전송에는 추가적인 네트워크 지연이 발생할 수 있습니다.
2. **데이터 전송 비용**: AWS는 리전 간 데이터 전송에 대해 비용을 부과할 수 있습니다.
3. **호환성 및 종속성**: 백업된 데이터가 다른 리전의 클러스터에서 호환되는지 확인해야 합니다. 예를 들어, 특정 클라우드 서비스의 리소스 식별자나 구성이 리전에 따라 다를 수 있습니다.

따라서, **`Velero`**를 사용하여 AWS에서 크로스 리전 클러스터를 백업하고 복구하는 것은 기술적으로 가능하지만, 상황에 따라 추가적인 구성 및 고려 사항이 필요

이러한 작업을 수행하기 전에 철저한 계획과 테스트가 중요함
