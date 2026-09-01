# CoursewareHub 構築・運用に関する FAQ

講義演習環境テンプレートを用いた CoursewareHub の構築・運用でよくある問題と対処方法です。

---

## 000-README

対象 Notebook: `000-README.ipynb`

### 「作業用 Notebook の作成」を実行しても Notebook が開かない

「作業用 Notebook の作成」の冒頭で、作業用 Notebook を配置するディレクトリを次のように指定しています。

```
WORK_DIR = 'work'
```

ここで指定したディレクトリの配下に作業用 Notebook が作成されています。そちらの Notebook を直接
実行してください。

---

## VC ノード作成・構成

対象 Notebook: `011-VCノード作成-構成1.ipynb`、`021-VCノード作成-構成2.ipynb`、`031-VCノード作成-構成3.ipynb`

### 「パラメータの保存」で `Exception: File 'scripts/check_params.py' not found.` となる

`000-README.ipynb` で「作業用 Notebook の作成」を実行せず、`notebooks/` にある Notebook を直接
実行している場合にこのエラーが出力されます。

`000-README.ipynb` で「作業用 Notebook の作成」を実行し、作成された作業用の Notebook を実行して
ください。

### 「Docker Swarm の設定」でトークン取得時に `[DEPRECATION WARNING]` が出力されエラーとなる

Ansible の実行で警告メッセージが出ているため、想定した出力結果を処理できずにエラーになっています。

`ansible.cfg` の `[defaults]` セクションにある `command_warnings` を設定している行を削除し、
再度実行してください。

---

## CoursewareHub のセットアップ

対象 Notebook: `121-CoursewareHubのセットアップ-ローカルユーザ認証.ipynb`、`221-CoursewareHubのセットアップ.ipynb`、`321-CoursewareHubのセットアップ.ipynb`

### 「CoursewareHub にアクセスする」でエラーとなる

コンテナの起動に失敗していることがあります。「コンテナの起動」の最後に、起動後の状態とログを
確認するセルがあります。次のコマンドを個別に実行し、再起動が繰り返されていないか、エラーが
出ていないかを確認してください。

```
!ansible {target_hub} -a 'docker stack ps {{{{ugroup_name}}}}'
!ansible {target_hub} -a 'docker service logs {{{{ugroup_name}}}}_postgres'
!ansible {target_hub} -a 'docker service logs {{{{ugroup_name}}}}_jupyterhub'
!ansible {target_hub} -a 'docker service logs {{{{ugroup_name}}}}_auth-proxy'
```

再起動が繰り返されている場合やエラーが出力されている場合は、**manager ノード上で**次のコマンドを
実行し、CoursewareHub のコンテナ群を再配備してください。

```
# {unitgroup_name} は構築時に指定した UnitGroup 名に置き換えてください
cd /srv/cwh
docker stack rm {unitgroup_name}
docker stack deploy -c docker-compose.yml {unitgroup_name}
```

問題が解消されない場合は[お問い合わせ](../README.md#お問い合わせ)ください。

---

## CoursewareHub コンテンツの配備

対象 Notebook: `D06_CoursewareHubコンテンツの配備.ipynb`

### 最初のセルが実行中のまま完了しない

CoursewareHub 管理者環境から manager ノードに ssh で**初めて**接続する際、接続先のホスト鍵を
`~/.ssh/known_hosts` に取り込むかどうかを `Are you sure you want to continue connecting (yes/no)?`
のように確認されます。この状態で止まると、Notebook 上には何も表示されずセルが実行中のままになります。

Jupyter Notebook の Terminal から manager ノードに ssh 接続し、上記のメッセージに `yes` と入力して
`known_hosts` にホスト鍵を取り込んでから、セルを実行してください。

---

## その他運用

### manager ノードで export している NFS を singleuser コンテナ内で追加でマウントしたい

次の 2 段階で設定します。

1. manager ノードのファイルを worker ノードで NFS マウントする
2. worker ノードのファイルを singleuser コンテナでマウントする

#### 1. manager ノードのファイルを worker ノードで NFS マウント

worker ノードでは、manager ノードの `/exported/${ugroup_name}` を `/mnt/nfs` に NFS マウントして
います (worker ノードの `/etc/fstab` で確認できます)。このディレクトリの下に共有ディレクトリを
作れば、NFS により各ノードでファイルを共有できます。

#### 2. worker ノードのファイルを singleuser コンテナでマウント

ノードで NFS の共有ができていれば、singleuser コンテナでは NFS を考慮する必要はなく、bind mount
などでそのノードのファイルをコンテナから見えるように設定するだけで済みます。

singleuser コンテナに追加の bind mount を設定するには、jupyterhub コンテナ内の設定ファイル
`/srv/jupyterhub/jupyterhub_config.py` に `extra_user_mounts` の記述を追加します。手順は次の
とおりです。

**(1) 既存の jupyterhub_config.py を取得する**

テンプレートで使用している jupyterhub コンテナの `jupyterhub_config.py` は、
[CoursewareHub-LC_platform](https://github.com/NII-cloud-operation/CoursewareHub-LC_platform) の
`jupyterhub/jupyterhub_config.py` から取得できます。

**(2) extra_user_mounts の設定を追加する**

worker ノードの `/mnt/nfs/local` を singleuser コンテナの `/opt/local` として bind mount する
場合は、次の内容を追記します。

```python
from docker.types import Mount

c.CoursewareUserSpawner.extra_user_mounts = [Mount(
    type="bind",
    target='/opt/local',
    source='/mnt/nfs/local',
    read_only=False
)]
```

**(3) docker-compose.yml に反映を設定する**

編集した設定ファイルを jupyterhub コンテナに反映するため、`docker-compose.yml` の jupyterhub
サービスに bind mount を追加します。設定ファイルを manager ノードの
`/srv/cwh/jupyterhub/jupyterhub_config.py` に配置していることを前提とします。

```yaml
      - type: bind
        source: /srv/cwh/jupyterhub/jupyterhub_config.py
        target: /srv/jupyterhub/jupyterhub_config.py
```

**(4) コンテナ群を再配備する**

manager ノード上で次を実行します。

```
# {unitgroup_name} は構築時に指定した UnitGroup 名に置き換えてください
cd /srv/cwh
docker stack rm {unitgroup_name}
docker stack deploy -c docker-compose.yml {unitgroup_name}
```

### worker ノードのリソースに余裕があるのに、一定数以上の single-user サーバコンテナが起動できない { #resource-limit }

セットアップ用 Notebook の「リソース制限の設定」で設定している制限値が影響していると考えられます。
設定ファイルには次のような最小保証値を指定できます。

```
mem_guarantee: 1G
cpu_guarantee: 0.5
```

これらは CPU とメモリの最小保証値です。single-user サーバコンテナを起動する際、実際には使用されて
いなくても `起動数 × 最小保証値` 分のリソースが確保できない場合、それ以上起動できなくなります。
値を変更し、起動可能数に変化がないか確認してください。

収容設計については `000-README.ipynb` の「収容設計について」も参照してください。

設定値の変更は次の手順で反映します。

1. 変更した `resource.yaml` を manager ノード上の `/srv/cwh/jupyterhub/resource.yaml` と置き換える
2. manager ノード上で次を実行し、新しい設定で各コンテナを起動しなおす

    ```
    # {unitgroup_name} は構築時に指定した UnitGroup 名に置き換えてください
    cd /srv/cwh
    docker stack rm {unitgroup_name}
    docker stack deploy -c docker-compose.yml {unitgroup_name}
    ```

3. 次を実行して各コンテナの起動状態を確認する

    ```
    docker stack ps {unitgroup_name}
    ```

### ユーザが利用する single-user サーバコンテナの処理が重い

セットアップ用 Notebook の「リソース制限の設定」を確認し、single-user サーバコンテナに割り当てる
リソース配分の変更を試してください。

その際、`801-リソース可視化.ipynb` を参考に Grafana で問題発生時のリソース状況を確認しながら
変更するとよいでしょう。この Notebook で紹介している JupyterHub.json では、single-user サーバ
コンテナの起動数やリソース使用量を確認できます。

リソース設定の反映方法は[前項](#resource-limit)を参照してください。

---

## 解決しない場合

[サポートポリシー](../README.md)に記載の窓口までお問い合わせください。

CoursewareHub 構築時の問題については
[情報収集用の Notebook](https://nii-gakunin-cloud.github.io/ocs-docs/faq/ocs-template/CousewareHub構築時の問題分析のための情報収集.ipynb)
を用意しています。実行結果を保存したファイルも添付してください。
