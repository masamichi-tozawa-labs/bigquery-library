#!/bin/bash
set -e

# .env 読み込み
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env ファイルが見つかりません"
  exit 1
fi

# SQL ベースディレクトリ
SQL_BASE_DIR="table_functions"

# 引数チェック
if [ $# -eq 0 ]; then
  echo "実行する SQL ファイルを指定してください"
  exit 1
fi

SQL_FILE="$1"
SQL_PATH="$SQL_BASE_DIR"

# SQL ファイルの存在確認
if [ -f "$SQL_BASE_DIR/$SQL_FILE" ]; then
  SQL_PATH="$SQL_BASE_DIR/$SQL_FILE"
else
  # サブフォルダ（dataset）内を検索
  SQL_PATH=$(find "$SQL_BASE_DIR" -type f -name "$SQL_FILE" | head -n 1)
  if [ ! -f "$SQL_PATH" ]; then
    echo "$SQL_FILE が見つかりません"
    exit 1
  fi
fi

# dataset は SQL ファイルの親フォルダ名
DATASET=$(basename $(dirname "$SQL_PATH"))

echo "Running $SQL_FILE on dataset $DATASET..."

# SQL 読み込み + Bash 変数展開で置換
SQL_CONTENT=$(<"$SQL_PATH")
SQL_CONTENT="${SQL_CONTENT//\$\{BQ_PROJECT\}/$GCP_PROJECT}"
SQL_CONTENT="${SQL_CONTENT//\$\{BQ_DATASET\}/$DATASET}"

# BigQuery に実行
echo "$SQL_CONTENT" | bq query --nouse_legacy_sql --project_id="$GCP_PROJECT"

echo "Done."
