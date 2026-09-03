SELECT
    ss.sale_id,
    ss.sale_date,
    ss.customer_id,
    ss.product_id,
    ss.employee_id,
    ss.quantity,
    ss.amount
FROM store_sales ss
WHERE ss.employee_id IN (
    -- 2022年1月1日以降に入社した従業員を取得
    SELECT employee_id
    FROm employees
    WHERE hire_date >= '2022-01-01'
)
ORDER BY
    ss.sale_date;