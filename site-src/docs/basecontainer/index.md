# ベースコンテナ { #base-container }

VCPにて、VCノードとして利用する仮想マシン上に起動するDockerコンテナを**ベースコンテナ**と呼ぶ。  
ベースコンテナ自体はVCコントローラが起動するため、基本的にユーザが直接操作することは無い。  
ここでは、ベースコンテナ用のDockerコンテナイメージの仕様を記載している。  

## ベースコンテナ種別 { #base-container-types }

ベースコンテナはOSごとに複数の種類が存在する。利用可能なベースコンテナイメージの種類については、以下の通り。

- [Alpine Linux 版](images.md#alpine-linux)
- [Ubuntu 版](images.md#ubuntu)
- [Ubuntu(Systemd) 版](images.md#ubuntu-systemd)
- [nvidia-container-toolkit 版](images.md#nvidia-container-toolkit)

★イメージの詳細は、[コンテナイメージ一覧](images.md) 参照

## ベースコンテナの起動コマンド { #base-container-startup-command }

VCノード作成時、VCコントローラによるプロビジョニング処理によりクラウドインスタンス上で以下のような `docker run` コマンドが実行され、ベースコンテナが起動する。  

```
docker run \
  -d \
  --privileged \
  --net="host" \
  -v /dev:/dev \
  -e PRIVATE_IP=XXX.XXX.XXX.XXX \
  -e VCCCTR_IPADDR=192.168.2.1 -e SERF_NODE_ID=xxxxx -e VCCC_ID=xxxxxx \
  vcp/base:3.0.0-alpine3.22
```

### 共通機能 { #common-features }

#### Supervisord { #supervisord }

* sshd、Docker、Serf、cAdvisorなどのプロセスを管理するために [Supervisord](http://supervisord.org/) を使用する
* ただし [Ubuntu(Systemd) 版](images.md#ubuntu-systemd) のみ例外で、Supervisordではなく Systemd のサービスユニットとして同等のプロセスを管理する

#### OpenSSH サーバ { #openssh }

* 公開鍵認証を許可する設定で sshd が常時稼働する
* ベースコンテナの環境変数`AUTHORIZED_KEYS` 環境変数により起動時に `root` ユーザの公開鍵を設定可能 

#### Docker { #docker }

* Docker in Docker 構成により ベースコンテナ内に Application コンテナを起動可能  
 （Application コンテナを使わない場合は不要）
* Storage Driver として `overlay2` を使用する

#### VCノード監視 { #vc-node-monitoring }

* [Hashicorp Serf](https://www.serf.io/) により、VCコントローラ管理下にあるVCノードを死活監視する

#### Dockerコンテナメトリクス収集 { #container-metrics }

* [Google cAdvisor](https://github.com/google/cadvisor) が常時稼働する
* VCコントローラ上の [Prometheus](https://prometheus.io/) により、VCノードのメトリクス情報を収集する

#### NFSサーバ { #nfs-server }
ベースコンテナの環境変数 `NFS_AUTOSTART` によりNFSサーバ自動起動の要否を指定可能である。

NFSの公開ディレクトリ設定は以下のとおり

* 公開するディレクトリ (export directory): `/export`

    * CCIのparam_vに ベースコンテナの /export　ディレクトリをクラウドインスタンスのディスク、またはアタッチした外部ディスクをmountするように設定すること

    * VCP SDKでの設定例: クラウドインスタンスの /export ディレクトリをベースコンテナの /export ディレクトリにマウントする  

        ```
        spec.param_v = ["/export:/export"]
        ```

* export host (or network): `*`
* host option: `rw,sync,no_subtree_check,fsid=0,no_root_squash`
* NFS公開するディレクトリを変更するには `/etc/exports` を編集して `exportfs -a` コマンドを実行すること

#### NFSクライアント { #nfs-client }
##### 使用方法 { #nfs-client-usage }
1. NFSクライアントのベースコンテナで `rpcbind` コマンドを実行する
2. NFSクライアントのベースコンテナで mount コマンドでNFSサーバが公開しているディレクトリをマウントする  

    例:  

    ```
    mount -t nfs {{NFSサーバのIPアドレス}}:/export /mnt
    ```

* ベースコンテナはNFSクライアントとして外部のNFSサーバの共有ディレクトリをNFSマウントするために必要なパッケージを含む


#### その他 インストール済みソフトウェア { #other-installed-software }

- [NVMe management command line interface (nvme-cli)](https://github.com/linux-nvme/nvme-cli)
- [Docker Compose](https://docs.docker.com/compose/)

### 環境変数 { #environment-variables }

以下の環境変数が利用可能。  

| 項目 | 説明 | 例 | 備考 |
|------|-----|----|------|
|`NFS_AUTOSTART`|NFS サーバを稼働させる場合は `true` を指定|`true / false`| |
|`AUTHORIZED_KEYS`|ベースコンテナの root アカウントに設定するSSH公開鍵を指定|`<Base64エンコード済みの公開鍵>`| ベースコンテナ起動時にデコードされ、 `/root/.ssh/authorized_keys` に展開される |
|`PRIVATE_IP`|VCノードのプライベートIPアドレス (SerfのbindアドレスやFluentdのログ送信元情報に使用)|`<VCノードのプライベートIPアドレス>`| ベースコンテナ起動時に設定される(コンテナイメージ開発者向け) |
|`VCP_CONTAINER_VERSION`|コンテナイメージ作成時にベースコンテナのバージョンが設定されている|`vcp/base:3.0.0-alpine3.22-dev`||
|`VCCC_ID`|VCコントローラのID (SerfによるVCノード死活監視に使用)|`<VCコントローラのユニークID>`| ベースコンテナ起動時に設定される(コンテナイメージ開発者向け) |
|`SERF_NODE_ID`|Serf による VC ノード監視用に使用する VC 内でユニークなID|`<VCノード内でユニークなID>`| ベースコンテナ起動時に設定される(コンテナイメージ開発者向け) |
|`VCCCTR_IPADDR`|VCコントローラのサービスネットワーク上のIPアドレス|`<VCコントローラのIPアドレス>`| ベースコンテナ起動時に設定される(コンテナイメージ開発者向け) |

### ベースコンテナの Listening Port とプロセス { #listening-port }

ベースコンテナは、 [ホスト・ネットワーク モード](https://docs.docker.jp/network/host.html) で起動されるため、以下の各 Listening Port はベースコンテナのホスト側 Port にもバインドされることになる。  

| port | protocol | process | 備考 |
|------|----------|---------|------|
|22|tcp|[sshd](https://man.openbsd.org/sshd.8)||
|2375|tcp|[dockerd](https://docs.docker.jp/engine/reference/commandline/dockerd.html)||
|7947|tcp,udp|[Serf](https://github.com/hashicorp/serf)||
|7373|tcp|[Serf](https://github.com/hashicorp/serf)||
|5353|udp|[Serf](https://github.com/hashicorp/serf)||
|18083|tcp|[cAdvisor](https://github.com/google/cadvisor)||
|9400|tcp|[DCGM-Exporter](https://github.com/NVIDIA/dcgm-exporter)|[nvidia-container-toolkit 版](images.md#nvidia-container-toolkit)のみ|

!!! note

    ベースコンテナのホスト側のsshdは `20022/tcp` で稼働する。ベースコンテナのsshdが22番ポートで稼働し、かつホスト・ネットワーク モードで起動されるため、ホスト側のsshdポートを変更している。
