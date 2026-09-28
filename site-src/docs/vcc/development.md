# 開発

## CLIコマンドドキュメントの生成

`docs/references/cli_commands.md` (`vcc` コマンド一覧) は `cli/docs/gen_docs.py` を実行することで生成する。

```
uv run python -m cli.docs.gen_docs
```

## コンテナイメージスキャン

- 脆弱性＆secrets混入チェック  

    修正可能なもののみをリストアップ、html出力  

    ```
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/reports:/reports aquasec/trivy image --format template --template "@/contrib/html.tpl" -o /reports/report.html --ignore-unfixed --docker-host unix:///var/run/docker.sock --image-src docker harbor.vcloud.nii.ac.jp/vcp/occtr:26.10.0-rcdev-cli
    ```

    > [!NOTE]
    > タグを開発中のものに変更すること。