# アプリケーションテンプレート

アプリケーションテンプレートは、VCP 上に特定のアプリケーション環境を構築するための手順を
Jupyter Notebook として記述したものです。テンプレートを順に実行することで、計算資源の確保から
アプリケーションのインストール・設定までを行えます。

テンプレートは [ocs-templates](https://github.com/nii-gakunin-cloud/ocs-templates) リポジトリで
公開されています (Apache-2.0 ライセンス)。

---

## 用途から選ぶ

| やりたいこと | テンプレート |
|---|---|
| Jupyter Notebook を使った講義・演習を行いたい | [講義演習環境 (CoursewareHub)](#coursewarehub) / [MCJ-CloudHub](#mcj-cloudhub) |
| Moodle で学習管理システムを立てたい | [LMS (Moodle)](#moodle) |
| HPC クラスタを構築したい | [HPC (OpenHPC)](#openhpc) |
| HPC クラスタをブラウザから使えるようにしたい | [Open OnDemand](#open-ondemand) |
| 構築した環境の利用状況を分析したい | [ログ解析](#log-analysis) |

---

## 共通の前提

テンプレートを実行するには、**VCP 環境が構築済みで、Notebook 環境が利用できる状態**である
必要があります。まだの場合は[はじめる](../getting-started/README.md)を参照してください。

テンプレートには **VCP SDK の対応バージョン**が記載されています。構築済みの環境のバージョンと
合わない場合、そのままでは動作しないことがあります。

**動作確認済みのクラウドプロバイダ**もテンプレートごとに異なります。記載のないプロバイダで
利用する場合は、インスタンスの指定などを環境に合わせて調整してください。

---

## 教育・学習環境

Jupyter Notebook を用いた講義・演習環境には、CoursewareHub と MCJ-CloudHub の 2 つのテンプレートが
あります。いずれも JupyterHub を基盤とし、教材の配布や課題の回収、操作履歴の収集といった講義に必要な
機能を備えています。MCJ-CloudHub は、これらに加えて nbgrader による課題の採点を特徴としています。
用途に応じて選択してください。

### 講義演習環境 (CoursewareHub) { #coursewarehub }

Jupyter Notebook を用いた講義演習環境を構築します。基盤には JupyterHub v3.x を講義演習用に
拡張した [CoursewareHub](https://coursewarehub.github.io/) を使用し、教材配布、課題の回答収集、
操作履歴の収集といった機能が利用できます。

- テンプレート: [CoursewareHub](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/CoursewareHub)
- VCP SDK v25.04 以降対応 (AWS、Azure、mdx で動作確認済み)
- 構築・運用で問題が起きた場合は [FAQ](../support/README.md) を参照してください

### MCJ-CloudHub { #mcj-cloudhub }

複数の科目で共同・同時に利用できる Web 型プログラミング演習システムです。演習環境に JupyterHub、
課題の配布・回収・採点に nbgrader を採用し、複数科目での同時利用に対応するための改修を
加えています。

- テンプレート: [mcj-cloudhub](https://github.com/nii-gakunin-cloud/mcj-cloudhub) (別リポジトリ)

### LMS (Moodle) { #moodle }

[Moodle](https://moodle.org/) を用いた学習管理システムを構築します。手動アカウントまたは LDAP 連携に
よる短期的な利用を想定した、機能を絞った構成です。Shibboleth 等の SSO 連携や長期利用のための
アップデートについては、この構成を元に各機関の事情に合わせてカスタマイズすることを想定しています。

VCP を利用せず、AWS または Azure に直接構築する手順も合わせて公開されています。

- テンプレート: [Moodle-Simple](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/Moodle-Simple)
- VCP SDK v25.04 以降対応 (AWS、Azure で動作確認済み)

---

## HPC 環境

### HPC (OpenHPC) { #openhpc }

[OpenHPC](https://openhpc.community/) のパッケージを利用して、クラウド上に HPC 環境を構築します。
Slurm によるジョブスケジューラ、Singularity コンテナ利用環境、GPU ノードの設定に加え、
ベンチマークプログラムの実行や NVIDIA NGC カタログのコンテナ実行まで行えます。

v2 と v3 があります。**新規に構築する場合は v3 を選んでください。**v2 は対応プロバイダが
多いため、mdx や Oracle Cloud Infrastructure を利用する場合の選択肢になります。

| | 対応 SDK | 動作確認済みプロバイダ | ベースコンテナ |
|---|---|---|---|
| [HPC テンプレート v3](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/OpenHPC-v3) | v25.04 以降 | AWS、Azure | Rocky Linux v9.x |
| [HPC テンプレート v2](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/OpenHPC-v2) | v22.04 | AWS、Azure、Oracle Cloud Infrastructure、mdx | Rocky Linux v8.x |

### Open OnDemand { #open-ondemand }

HPC テンプレート v2 で構築した OpenHPC 環境の上に、[Open OnDemand](https://openondemand.org/) 環境を
構築します。ブラウザから HPC クラスタを利用できるようになります。

- テンプレート: [OpenOnDemand](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/OpenOnDemand)
- VCP SDK v22.04 以降対応 (mdx で動作確認済み)

## ログ解析 { #log-analysis }

各テンプレートで構築した環境から出力されるログを収集・解析・可視化します。システムの利用状況や
操作履歴の分析を通じて、運用状況の把握や学習活動の可視化を支援します。現在は CoursewareHub の
Notebook 実行ログに対応しています。

- テンプレート: [LogAnalysis](https://github.com/nii-gakunin-cloud/ocs-templates/tree/master/LogAnalysis)
- VCP SDK v25.04 対応

---

## 変更履歴

各テンプレートの更新内容は
[CHANGELOG](https://github.com/nii-gakunin-cloud/ocs-templates/blob/master/CHANGELOG.md) で
公開されています。
