# インストール

## 要件

* Python 3.8 以上
* VCコントローラ (VCC) のアクセストークン
* (VCコントローラがプライベートCA発行のSSL証明書を使用している場合) その証明書
    - `requests` モジュール経由でHTTPS通信を行うため、環境変数 `REQUESTS_CA_BUNDLE` にCA証明書のパスを指定しておく必要がある。

## インストール

```
pip install git+https://github.com/nii-gakunin-cloud/vcpsdk.git
```

!!! note

    依存パッケージの1つ (`mdx`) は GitHub 上のリポジトリから直接インストールされるため、
    インストールを行う環境に `git` コマンドが必要。

VCP提供のJupyterNotebookコンテナイメージには、あらかじめ VCP SDK がインストール済みの場合であるため、本手順は不要。

## 設定ディレクトリの準備

VCP SDK は、VCコントローラへの接続情報やクラウド毎のデフォルトパラメータを設定ディレクトリ配下の
YAMLファイルから読み込む。設定ディレクトリは `VcpSDK` 初期化時に以下の優先順位で決定される。

1. `VcpSDK(config_dir=...)` に指定した値
2. 環境変数 `VCPSDK_CONFIG_DIR`
3. デフォルト値 `~/vcp_config`

設定ディレクトリには最低限、以下のファイルを配置する。

| ファイル | 必須 | 内容 |
|---|---|---|
| `vcp_config.yml` | ✓ | VCコントローラの接続先、利用するクラウドプロバイダごとのクレデンシャル参照先など |
| `vcp_flavor.yml` | | クラウドプロバイダ・flavor名(`small`/`medium`/`large`等)ごとのデフォルトスペック(インスタンスタイプ、ディスクサイズ等) |

どちらのファイルも `vcpsdk/schema/` 配下の JSON Schema でバリデーションされるため、
未対応のキーを指定するとロード時にエラーとなる。サンプルは `vcpsdk/setup/vcp_config.yml`,
`vcpsdk/setup/vcp_flavor.yml` を参照。

### `vcp_config.yml`

```yaml
vcc:
    host: occtr
    name: pvcc
    # DNAT等で接続先が異なる場合のみ指定
    # vcc_port: VCP REST API port
    # insecure_request_warning: False

    # VcNodeなどの起動・終了待ち時間の調整
    wait_timeout_sec: 1000 # default 1000sec = 15分

# クラウドプロバイダごとの設定。クレデンシャル値は直接記述せず、
# vault:// スキームで Vault (bao) 上のパスを参照する。
aws:
    access_key: "vault://cubbyhole/aws/access_key"
    secret_key: "vault://cubbyhole/aws/secret_key"
    private_network: "default"
```

`vcc.host` には VCコントローラのホスト名を指定する(JupyterNotebookコンテナから同一Docker network上の
`occtr` コンテナに接続する場合は `occtr` のままでよい)。

利用するクラウドプロバイダごとのセクション(`aws`, `azure`, `gcp`, `oracle`, `sakura`, `vmware`,
`proxmox`, `mdx2` など)には、クレデンシャルの実体を直接書くことは非推奨。`vault://cubbyhole/<provider>/<key>` の
形式で Vault 上のパスを参照することで、Vaultに登録したクレデンシャル情報を利用することを想定している。`private_network` には、利用するVPNカタログ名(VCコントローラの
`vpn_catalog.yml` で定義された名前)を指定する。

### `vcp_flavor.yml`

プロバイダ・flavor名ごとのデフォルトスペックを定義する。`VcpSDK.get_spec(provider_name, flavor)` は
この定義を初期値として spec オブジェクトを生成する(個々のパラメータは spec オブジェクトの属性として
上書き可能)。

```yaml
aws:
    small:
        instance_type: m4.large
        volume_type: gp2
        volume_size: 16
    medium:
        instance_type: m4.xlarge
        volume_type: gp2
        volume_size: 40
```

## クラウドクレデンシャルの登録 (Vault)

`vcp_config.yml` で `vault://cubbyhole/...` として参照したクレデンシャルの実体は、Vault に直接ではなく
`VcpSDK.post_credential(key, value)` 経由でVCコントローラに登録する。

```python
from getpass import getpass
from vcpsdk.vcpsdk import VcpSDK

vcp = VcpSDK(vcc_access_token=getpass("access token を入力"), config_dir="/path/to/vcp_config")

vcp.post_credential("aws/access_key", getpass("access key ID を入力"))
vcp.post_credential("aws/secret_key", getpass("secret key を入力"))
```

登録すべきキーはプロバイダごとに異なる(例: AWSは `access_key`/`secret_key`、Azureは
`subscription_id`/`client_id`/`client_secret`/`tenant_id` など)。まとめて設定するための
NotebookテンプレートがSDKに同梱されている(`vcpsdk/setup/credential_setup.ipynb`)。

登録済みのクレデンシャル値は `VcpSDK.get_credential(key)` で取得できる。

## 動作確認

設定ディレクトリの準備、クレデンシャル登録が完了したら、`VcpSDK` を初期化してVCコントローラへの接続を確認する。

```python
from vcpsdk.vcpsdk import VcpSDK

sdk = VcpSDK(vcc_access_token="xxxxxxxxxxxxx",
             config_dir="/path/to/vcp_config")

print(sdk.version_dict())  # VCコントローラ側のバージョン情報
print(sdk.authority())     # アクセストークンの権限情報
```

初期化時に認証チェックが行われるため、アクセストークンや `vcc.host` の設定に誤りがある場合はここで
例外が発生する。

続きは [クイックスタート](quickstart.md) を参照。
