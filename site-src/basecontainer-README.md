# VCP提供の Baseコンテナイメージ

[VCP](https://github.com/nii-gakunin-cloud/vcc) で利用するBaseコンテナイメージについて説明する。Baseコンテナは、VCノード上で動作するDockerコンテナのベースとなるイメージである。  

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

各イメージの詳細（機能・リリースタグ一覧・命名規則等）は [コンテナイメージ一覧](docs/images.md) を参照。  

|イメージ名|説明|
|-|-|
|alpine3.22|Alpine Linuxベースの軽量イメージ。vcpで起動するデフォルトイメージ|
|ubuntu24.04|Ubuntuベースのイメージ|
|ubuntu24.04-systemd|`ubuntu24.04`を継承し、各サービスをSystemdのサービスユニットで管理するイメージ|
|ubuntu24.04-gpu|`ubuntu24.04`をベースに、nvidia-container-toolkitをインストール済みのGPU環境向けイメージ|
