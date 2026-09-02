WITH all_sales AS (
    -- 店舗売り上げとオンライン売り上げを結合
    SELECT
        customer_id,
        amount
    FROM store_sales

    UNION ALL

    SELECT
        customer_id,
        amount
    FROM online_sales
)

SELECT
    c.prefecture,
    SUM(a.amount) AS total_sales_amount
FROM all_sales a
-- 顧客情報を結合
JOIN customers c
    ON a.customer_id = c.customer_id
GROUP BY c.prefecture
ORDER BY total_sales_amount DESC;