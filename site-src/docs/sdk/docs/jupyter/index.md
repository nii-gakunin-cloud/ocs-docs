# VCP用JupyterNotebookコンテナイメージ

[ocs-templates](https://github.com/nii-gakunin-cloud/ocs-templates)を利用するためのJupyterNotebook コンテナイメージについて説明する。  

## 要件

### パッケージ等

| 必須 | 依存関係 | 説明 |
|---|---|---|
|✓|vcpsdk|VCコントローラのAPIを利用するためのPython SDK。JupyterNotebook上でVCコントローラのAPIを利用するために必要。|
|✓|git|バージョン管理システム。JupyterNotebook上でのコード管理や、ocs-templatesの利用に必要。|
|✓|ansible|構成管理ツール。ocs-templatesを利用してJupyterNotebook上での環境構築や管理を行うために必要。|
|✓|rsync|ファイル同期ツール。Ansibleでのファイル同期に必要。|
||vcpcli|ローカルファイルを操作するためのPython CLIツール。VCコントローラに登録した認証情報を利用して、クラウド上のファイルの管理を行う|

### VCコントローラ CA証明書

JupyterNotebookからVCコントローラ、VaultサーバへのアクセスにTLSを使用するために、予め発行したCA証明書が必要。VCコントローラとJupyterNotebookを同じホスト上で動作させる場合等、自己署名証明書を使用する場合、その証明書を予め証明書リスト（`/usr/local/share/ca-certificates` 等）に登録しておく必要がある。  

!!! note  

    プログラム（Pythonの`requests`モジュール）からリクエストを行う場合はOSの証明書リストが参照されないため、環境変数 `REQUESTS_CA_BUNDLE` を通じて当該証明書のファイルパスを指定しておく必要がある。

## VCP提供のjupyterコンテナイメージ

VCPでは、前述した仕様を満たすJupyter Notebook環境をDockerコンテナイメージとして提供している。  
コンテナイメージには、ベースイメージやインストール済みのパッケージ等の違いにより、以下の通り複数のバリエーションがある。  

- [`Jupyter-LC_docker`](https://github.com/NII-cloud-operation/Jupyter-LC_docker) をベースイメージとし、VCP向けにカスタマイズしたもの
- Jupyterプロジェクト公式の [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) のイメージをベースイメージとし、VCP向けにカスタマイズしたもの

★ イメージの詳細は、[コンテナイメージ一覧](images.md) 参照  
★ コンテナ起動サンプルは、[クイックスタート](quickstart.md) 参照  

### 環境変数

以下の環境変数が利用可能。  

| 項目 | 説明 | 例 | デフォルト| 備考 |
|------|-----|----|------|------|
|`REQUESTS_CA_BUNDLE`|VCコントローラ CA証明書のファイルパス|`/etc/ssl/certs/ca-certificates.crt`|`/etc/ssl/certs/ca-certificates.crt`| |
|`TZ`|JupyterNotebook コンテナ上の timezone|`JST-9`|`JST-9`| 例: 東京(+09:00)の場合は `JST-9` を指定 |
|`VCP_CONTAINER_VERSION`|JupyterNotebook コンテナのバージョン|`vcpjupyter/cloudop-notebook:20250401-ssl-cc`||参照用に、コンテナイメージビルド時に指定されている|
|`PASSWORD`|JupyterNotebook のログインパスワード|`任意のパスワード`| | |

!!! note

    `VCP_CONTAINER_VERSION` は、コンテナイメージが `vcpjupyter/cloudop-notebook:20190219-ssl-vcp` 以前の場合、null 値となる。
