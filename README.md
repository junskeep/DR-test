Velero란?
"Velero(이전엔 Heptio Ark)"는 백업 및 복구 솔루션으로, 주로 쿠버네티스(Kubernetes) 환경에서 사용됩니다.

이 소프트웨어는 쿠버네티스 클러스터의 리소스와 데이터를 백업하고, 필요할 때 복구할 수 있는 기능을 제공합니다.

Velero는 쿠버네티스의 워크로드, Pod, Service, Volume 등 다양한 컴포넌트의 상태를 저장하고, 클러스터가 손상되거나 중요 데이터가 손실될 경우 이를 복구할 수 있게 해줍니다.

Velero 주요 기능
백업 및 복구: 쿠버네티스 클러스터의 전체 또는 일부를 백업하고, 이를 다른 클러스터에 복원할 수 있습니다.

재해 복구: 클러스터의 재해 발생 시, 백업 데이터를 사용하여 시스템을 빠르게 복구할 수 있습니다.

스케줄링: 정기적인 백업을 위해 스케줄을 설정할 수 있으며, 이를 통해 데이터의 일관성과 안정성을 유지할 수 있습니다.

클라우드 통합: AWS, GCP, Azure 등 다양한 클라우드 스토리지 서비스와 통합하여 백업 데이터를 저장할 수 있습니다.

커스터마이징: 사용자의 요구에 맞게 백업 정책을 설정하고, 특정 리소스에 대한 백업 및 복구를 제어할 수 있습니다.

Velero는 쿠버네티스 기반의 애플리케이션과 서비스를 운영하는 조직에게 중요한 도구로, 클러스터 관리 및 운영의 복잡성을 줄이고, 데이터 손실 위험을 최소화하는 데 도움을 줍니다.

Velero의 장점
Velero는 Cloud Provider나 On-Prem과 함께 사용할 수 있다.

백업과 클러스터 복원으로 손실을 최소화

클러스터의 리소스를 다른 클러스터에 마이그레이션

프로덕션 클러스터를 개발과 테스트 클러스터로 리플리케이션


Velero CLI 설치
사전 구성

접근 가능한 Kubernetes cluster v1.18+ (DNS와 컨테이너 네트워킹 enabled)

버전에 관한 추가 정보는 GitHub - vmware-tanzu/velero: Backup and migrate Kubernetes applications and their persistent volumes 

로컬에 설치된 kubectl

Velero는 백업과 관련 아티팩트를 저장하는 객체 저장소를 사용한다.

또한 선택적으로 지원되는 block storage system과 통합하여 Persistent volume(영구 볼륨)의 스냅샷을 생성 할 수 있다.

설치를 시작하기 전에 호환 가능한 목록에서 Object Storage Provide(ex : S3)와 Block Storage Provider(ex : EBS snapshot)를 식별해야한다.

Velero는 스토리지 프로바이더로 클라우드 환경과 온프레미스 환경을 모두 지원한다.

자세한 온프레미스 시나리오는 on-premises documentation.

Velero 서버 설치
Velero Server 컴포넌트를 쿠버네티스에 설치 및 구성

Velero 서버 컴포넌트 설치에는 두가지 방법이 지원된다.

velero install CLI command

Helm chart GitHub - vmware-tanzu/helm-charts: Contains Helm charts for Kubernetes related open source tools 

helm repo add vmware-tanzu <https://vmware-tanzu.github.io/helm-charts>

Velero는 Storage Provider 플러그인을 사용하여 다양한 스토리지 시스템과 통합하여 백업 및 스냅샷 작업을 지원

적절한 플러그인과 함께 Velero 서버 구성요소를 설치하고 구성하는 단계는 선택한 스토리지 제공업체에 따라 다릅니다.

선택한 스토리지 공급업체에 대한 설치 지침을 찾으려면 지원되는 스토리지 프로바이더의 페이지에서

해당 공급업체의 문서 링크를 참조

참고: 오브젝트 스토리지 공급업체가 볼륨 스냅샷 공급업체와 다른 경우, 먼저 오브젝트 스토리지 프로바이더의 설치 지침을 따른 다음 여기로 돌아와 지침에 따라 볼륨 스냅샷 프로바이더를 추가

추가로 다양한 Customize Velero 설치

Velero Docs - Customize Velero Install 

모든 Namespace에 Velero 설치

non-file-based 설치

file system backup 등등

Velero Provider
 

Provider plugins maintained by the Velero maintainers - Provider 목록 • Provider plugins maintained by the Velero community - Community Provider 목록 • S3-Compatible object store providers - S3 호환 Object Storage 목록 • Velero Docs - File System Backup  - 원하는 SnapShot Provider가 없는 경우 file-system-backup을 고려해야함 But, AWS 기반의 강의이기 때문에 자세히 다루지 않음

Velero는 백업과 스냅샷 운영에 다양한 Storage Provider를 지원한다.

Velero는 누구나 코드베이스를 수정하지 않고도 추가 백업 및 Volume Storage 플랫폼에 대한 호환성을 추가할 수 있는 플러그인 시스템을 갖추고 있습니다.

Object Storage Provider 예시
Provider plugins maintained by the Velero maintainers
Provider

Object Store

Volume Snapshotter

Plugin Provider Repo

Setup Instructions

Parameters

Cloud Computing Services - Amazon Web Services (AWS) 

AWS S3

AWS EBS

GitHub - vmware-tanzu/velero-plugin-for-aws: Plugins to support Velero on AWS 

GitHub - vmware-tanzu/velero-plugin-for-aws: Plugins to support Velero on AWS 

https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/backupstoragelocation.mdGithub 계정 연결  https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/volumesnapshotlocation.mdGithub 계정 연결 

Cloud Computing Services | Google Cloud 

https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/backupstoragelocation.mdGithub 계정 연결 

https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/volumesnapshotlocation.mdGithub 계정 연결 

GitHub - vmware-tanzu/velero-plugin-for-gcp: Plugins to support Velero on Google Cloud Platform (GCP) 

GitHub - vmware-tanzu/velero-plugin-for-gcp: Plugins to support Velero on Google Cloud Platform (GCP) 

https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/backupstoragelocation.mdGithub 계정 연결  https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/volumesnapshotlocation.mdGithub 계정 연결 

Cloud Computing Services | Microsoft Azure 

Azure Blob Storage

Azure Managed Disks

GitHub - vmware-tanzu/velero-plugin-for-microsoft-azure: Plugins to support Velero on Microsoft Azure 

GitHub - vmware-tanzu/velero-plugin-for-microsoft-azure: Plugins to support Velero on Microsoft Azure 

https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/main/backupstoragelocation.mdGithub 계정 연결  https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/main/volumesnapshotlocation.mdGithub 계정 연결 

VMware vSphere | Virtualization Platform 

🚫

vSphere Volumes

GitHub - vmware-tanzu/velero-plugin-for-vsphere: Plugin to support Velero on vSphere 

GitHub - vmware-tanzu/velero-plugin-for-vsphere: Plugin to support Velero on vSphere 

🚫

Container Storage Interface (CSI) for Kubernetes GA 

🚫

CSI Volumes

GitHub - vmware-tanzu/velero-plugin-for-csi: Velero plugins for integrating with CSI snapshot API 

GitHub - vmware-tanzu/velero-plugin-for-csi: Velero plugins for integrating with CSI snapshot API 

🚫

Provider plugins maintained by the Velero community
Provider

Object Store

Volume Snapshotter

Plugin Documentation

Contact

Provider

Object Store

Volume Snapshotter

Plugin Documentation

Contact

Empower Your Business in USA & Canada with Alibaba Cloud's Cloud Products & Services 

Alibaba Cloud OSS

Alibaba Cloud

GitHub - AliyunContainerService/velero-plugin 

https://github.com/AliyunContainerService/velero-plugin/issuesGithub 계정 연결 

DigitalOcean | Cloud Infrastructure for Developers 

DigitalOcean Object Storage

DigitalOcean Volumes Block Storage

https://github.com/StackPointCloud/ark-plugin-digitaloceanGithub 계정 연결 

 

Storage Products 

🚫

HPE Storage

GitHub - hpe-storage/velero-plugin: HPE plugin for Velero 

Slack-signup , https://github.com/hpe-storage/velero-plugin/issuesGithub 계정 연결 

OpenEBS - Kubernetes storage simplified. 

🚫

OpenEBS CStor Volume

GitHub - openebs/velero-plugin: Velero plugin for backup/restore of OpenEBS cStor volumes 

https://openebs-community.slack.com/, https://github.com/openebs/velero-plugin/issuesGithub 계정 연결 

Open Source Cloud Computing Infrastructure - OpenStack 

Swift

Cinder

GitHub - Lirt/velero-plugin-for-openstack: Openstack Cinder, Manila and Swift plugin for Velero backups 

https://github.com/Lirt/velero-plugin-for-openstack/issuesGithub 계정 연결 

Portworx - Kubernetes Storage and data services for containers 

🚫

Portworx Volume

https://docs.portworx.com/scheduler/kubernetes/ark.html

https://portworx.slack.com/messages/px-k8s, https://github.com/portworx/ark-plugin/issuesGithub 계정 연결 

Globally Distributed Cloud Object Storage 

Storj Object Storage

🚫

GitHub - storj-thirdparty/velero-plugin: Velero object store plugin that is backed by Storj 

https://github.com/storj-thirdparty/velero-plugin/issuesGithub 계정 연결 

S3 호환 object store 프로바이더
Velero의 AWS Object Store 플러그인은 Amazon’s Go SDK를 사용해 AWS S3 API와 연결 할 수 있다.

서드파티 스토리지 프로바이더는 S3 API를 지원하고 다음 프로바이더들은 Velero를 지원한다.

아래의 스토리지 프로바이더는 Velero 팀에서 직접 테스트 관리하지 않음

IBM Cloud

Oracle Cloud

Minio

DigitalOcean

NooBaa

Tencent Cloud

Ceph RADOS v12.2.7

Quobyte

Cloudian HyperStore

Non-supported volume snapshots
이 경우는 볼륨 스냅샷을 갖길 원하지만 프로바이더에 맞는 플러그인을 찾을 수 없을 때,

velero는 File System Backup을 사용하는 스냅샷을 지원한다. File System Backup
