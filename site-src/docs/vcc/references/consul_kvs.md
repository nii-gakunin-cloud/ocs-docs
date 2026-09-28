# Consul KVS データ構造

VCコントローラ（occtr）は、VC・Unit・Node等の状態をConsul KVSに保存する。  
本ページでは、Consul KVS上のキー階層と各キーに格納されるデータ構造を説明する。  
UnitGroup（SDK側の呼称。occtr内部では **VC** と呼ぶ）やその配下のリソースを、何らかの理由でVCC REST API/CLIを使わずにKVSから直接削除する必要がある場合の手順も示す。

> [!WARNING]
> 本ページの手順は、通常はVCC REST API（またはCLI）経由の削除が失敗し続ける場合の最終手段として使うことを想定している。  
> KVSを直接操作すると、クラウド上に実際に残っているインスタンス・ディスク等のリソースとKVS上の状態が食い違う（クラウドリソースが残ったままKVS上の記録だけが消える）ことがある。  
> 実行前に、対象のUnitGroup配下のクラウドリソース（インスタンス、ディスク等）がすでに存在しないこと、またはterraformのstate等と合わせて別途削除・整理する計画があることを確認すること。  
> 可能であれば、削除対象キー配下を `consul kv export` 等でバックアップしてから作業する。

## 前提: キーのプレフィックスと用語

すべてのキーは `vcp/modules/vcpm/` から始まる。

| SDK/ドキュメント上の呼称 | occtr内部のクラス | 備考 |
| --- | --- | --- |
| UnitGroup | `datamodel.vc.VC` | 1つのUnitGroupが1つのVCに対応する |
| Unit（compute種別） | `datamodel.unit.Unit` | ノードの集合 |
| Unit（storage種別） | `datamodel.diskunit.DiskUnit` | ディスクの集合 |
| Node | `datamodel.node.Node` | compute UnitGroupの仮想マシン1台 |
| Disk | `datamodel.disk.Disk` | storage UnitGroupのディスク1台 |
| Gateway | `datamodel.gateway.Gateway` | UnitGroupに紐づくservice internet gateway |

各クラスの実装は `datamodel/` 配下にあり、KVSキーのフォーマット文字列はクラス変数 `KVS_KEY`（固定値のINFO）、`LOCK_KEY_BASE_TEMPLATE`（可変値=mutable fieldのベース）として定義されている。

## キー階層全体図

```text
vcp/modules/vcpm/
├── OC_CONTROLLER_INFO/<occtr_id>                         … occtr自身の設定 (OCController)
├── OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/
│   ├── vc_id_list/{info,lock}                            … 全UnitGroup IDの一覧
│   ├── node_id_list/{info,lock}                          … 払い出し済みNode/Disk IDの一覧
│   ├── user_info/{info,lock}
│   └── l2vpn_pool/{info,lock}
│
├── OC_INFO/<vcid>/                                        … 1つのUnitGroup(VC)
│   ├── INFO                                               … UnitGroup本体
│   ├── MUTABLE_INFO/
│   │   ├── state
│   │   ├── owner
│   │   └── unit_name_list/{info,lock}                     … このUnitGroupに属するUnit名の一覧
│   │
│   ├── UNIT_INFO/<unit_name>/                             … compute種別のUnit
│   │   ├── INFO
│   │   ├── MUTABLE_INFO/state
│   │   ├── MUTABLE_INFO/terraform_error_log
│   │   ├── MUTABLE_INFO/processing
│   │   └── NODE_INFO/<node_id>/
│   │       ├── INFO
│   │       └── MUTABLE_INFO/{state,watch_mode,error_message,tf_param_source_path,tf_setup_source_path,chrony_path}
│   │
│   ├── DISK_UNIT_INFO/<unit_name>/                        … storage種別のUnit
│   │   ├── INFO
│   │   ├── MUTABLE_INFO/state
│   │   ├── MUTABLE_INFO/terraform_error_log
│   │   ├── MUTABLE_INFO/processing
│   │   └── DISK_INFO/<disk_id>/
│   │       ├── INFO
│   │       └── MUTABLE_INFO/{state,error_message,in_use}
│   │
│   └── GATEWAY_INFO/<gateway_name>/INFO
│
├── RACK_INFO/<rack_id>                                     … VCPRack
├── OCC_MGR_INFO/<rack_id>                                  … OCCManager
├── OCC_MGR_MASTER                                          … OCCManagerのリーダー選出用ロック
├── IP_POOL_INFO/<type>/<rack_id>                           … IpPool
├── ACCESS_KEY_INFO/<account>                               … AccessKey
├── GAKUNIN_ACCOUNT_INFO/<account>                          … GkAccount
└── SINET_L2VPN/<sl2vpn_id>                                 … SL2VPN
```

Consul KVS自体はフラットなキーバリューストアであり、上記の階層はキー文字列の `/` 区切りによる見かけ上の階層である。  
例えば1台のNodeの本体情報は、実際には `vcp/modules/vcpm/OC_INFO/<vcid>/UNIT_INFO/<unit_name>/NODE_INFO/<node_id>/INFO` という1本の文字列キーに、1つのJSON値として格納されている。

`INFO` キーの値はUTC以外のフィールドをそのまま含むオブジェクト全体、`MUTABLE_INFO/<field>` キーの値は、更新頻度の高い単一フィールドを個別に読み書きするためのものである（`datamodel/base.py` の `MutableDatamodelBase`）。`xxx_list/info` の値は `{"list": [...], "no": <通し番号>}` という形式で、対になる `xxx_list/lock` キーは書込み時にCAS（`?cas=0`）で確保・解放される一時的な排他ロック用キーであり、通常運用中は存在しない（残っている場合は、書込み処理が異常終了してロックが解放されなかった可能性がある）。

## 各データのJSON構造

### UnitGroup本体（`OC_INFO/<vcid>/INFO`）

```json
{
  "occtr_id": "occtr01",
  "vcid": "3fae2b7c9d8e4a1eb6c0f21a5d7e9c31",
  "vcno": 12,
  "name": "my-unitgroup",
  "type": "compute",
  "description": null,
  "state": null,
  "cdate": "2026/01/10 09:00:00 JST",
  "cci": "<base64エンコードされたCCI全体>",
  "owner": null,
  "token_head": null,
  "unit_name_list": ["unit1"],
  "gateway_name_list": [],
  "creating": false,
  "updating": false,
  "is_migrated20_04_0": true,
  "is_migrated21_10_0": true,
  "error_message": null
}
```

> [!NOTE]
> `state`・`owner`・`unit_name_list` は移行済み環境（`is_migrated20_04_0`/`is_migrated21_10_0` が `true`）では実際にはこのINFOキーの値を使わず、後述の `MUTABLE_INFO` 配下の値が正となる（INFOキー内の値は移行前の名残であり、以後は更新されない）。  
> `gateway_name_list` は削除処理内で直接書き換えられており、実質的にはINFOキー内の値がそのまま使用されている（コード中のコメントには「使用していない」とあるが、Service Internet Gateway関連の処理で参照・更新されている）。

- `MUTABLE_INFO/state`: 文字列。`"APPLYING"` / `"RUNNING"` / `"DELETING"` / `"ERROR"` のいずれか。
- `MUTABLE_INFO/owner`: 文字列（ユーザ名）。未設定時は `"nobody"`。
- `MUTABLE_INFO/unit_name_list/info`: `{"list": ["unit1", "unit2"], "no": 2}`。UnitGroupに属するUnit名の一覧。

### Unit（compute種別、`OC_INFO/<vcid>/UNIT_INFO/<unit_name>/INFO`）

```json
{
  "vcid": "3fae2b7c9d8e4a1eb6c0f21a5d7e9c31",
  "name": "unit1",
  "description": null,
  "state": null,
  "cdate": "2026/01/10 09:00:05 JST",
  "info": "<base64エンコードされたCCIのUnit部分>",
  "provider": "aws",
  "last_node_no": 2,
  "node_id_list": ["a1b2c3d4...", "e5f6a7b8..."],
  "processing": false,
  "ssh_user_name": "ubuntu",
  "network_if": null,
  "terraform_error_log": null,
  "last_state_update_time": null,
  "volume_list": [],
  "is_migrated20_04_0": true
}
```

> [!NOTE]
> `node_id_list` はUnitGroupの `unit_name_list` とは異なり、専用の `MUTABLE_INFO` キーを持たず、このINFOキー自身の値の一部としてUnit全体のPUT（読み込み→書き換え→書き込み）で更新される。  
> Nodeを追加・削除する際は、必ずこのUnitのINFOキーの `node_id_list` も合わせて更新する必要がある（KVSは自動的に整合させない）。

- `MUTABLE_INFO/state`: 文字列。`Unit.State` のいずれか（例: `"RUNNING"`, `"DELETING"`, `"ERROR"` 等）。
- `MUTABLE_INFO/terraform_error_log`: 文字列またはnull。
- `MUTABLE_INFO/processing`: `{"vcid": "...", "name": "unit1", "processing": false}`。CASによる排他制御専用（`UnitProcessing`）。

### Node（`OC_INFO/<vcid>/UNIT_INFO/<unit_name>/NODE_INFO/<node_id>/INFO`）

```json
{
  "_tag": "Node",
  "vcid": "3fae2b7c9d8e4a1eb6c0f21a5d7e9c31",
  "unit_name": "unit1",
  "provider": "aws",
  "node_id": "a1b2c3d4e5f60718293a4b5c6d7e8f90",
  "node_no": 1,
  "state": null,
  "cdate": "2026/01/10 09:00:05 JST",
  "boot_date": null,
  "container_date": null,
  "resource_name": "node1",
  "watch_mode": true,
  "host_address": {"class": "ipif", "val": "10.0.0.5/24"},
  "cloud_instance_id": "i-0123456789abcdef0",
  "error_message": null,
  "tf_param_source_path": null,
  "tf_setup_source_path": null,
  "tf_name_tag": "my-unitgroup-unit1-1",
  "onpremises_base_already_exists_error": false,
  "ssh_checktime": null,
  "ssh_checktime_delta": 0,
  "plugin_data": {},
  "plugin_node_info": {},
  "volume_list": [],
  "is_migrated20_04_0": true
}
```

IPアドレスを表すフィールド（`host_address` 等）は、`{"class": "ipif", "val": "<CIDR表記>"}`（インターフェース）または `{"class": "ipadr", "val": "<IPアドレス>"}`（アドレスのみ）という形式でエンコードされる。

- `MUTABLE_INFO/state`: 文字列。`Node.State` のいずれか（`"BOOTING"`, `"RUNNING"`, `"STOPPED"`, `"DELETING"`, `"HOST_ERROR"` 等）。
- `MUTABLE_INFO/watch_mode`: 真偽値。serfによる死活監視の対象かどうか。
- `MUTABLE_INFO/error_message`: 文字列またはnull。
- `MUTABLE_INFO/tf_param_source_path`, `MUTABLE_INFO/tf_setup_source_path`, `MUTABLE_INFO/chrony_path`: 文字列またはnull（tofu実行用スクリプトの保存パス）。

### DiskUnit（storage種別、`OC_INFO/<vcid>/DISK_UNIT_INFO/<unit_name>/INFO`）とDisk（`.../DISK_INFO/<disk_id>/INFO`）

Unit/Nodeと対称的な構造を持つ。

```json
// DiskUnit INFO
{
  "vcid": "...", "name": "diskunit1", "description": null,
  "state": null, "cdate": "...", "info": "<base64 CCI>",
  "provider": "aws", "last_disk_no": 1,
  "disk_id_list": ["d1e2f3..."],
  "processing": false, "is_migrated20_04_0": true,
  "terraform_error_log": null
}
```

```json
// Disk INFO
{
  "_tag": "Disk",
  "vcid": "...", "unit_name": "diskunit1", "provider": "aws",
  "disk_id": "d1e2f3...", "disk_no": 1,
  "state": null, "cdate": "...",
  "in_use": null, "resource_name": "disk1",
  "cloud_disk_id": "vol-0123456789abcdef0", "cloud_disk_size": null,
  "error_message": null, "tf_name_tag": "my-unitgroup-diskunit1-1",
  "plugin_output_data": {}, "is_migrated20_04_0": true
}
```

- DiskUnitの `MUTABLE_INFO/{state,terraform_error_log,processing}` はUnitと同様。
- Diskの `MUTABLE_INFO/{state,error_message,in_use}`。`in_use` は真偽値でNodeにアタッチ中かどうかを表す。
- DiskUnitのINFOキー内 `disk_id_list` も、Unitの `node_id_list` と同様に専用mutableキーを持たず、DiskUnit全体のPUTで更新される。

### Gateway（`OC_INFO/<vcid>/GATEWAY_INFO/<gateway_name>/INFO`）

```json
{
  "vcid": "...",
  "gateway_name": "gw1",
  "primary_global_ipmask": {"class": "ipif", "val": "203.0.113.10/32"},
  "secondary_global_ipmask": {"class": "ipif", "val": "203.0.113.11/32"},
  "entries": [
    {"class": "Gateway.Entry", "ip": "10.0.0.5/24", "port": 8080}
  ]
}
```

Gatewayは他モデルと異なりmutableフィールドを持たず、更新のたびにこのINFOキー全体を上書きする。

### OCController（`OC_CONTROLLER_INFO/<occtr_id>`）

occtr自身のネットワーク設定・VPNカタログ等の巨大な構成情報を保持する。UnitGroupの削除には直接関係しないが、以下のmutableフィールドはUnitGroup/Node/Diskの生成・削除のたびに更新される。

- `OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/vc_id_list/info`: `{"list": ["<vcid1>", "<vcid2>", ...], "no": N}`。occtr配下の全UnitGroup IDの台帳。
- `OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/node_id_list/info`: `{"list": ["<id1>", ...], "no": N}`。Node/Disk ID採番時の重複回避に使う、全UnitGroup共通のID台帳（NodeとDiskのIDを区別せず同じ台帳を使う）。

## UnitGroup（VC）をKVSから直接削除する手順

### 削除対象キーと順序

UnitGroup配下の子リソースから順に削除し、最後にUnitGroup本体とocctr側の台帳を更新する。逆順（親を先に消す）で行うと、子リソースのキーが孤立して残る。

| 順序 | 対象 | 削除・更新するキー |
| --- | --- | --- |
| 1 | 各Node（該当UnitGroupの全Unit分） | `OC_INFO/<vcid>/UNIT_INFO/<unit>/NODE_INFO/<node_id>/INFO` および同配下の `MUTABLE_INFO/*` |
| 2 | 各Disk（storage UnitGroupの場合） | `OC_INFO/<vcid>/DISK_UNIT_INFO/<unit>/DISK_INFO/<disk_id>/INFO` および同配下の `MUTABLE_INFO/*` |
| 3 | 各Unit / DiskUnit | `OC_INFO/<vcid>/UNIT_INFO/<unit>/INFO` と配下の `MUTABLE_INFO/*`（または `DISK_UNIT_INFO/<unit>/...`）※このとき当該Unitの `node_id_list`（またはDiskUnitの `disk_id_list`）に消し残しがないことを確認する |
| 4 | 各Gateway（存在する場合） | `OC_INFO/<vcid>/GATEWAY_INFO/<gateway_name>/INFO` |
| 5 | UnitGroup本体 | `OC_INFO/<vcid>/INFO` と配下の `MUTABLE_INFO/*`（`state`, `owner`, `unit_name_list/info`。`unit_name_list/lock` が残っていないことも確認） |
| 6 | occtrの台帳 | `OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/vc_id_list/info` の `list` から該当vcidを除去、`OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/node_id_list/info` の `list` から該当UnitGroupに属していたNode/Disk IDをすべて除去 |

> [!WARNING]
> アプリケーションコード（`datamodel/base.py` の `DatamodelBase.__delete_from_kvs`）のDELETE処理は `recurse` オプションを付けずにConsul KVSの `DELETE /v1/kv/<key>` を呼んでいるため、**指定したキーと完全一致するキー1件のみ**が削除される。  
> そのため、上表の各行で「対象キー」だけでなく、その配下の `MUTABLE_INFO/*` キー群も個別に、あるいは `?recurse` を付けて明示的に削除しないと、削除後もKVS上にデータが残り続ける（孤立キーとなる）。手動でKVSから削除する際は、必ず `consul kv delete -recurse` でキー配下をまとめて削除すること。

### コマンド例（Consul CLIを使う場合）

```bash
# 対象UnitGroupの配下すべてを一覧して内容を確認する
consul kv get -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/"

# 1. Node（Unit配下）を削除
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/UNIT_INFO/<unit_name>/NODE_INFO/<node_id>/"

# 2. Disk（DiskUnit配下、storage種別の場合)
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/DISK_UNIT_INFO/<unit_name>/DISK_INFO/<disk_id>/"

# 3. Unit / DiskUnit を削除
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/UNIT_INFO/<unit_name>/"
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/DISK_UNIT_INFO/<unit_name>/"

# 4. Gateway を削除
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/GATEWAY_INFO/<gateway_name>/"

# 5. UnitGroup本体を削除
consul kv delete -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/"

# 6. occtr台帳(vc_id_list, node_id_list)を確認・編集する
consul kv get "vcp/modules/vcpm/OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/vc_id_list/info"
consul kv get "vcp/modules/vcpm/OC_CONTROLLER_MUTABLE_INFO/<occtr_id>/node_id_list/info"
```

`vc_id_list/info` と `node_id_list/info` の値は `{"list": [...], "no": N}` というJSONであるため、対象IDを `list` から取り除いたJSONを作成し、`consul kv put` で書き戻す（`no` は通し番号なので変更しない）。この2つのキーには、書込み中のみ存在する対の `.../lock` キーがある。編集前に `consul kv get ".../lock"` で存在しないことを確認し、万一残っていた場合は他のプロセスが操作中でないことを確認したうえで削除すること。

### 削除後の確認

```bash
# 何も表示されなければ孤立キーは残っていない
consul kv get -recurse "vcp/modules/vcpm/OC_INFO/<vcid>/"
```

すべてのUnitGroupの削除操作は、対象のUnitGroupに対してVCC REST API側の操作（作成・削除・状態更新等）が同時に走っていない状態で行うこと。occtrが同じキーを操作中に手動で書き換えると、CASロック（`unit_name_list/lock` 等）の不整合や、occtr側キャッシュとの不一致が発生し得る。
