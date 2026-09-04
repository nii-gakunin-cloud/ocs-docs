# チュートリアル

[はじめる](../getting-started/README.md)で扱わなかった使い方を学ぶための資料です。

このページは資料への索引です。手順の本体は、それぞれのリンク先にあります。

---

## 自習用資料

各手順を実行した様子を収録した資料です。**Jupyter Notebook の実行環境がなくても読める**ため、
実際に構築する前に流れを把握したい場合にも利用できます。

- [101 VC ノードの起動、削除](http://tutorials.vcp-handson.org/101.html)
- [201 GPU インスタンスの利用](http://tutorials.vcp-handson.org/201.html)

101 は、[はじめる](../getting-started/first-node.md)で扱う VC ノードの起動と削除に加えて、複数のクラウド
プロバイダにまたがる利用など、より広い範囲を扱っています。使用している Notebook は現行のものと異なりますが、
実行の様子を動画で確認できます。

---

## ハンズオンセミナーの教材

ハンズオンセミナーで使用した教材が
[handson](https://github.com/nii-gakunin-cloud/handson) リポジトリで公開されています。
内容ごとに整理すると以下のとおりです。同じ内容で複数回開催されたものは、最新の回の教材を
挙げています。

> **注意**
>
> これらの教材は、**セミナーで用意された環境で実行することを前提に作成されています。**
> そのままでは自分の環境で動作しません。実行する前に、接続先や認証情報、使用するクラウド
> プロバイダとインスタンスの指定などを、自分の環境に合わせて書き換えてください。
>
> また、教材は開催当時の内容のまま保存されています。

### VCP の基礎

VC ノードの起動と削除、GPU 環境の構築、スポットインスタンスの利用など、VCP の基本操作を
扱います。

| 教材 | 開催 | 備考 |
|---|---|---|
| [handson202402-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202402-vcp) | 2024年2月 | 最新の基礎編 |
| [handson202305-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202305-vcp) | 2023年5月・8月・12月 | |
| [handson202303-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202303-vcp) | 2023年3月 | |
| [handson202107-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202107-vcp) | 2021年7月・9月・12月 | GPU 利用、スポットインスタンスを含む |

### VCP ポータブル版の構築

VC コントローラを自前の環境に構築する演習です。現行の手順は
[はじめる](../getting-started/setup.md)を参照してください。

| 教材 | 開催 | 対象 |
|---|---|---|
| [handson202212-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202212-vcp) | 2022年12月 | さくらのクラウド |
| [handson202209-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202209-vcp) | 2022年9月 | mdx |

### 講義・演習環境

| 教材 | 開催 | 対象 |
|---|---|---|
| [MCJ-CloudHub 演習 (2025年9月)](https://github.com/nii-gakunin-cloud/handson/blob/master/examples/MCJ-0902/01-auto.ipynb) | 2025年9月 | MCJ-CloudHub |
| [MCJ-CloudHub 演習 (2025年4月)](https://github.com/nii-gakunin-cloud/handson/blob/master/examples/MCJ-0423/assign01.ipynb) | 2025年4月 | MCJ-CloudHub |
| [handson202501-mcjcloudhub](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson202501-mcjcloudhub) | 2025年1月 | MCJ-CloudHub の構築 |
| [20240828](https://github.com/nii-gakunin-cloud/handson/blob/master/ipynb/20240828/01-basic.ipynb) | 2024年8月 | MCJ-CloudHub |
| [handson202206-vcp](https://github.com/nii-gakunin-cloud/handson/blob/master/Basic-Tutorials/handson202206-vcp) | 2022年6月 | 軽量 Python 実習環境 (JupyterHub) |
| [handson201902-guacamole](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson201902-guacamole) | 2019年2月 | Guacamole による計算機実習環境 |

### HPC 環境

| 教材 | 開催 | 対象 |
|---|---|---|
| [handson202503-openondemand](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson202503-openondemand) | 2025年3月 | Open OnDemand |
| [handson202409-openondemand](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson202409-openondemand) | 2024年9月 | OpenHPC + Open OnDemand |
| [handson202109-openhpc](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson202109-openhpc) | 2021年9月 | OpenHPC-v2 での手書き数字認識 |

### その他のアプリケーション

| 教材 | 開催 | 対象 |
|---|---|---|
| [of2018-vcp-moodle](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/of2018-vcp-moodle) | 2018年6月 | Moodle |
| [handson2017-galaxy](https://github.com/nii-gakunin-cloud/handson/blob/master/Application-Tutorials/handson2017-galaxy) | 2017年12月 | Galaxy |

### 講演資料

各回の講演資料 (PDF) や、上記に含まれない教材については
[handson リポジトリの README](https://github.com/nii-gakunin-cloud/handson) を参照してください。
開催回ごとに一覧されています。

---

## その他の使い方

| 調べたいこと | 参照先 |
|---|---|
| 特定のアプリケーション環境を構築する | [アプリケーションテンプレート](../templates/README.md) |
| 複数のクラウドプロバイダやストレージの指定方法 | [SDK リファレンス](../sdk/README.md) |
| 構築した環境の運用 | [運用ガイド](../operations/README.md) |
