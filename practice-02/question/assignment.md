# 課題: 部署内の給与ランキング分析

## 概要

あなたは人事部門のデータアナリストです。
各部署の平均給与と、その部署内での各従業員の給与ランキングを同時に表示するレポートを作成するよう依頼されました。

## テーブル

*   `departments`
    *   `id`: 部署ID (SERIAL PRIMARY KEY)
    *   `name`: 部署名 (VARCHAR)
*   `employees`
    *   `id`: 従業員ID (SERIAL PRIMARY KEY)
    *   `name`: 従業員名 (VARCHAR)
    *   `department_id`: 部署ID (INT)
    *   `salary`: 給与 (INT)

## 期待される結果

以下のカラムを持つテーブルを返すSQLクエリを作成してください。

*   `department_name`: 部署名
*   `employee_name`: 従業員名
*   `salary`: 給与
*   `department_avg_salary`: 部署の平均給与 (小数点以下は四捨五入)
*   `salary_rank_in_department`: 部署内での給与ランキング (給与が高い順)

**期待される出力例:**

| department_name | employee_name | salary | department_avg_salary | salary_rank_in_department |
| --------------- | ------------- | ------ | --------------------- | ------------------------- |
| Engineering     | Frank         | 90000  | 81667                 | 1                         |
| Engineering     | David         | 80000  | 81667                 | 2                         |
| Engineering     | Eve           | 75000  | 81667                 | 3                         |
| HR              | Henry         | 50000  | 47500                 | 1                         |
| HR              | Grace         | 45000  | 47500                 | 2                         |
| Sales           | Bob           | 60000  | 55000                 | 1                         |
| Sales           | Charlie       | 55000  | 55000                 | 2                         |
| Sales           | Alice         | 50000  | 55000                 | 3                         |

## 要件

*   **共通テーブル式 (CTE)** を使用して、部署ごとの平均給与を計算してください。
*   **ウィンドウ関数** を使用して、部署内での給与ランキングを計算してください。
*   給与が同じ場合は、同じランクになるようにしてください (例: `RANK()` または `DENSE_RANK()`)。
*   最終的なクエリ結果を `employee_salary_analysis` という名前の**ビュー**として作成してください。

## 提出物

*   上記の要件をすべて満たすSQLクエリ (`.sql` ファイル)。
