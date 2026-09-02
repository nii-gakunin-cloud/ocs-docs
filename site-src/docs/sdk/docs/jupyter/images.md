# コンテナイメージ一覧

各コンテナイメージの詳細について記載する。  

コンテナイメージは、`harbor.vcloud.nii.ac.jp/vcpjupyter/cloudop-notebook` リポジトリで公開されている。  

!!! note 利用可能なコンテナイメージ一覧取得

    Harbor API（v2.0）を用いて、利用可能なベースコンテナイメージのタグ一覧を取得することができる。  

    ```
    curl -s https://harbor.vcloud.nii.ac.jp/api/v2.0/projects/vcpjupyter/repositories/cloudop-notebook/artifacts?q=tags=* | jq .[].tags[0].name
    ```

## Jupyter-LC_docker ベース

[`Jupyter-LC_docker`](https://github.com/NII-cloud-operation/Jupyter-LC_docker) をベースイメージとし、VCP向けにカスタマイズしたイメージ。

### リリース一覧

| タグ | リリース日 | 備考 |
|------|------|--|
|lab-4.5.0|2026-10-01||

## Jupyter公式イメージベース

Jupyterプロジェクト公式の [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) のイメージをベースイメージとし、VCP向けにカスタマイズしたイメージ。  
最もベーシックな構成のイメージ（[`jupyter/base-notebook`](https://quay.io/repository/jupyter/base-notebook)）をベースイメージとし、最低限の機能に絞った軽量版。タグに `-simple` が付与される。  

### リリース一覧

| タグ | リリース日 | 備考 |
|------|------|--|
|lab-4.5.7-simple|2026-10-01||
