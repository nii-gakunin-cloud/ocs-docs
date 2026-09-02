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

本リポジトリの資材を用いたコンテナイメージのビルドは以下のように行う。  

```
bash build.sh ./images/lab-4.5.7-simple
```

以下のような名前でコンテナイメージが作成される。  

`harbor.vcloud.nii.ac.jp/vcpjupyter/cloudop-notebook:{IMAGE_TAG}`
