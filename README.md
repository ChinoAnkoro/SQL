# SQL Practice for Advanced Techies

実践的な課題を通じたSQLのスキル向上を目的としています。

## zipエクスポート用スクリプトの使い方

本プロジェクトのルートで以下のコマンドを実行してください。

```sh
chmod +x batches/export_practices.sh
batches/export_practices.sh
```

- 実行後、`batches/export` ディレクトリに各practiceのzipファイルが生成されます。
  + 各practiceの`answer`ディレクトリ内の`README.md`以外のファイルは、zipファイルに不要なため空ファイル化されます。
  + `.gitignore`に記載されたディレクトリも、zipファイルに不要なため削除されます。
  + 空になった各`answer`ディレクトリ内のファイルはgitの操作で復元してください。