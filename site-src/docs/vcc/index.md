# 概要

利用者はポータブルVCコントローラを使用することにより、利用者が準備した実行環境にVCコントローラを配備し、
VCPの機能を用いてクラウド環境のリソースを利用することができる。
実行環境の例として、VirtualBox などの Linux VM 環境、クラウド上のインスタンス、利用者や利用組織が所有する
物理マシンが挙げられる。

## 対応クラウドプロバイダと動作環境

* AWS
* AWS (EC2 Spot Instance)
* Oracle Cloud Infrastructure
* Microsoft Azure
* Google Cloud Platform
* さくらのクラウド
* OpenStack
    - OpenStackをベースとするオンプレミスクラウド環境での動作実績はあるが、個別のOpenStack環境に合わせてVCPプラグイン実装をカスタマイズする必要がある。
* mdx Ⅱ
* Proxmox VE
* 既存サーバ
    - Dockerインストール済みの sshログイン可能なLinuxマシンを「既存サーバ」として使用する
    - VCPでは既存サーバを onpremises というクラウドプロバイダとみなす
    - オンプレミスマシンやVCPで非サポートのクラウドプロバイダ(ex. `mdx I`)を利用する場合に、予め用意した仮想マシンを「既存サーバ」として使用することができる。その他、自身でカスタマイズしたマシンイメージを利用したい場合等にも既存サーバモードを利用する。

## 利用方法

利用するには、DB等他のサービスが必須となる。  
それら関連サービスも含めたインストール手順やスクリプト、リファレンスは、ocs-vcp-portable リポジトリに記載している。

- [インストール](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/installation.md)
- [管理操作](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/manipulation.md)
- [vcc コマンド一覧](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/references/cli_commands.md)
- [VPNカタログ項目一覧](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/references/vpncatalog.md)
- プロバイダ別の事前準備: [Proxmox VE](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/references/providers/proxmox.md)、[mdx I](https://github.com/nii-gakunin-cloud/ocs-vcp-portable/blob/feature/vcc2610-volume/docs/references/providers/mdx1.md)
