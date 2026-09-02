# クイックスタート

VCP SDK を使って、VC(UnitGroup)の作成からNodeの起動までを行う最小限の手順を示す。

## 前提条件

* [インストール](installation.md) が完了していること
* VCコントローラのアクセストークンを取得済みであること
* 設定ディレクトリ (`vcp_config.yml`) の準備、利用するクラウドプロバイダのクレデンシャル登録が
  完了していること

## 1. VcpSDK の初期化

```python
from vcpsdk.vcpsdk import VcpSDK

sdk = VcpSDK(vcc_access_token="xxxxxxxxxxxxx",
             config_dir="/path/to/vcp_config")
```

## 2. VC(UnitGroup)の作成

VC は `VcpUnitGroupClass` のインスタンスとして扱う。引数 `ugroup_type` にはUnitGroupのタイプを指定する。  
引数省略時は、`compute`(コンピュートユニット)となる。ストレージユニットの場合、`storage` を指定する。

```python
ug = sdk.create_ugroup("my-vc")
```

## 3. spec の取得とパラメータ設定

Unit/Node を作成する際は、あらかじめ `get_spec()` でプロバイダ・flavorに対応する spec オブジェクトを
取得し、必要なパラメータを属性として設定する。flavorのデフォルト値は `vcp_flavor.yml` で定義したものが
使われる。

```python
spec = sdk.get_spec("aws", "small")

spec.num_nodes = 2                         # 作成するNode数
spec.set_ssh_pubkey("~/.ssh/id_rsa.pub")   # base containerへのSSH公開鍵
# spec.instance_type = "m4.xlarge"         # 必要に応じて上書き
# spec.set_tag("Owner", "myname")          # クラウド上のタグ
```

設定可能な属性はプロバイダごとに異なる。詳細は各プロバイダの spec 実装
(`vcpsdk.plugins.aws.VcpSpecResourceAws` など)の docstring を参照。

## 4. Unit の作成

```python
unit = ug.create_unit("web", spec)
```

`spec.num_nodes` で指定した数のNodeが起動し、既定では起動完了まで待機する
(`wait_for=False` を指定すると非同期で戻る)。

## 5. Node の追加・確認・削除

```python
# Nodeを追加で起動する
unit.add_nodes(num_add_nodes=1)

# Node一覧をDataFrameで確認する
unit.df_nodes()

# Nodeを削除する
unit.delete_nodes(num_delete_nodes=1)
```

## 6. 後片付け

```python
# Unitを削除する
ug.delete_units("web")

# VC(UnitGroup)全体を削除する
ug.cleanup()
```

## その他

* `sdk.df_ugroups()` / `sdk.df_nodes()` で、自分が保有する VC/Node の一覧を横断的に確認できる。
* `unit.watch_nodes()` を使うと、Nodeの死活状態変化を継続的に監視できる。
* より詳しい操作は [APIリファレンス](api/vcpsdk.md) を参照。
* VCノードの起動・削除を行うサンプル実装（jupyterノートブック）が利用可能。 （`examples`ディレクトリ参照）