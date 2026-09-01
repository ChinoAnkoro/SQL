#!/bin/bash

# FIXME: 空にしたanswerディレクトリ内のファイルの復元を織り込んでおらず、gitの操作による復元に頼ってしまっている
# TODO: answersディレクトリのzip化のスクリプトを別途準備する？
# 1. 各practiceのanswer内でREADME.md以外のファイルの中身を空にする
for practice in practice-*; do
  if [ -d "$practice/answer" ]; then
    find "$practice/answer" -type f ! -name "README.md" -exec sh -c '> "$1"' _ {} \;
  fi
done

# 2. .gitignoreに記載されているフォルダを削除
if [ -f .gitignore ]; then
  grep '/$' .gitignore | while read dir; do
    dir=${dir%/}
    [ -d "$dir" ] && rm -rf "$dir"
  done
fi

# 3. exportディレクトリ作成
mkdir -p batches/export

# 4. 各practiceディレクトリをzip化してexportに出力
for practice in practice-*; do
  if [ -d "$practice" ]; then
    zip -r "batches/export/${practice}.zip" "$practice"
  fi
done

echo "Export completed."
