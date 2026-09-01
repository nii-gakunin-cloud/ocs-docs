# VCP CLI

[VCコントローラ](https://github.com/nii-gakunin-cloud/ocs-vcp-portable) で管理している認証情報を利用して、ローカルファイルをAWS S3やAzure Blob Storageにアップロードしたり、ダウンロードしたりすることができるCLIツール。


## 対象クラウドプロバイダ（ストレージサービス）
- AWS S3
- Azure Blob Storage

## 使い方

```bash
vcp storage [--debug] create [--no-verify] [--public] <bucket_path>
vcp storage [--debug] drop [--no-verify] <bucket_path>
```

# For Developers

## ドキュメント生成

```bash
uv sync --no-dev --group docs
```