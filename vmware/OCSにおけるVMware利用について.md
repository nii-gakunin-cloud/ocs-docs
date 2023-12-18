# OCSにおけるVMware利用について

## ネットワーク接続の概要

- オンプレミスシステムのVMware vSphere環境は、利用機関のセグメント内に構築されている想定です。
- 接続申し込みにあたって、外部のパブリッククラウド環境を併用しない場合は項目(7)〜(16) を提示いただく必要はありません。

![](https://i.imgur.com/Pfq73oY.png)

![](https://i.imgur.com/1OmZcX0.png)

## ネットワークの要件

オンプレミスシステムで構築されたVMware vSphere環境をOCSから利用するためのネットワークに関する要件は以下のとおりです。

1. VCコントローラから vSphere 環境へのルーティングが可能なこと
    - vCenter Server に対し、vSphere の REST API (vCenter REST API) が実行できること
    - vCenter 管理下のESXiサーバで作成されるVM (=VC Node) に対し、SINET L2VPNによるプライベートネットワークで接続可能なこと
2. vCenter管理下で作成されるVMのためのDHCPサーバが用意されていること
      - VCノード作成時に固定IPアドレスを付与する場合は不要
3. vCenter REST API 実行のために必要な各パラメータ（後述）をOCS運用担当者に提示し、VCコントローラに設定済みであること

## VMware 仮想マシン テンプレートの作成について

VMware vSphere環境において、OCS向けの仮想マシン テンプレートを作成する際の必要事項について説明します。

### 仮想マシン テンプレートの要件

1. サポート対象 OS ディストリビューション: `Ubuntu 20.04 LTS`
2. ssh サーバが VM 起動時にポート22番で自動起動すること
3. パスワード認証による ssh ログイン可能な `ubuntu` ユーザが存在すること
    - パスワードはOCS運用担当者から指定されたものを設定すること
4. `ubuntu` ユーザは `sudo` コマンドによりパスワード入力無しで root権限を得られること
5. Docker-CE がインストール済みで VM 起動時に Docker daemon が自動起動すること
    - インストール手順 https://docs.docker.com/engine/install/ubuntu/
7. VMware Tools がインストール済みで VM 起動時にサービスが自動起動すること
    - Ubuntu の場合は `open-vm-tools` パッケージを利用可能
    - VM起動後に OS のカスタマイズ機能を実行する仕組みは VMware Tools が担っている

### VMをテンプレートに変換する前に必要な操作

1. cloudconfig に元のホスト名が保持されないようにし、ホスト名をリセットします。

```
sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
sudo truncate -s0 /etc/hostname
sudo hostnamectl set-hostname localhost
```

2. 現在のネットワーク構成を削除します。

```
sudo rm /etc/netplan/*.yaml
```

3. シェルの履歴を消去して VM をシャットダウンします。

```
cat /dev/null > ~/.bash_history && history -c
sudo shutdown now
```

- (参考資料) [VMware vSphere仮想マシン テンプレート作成のためのガイダンス](https://learn.microsoft.com/ja-jp/azure/cloud-adoption-framework/manage/hybrid/server/best-practices/vmware-ubuntu-template#post-installation)

## vCenter REST API 実行のために必要な各パラメータ

VCコントローラ側で事前に設定が必要な以下の各パラメータ情報をOCS運用担当者にご提示いただきます。

- vSphereサーバ (vCenter) のホスト名 または IPアドレス
- vSphereのデータセンター名
- vSphereのデータストア名
- vSphereのリソースプール名
- 仮想マシン接続先のvSphereのネットワーク名
- 仮想マシン接続先のvSphereのネットワークサブネットマスク長
- マシンイメージとして使う仮想マシンテンプレートの名前（VMテンプレート名）
- 仮想マシンに設定するデフォルトゲートウェイのIPアドレス
- 仮想マシンに設定するドメイン名（例: `<VCコントローラ名>.local`）
- 仮想マシンに設定するNTPサーバ情報（例: `pool ntp.nict.jp iburst`）
- 仮想マシンに設定する参照先DNSサーバのIPアドレス（例: `8.8.8.8`）
