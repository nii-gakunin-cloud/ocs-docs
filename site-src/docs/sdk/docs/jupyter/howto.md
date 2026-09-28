# VCP提供イメージ利用マニュアル

## ログインパスワード変更

`jupyter notebook password` コマンドを用いてログインパスワードを変更することができる。以下のコマンドを実行すると、パスワード変更プロンプトが表示されるので、新しいパスワードを入力する。

```
jovyan@519d28789fad:/$ /opt/conda/bin/jupyter notebook password
Enter password: 新しいパスワード
Verify password: 新しいパスワード
[NotebookPasswordApp] Wrote hashed password to /home/jovyan/.jupyter/jupyter_notebook_config.json
```

その後、コンテナを再起動することで新しいパスワードが有効化される。

```
docker restart vcp-jupyter-8888
```

## コンテナイメージのビルド

本リポジトリの資材を用いたコンテナイメージのビルドは、`bash build.sh <イメージディレクトリ> [タグサフィックス]`
で行う。タグサフィックスを省略した場合は `dev` が使われる。  

```
bash build.sh ./images/lab-4.5.7-simple
```

以下のような名前でコンテナイメージが作成される（`{IMAGE_TAG}` は `<イメージディレクトリ名>-<タグサフィックス>`、
上記の例では `lab-4.5.7-simple-dev`）。  

`harbor.vcloud.nii.ac.jp/vcpjupyter/cloudop-notebook:{IMAGE_TAG}`

ビルド実行時には、クレデンシャル情報の混入チェックのため `secretlint/secretlint` コンテナイメージが
自動的に取得・実行される。初回実行時や、ネットワーク環境によってはこの取得に時間がかかることがある。

> [!WARNING]
>   `images/cloudop` は、マルチステージビルドで `images/lab-4.5.7-simple` 側のビルド済みイメージ
>   （`harbor.vcloud.nii.ac.jp/vcpjupyter/cloudop-notebook:lab-4.5.7-simple-dev` 固定）から
>   `vcp-hook.sh` を取得する構成になっている。そのため `cloudop` をビルドする前に、まず
>   `lab-4.5.7-simple` をビルド（またはpull可能な状態に）しておく必要がある。
>
>   ```
>   # 1. 先に lab-4.5.7-simple をビルドする（デフォルトタグ: lab-4.5.7-simple-dev）
>   bash build.sh ./images/lab-4.5.7-simple
>
>   # 2. その後 cloudop をビルドする
>   bash build.sh ./images/cloudop
>   ```
