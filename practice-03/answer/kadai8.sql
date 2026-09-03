SELECT
    c.customer_name,
    s.total_sales_amount
FROM customers c
-- 顧客ごとの売上額を集計
JOIN (
    SELECT
        customer_id,
        SUM(amount) AS total_sales_amount
    FROM(
        -- 店舗売り上げ
        SELECT
            customer_id,
            amount
        FROM store_sales

        UNION ALL

        -- オンライン売り上げ
        SELECT
            customer_id,
            amount
        FROM online_sales
    ) AS all_sales
    GROUP BY customer_id
) s
    ON c.customer_id = s.customer_id
ORDER BY s.total_sales_amount DESC
LIMIT 1;