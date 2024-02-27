## Multi-Cluster Migration Test

### Recovery cluster

앞의 예시대로 2번째 클러스터에도 설치가 완료되면

backup-location의 bucket을 조회했을때

클러스터 1에서 백업한 백업 파일을 조회 할 수 있다.

-access-mode=ReadOnly 플래그를 사용하여 BackupStorageLocations를 읽기 전용으로 구성하는 것이 좋다. 이렇게 하면 복원 중에 실수로 개체 저장소에서 백업이 삭제되지 않도록 할 수 있다.


```bash
velero backup-location create bsl --provider aws --bucket $BUCKET \
--config region=$REGION \
--access-mode=ReadOnly --default

velero snapshot-location create vsl --provider aws --config region=$REGION
```
```


### 클러스터 2에서 복원 테스트


```bash
❯ velero restore create --from-backup nginx-backup-pv
Restore request "nginx-backup-pv-20240102000340" submitted successfully.
Run `velero restore describe nginx-backup-pv-20240102000340` or `velero restore logs nginx-backup-pv-20240102000340` for more details.

❯ velero restore get
NAME                             BACKUP            STATUS      STARTED                         COMPLETED                       ERRORS   WARNINGS   CREATED                         SELECTOR
nginx-backup-pv-20240102000340   nginx-backup-pv   Completed   2024-01-02 00:03:41 +0900 KST   2024-01-02 00:03:43 +0900 KST   0        1          2024-01-02 00:03:41 +0900 KST   <none>

❯ velero restore describe nginx-backup-pv
An error occurred: restores.velero.io "nginx-backup-pv" not found

❯ velero restore describe nginx-backup-pv-20240102000340**
Name:         nginx-backup-pv-20240102000340
Namespace:    velero
Labels:       <none>
Annotations:  <none>

Phase:                       Completed
Total items to be restored:  11
Items restored:              11

Started:    2024-01-02 00:03:41 +0900 KST
Completed:  2024-01-02 00:03:43 +0900 KST

Warnings:
  Velero:     <none>
  Cluster:    <none>
  Namespaces:
    nginx-example:  could not restore, ConfigMap "kube-root-ca.crt" already exists. Warning: the in-cluster version is different than the backed-up version

Backup:  nginx-backup-pv

Namespaces:
  Included:  all namespaces found in the backup
  Excluded:  <none>

Resources:
  Included:        *
  Excluded:        nodes, events, events.events.k8s.io, backups.velero.io, restores.velero.io, resticrepositories.velero.io, csinodes.storage.k8s.io, volumeattachments.storage.k8s.io, backuprepositories.velero.io
  Cluster-scoped:  auto

Namespace mappings:  <none>

Label selector:  <none>

Or label selector:  <none>

Restore PVs:  auto
```

```bash
k get all -n nginx-example
k get pv -A
```

성공적으로 cluster1의 백업이 cluster2에 restore 된걸 확인 할 수 있다.

### Velero Uninstall

```bash
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
```