# VCP提供の Baseコンテナイメージ

[VCP](https://github.com/nii-gakunin-cloud/vcc) で利用するBaseコンテナイメージについて説明する。Baseコンテナは、[VCノード](https://nii-gakunin-cloud.github.io/ocs-docs/concepts/index.html)上で動作するDockerコンテナのベースとなるイメージである。  

## Example

利用例を以下に示す。  

```
from vcpsdk.vcpsdk import VcpSDK
vcp = VcpSDK(vcc_access_token)
ugroup = vcp.create_ugroup("unit_group_aws", "compute")
spec = vcp.get_spec("aws", "medium")
spec.image = "harbor.vcloud.nii.ac.jp/vcp/base:3.0.0-alpine3.22-x86_64"
```

## 提供イメージ一覧

|イメージ名|説明|
|-|-|
|alpine3.22||
|ubuntu24.04||
|ubuntu24.04-systemd||
|ubuntu24.04-gpu||
