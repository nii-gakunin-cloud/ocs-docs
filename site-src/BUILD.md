# ドキュメントのビルド方法

このディレクトリは [Zensical](https://zensical.org/) のプロジェクトです。設定ファイルは
`mkdocs.yml` で、MkDocs 互換の形式です。

## 準備

```
pip install zensical
```

## ローカルでの確認

```
zensical serve
```

`http://127.0.0.1:8000` でプレビューできます。ファイルを保存すると自動的に再読み込みされます。

## HTML の生成

```
zensical build
```

`site/` ディレクトリに HTML 一式が出力されます。

## 関係者への配布

`site/` をそのまま zip に固めて渡してください。受け取った側は展開して `site/index.html` を
ブラウザで開くだけで閲覧できます。Web サーバは不要です。

これは `mkdocs.yml` の `use_directory_urls: false` によるものです。この設定を外すと
リンクが `concepts/` 形式になり、ファイルを直接開いた場合に機能しなくなります。

## 構成

```
.
├── mkdocs.yml              設定ファイル (目次・テーマ・拡張機能)
├── docs/                   ドキュメント本体 (サイトになる部分)
│   ├── README.md           トップページ
│   ├── concepts/           ┐
│   ├── getting-started/    │
│   ├── tutorials/          │
│   ├── operations/         ├ 将来 ocs-docs リポジトリへ
│   ├── sdk/                │
│   ├── specs/              │
│   ├── templates/          │
│   ├── support/            ┘
│   ├── vcc/                将来 vcc リポジトリへ
│   ├── basecontainer/      将来 basecontainer リポジトリへ
│   └── vcpcli/             将来 vcpcli リポジトリへ
├── basecontainer-README.md 分割時に basecontainer リポジトリ直下へ置くファイル
└── vcpcli-README.md        分割時に vcpcli リポジトリ直下へ置くファイル
```

`docs/` 配下は、将来分割するリポジトリごとにディレクトリを分けています。分割時は該当
ディレクトリを各リポジトリの `docs/` へ移動し、`mkdocs.yml` の `nav` から該当項目を
削除して、コンポーネントをまたぐリンクを各サイトの URL に差し替えます。

`basecontainer-README.md` と `vcpcli-README.md` は、GitHub でリポジトリを開いたときに
表示される入口ページです。サイトには含まれないため `docs/` の外に置いています。

## 記述上のルール

このドキュメントは以下の 3 通りの方法で読まれます。どの方法でも問題なく読めるように、
下記のルールを守ってください。

1. ビルドしたサイト (`zensical serve` / GitHub Pages)
2. zip で配布した `site/` をブラウザで直接開く
3. markdown ファイルをエディタや GitHub 上で直接読む

### リンク

相対パスで `.md` の拡張子まで書いてください。

```
[コンセプト](../concepts/README.md)   ○
[インストール](/installation)          × 絶対パス。3 で壊れ、GitHub Pages の
                                         サブパス配信でも壊れる
[インストール](installation)           × 拡張子がない。3 で壊れる
```

相対 `.md` リンクはビルド時に HTML へ変換されるため、1 と 2 でも正しく機能します。

### 記法

MkDocs 固有の記法は、3 のときにそのまま文字として表示されてしまいます。標準的な
markdown で書いてください。

```
> **注意**                            ○ どの環境でも引用として表示される
!!! note                              × ビルドしないと注記にならない
# 見出し { #anchor }                   △ 3 のとき見出しに文字列が見える
```

見出しへのアンカー指定は、他のページから参照されている場合のみ残してください。

### 画像

`docs/` 配下に置き、相対パスで参照してください。

## 補足

- 各ディレクトリのインデックスは `README.md` または `index.md` です。どちらでも動作します。
- Zensical は既定で `docs/templates/` を除外します (テーマ用に予約されているため)。
  アプリケーションテンプレートの節でこの名前を使用しているため、`mkdocs.yml` の
  `exclude_docs` で否定パターンを指定して再度対象に含めています。
- GitHub Pages で公開する際は、`mkdocs.yml` に `site_url` を設定してください。設定が
  ないと 404 ページのスタイルがサブパス配信で崩れます。
