# 開発

## CLIコマンドドキュメントの生成

`docs/references/cli_commands.md` (`vcc` コマンド一覧) は手書きではなく、`cli/commands/`
配下のコマンド定義(`Command` サブクラスの `DESCRIPTION`/`add_arguments`、サブコマンドを
持つモジュールの `COMMANDS` 辞書)から `cli/docs/gen_docs.py` が自動生成する。

```
uv run python -m cli.docs.gen_docs
```

`zensical build` でドキュメントサイトをビルドする前に実行し、生成された
`docs/references/cli_commands.md` の差分をコミットする。

## コンテナイメージスキャン

- 脆弱性＆secrets混入  

    修正可能なもののみをリストアップ、html出力  

    ```
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/reports:/reports aquasec/trivy image --format template --template "@/contrib/html.tpl" -o /reports/report.html --ignore-unfixed --docker-host unix:///var/run/docker.sock --image-src docker harbor.vcloud.nii.ac.jp/vcp/occtr:26.10.0-rcdev-cli
    ```
