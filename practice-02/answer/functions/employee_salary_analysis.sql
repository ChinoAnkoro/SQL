-- ビューを作成
CREATE VIEW employee_salary_analysis AS

--CTEを使用して、部署ごとの平均給与を計算
WITH department_avg AS (
    SELECT
        -- 部署ID
        department_id,
        -- 部署ごとの平均給与を計算
        ROUND(AVG(salary)) AS department_avg_salary
    -- employeesテーブルからデータを取得
    FROM employees
    -- 部署ごとにグループ化して平均給与を計算
    GROUP BY department_id
)

-- 取得する項目を指定
SELECT
    -- 部署名
    d.name AS department_name,
    -- 従業員名
    e.name AS employee_name,
    -- 従業員の給与
    e.salary,
    --所属部署の平均給与
    da.department_avg_salary,
    -- 部署内での給与ランキング
    RANK() OVER (
        -- 部署ごとにランキングを分ける
        PARTITION BY e.department_id
        -- 給与の高い順にランキングを付ける
        ORDER BY e.salary DESC
    -- ランキングのカラム名
    ) AS salary_rank_in_department

-- employeesテーブルを基準にする
FROM employees e
-- departmentsテーブルを結合して部署名を取得
JOIN departments d
    ON e.department_id = d.id
-- CTEで作成した部署ごとの平均給与を結合
JOIN department_avg da
    ON e.department_id = da.department_id;