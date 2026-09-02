SELECT
    s.store_name,
    ss.sale_date,
    -- その日の売上額
    SUM(ss.amount) AS daily_sales_amount,

    -- 店舗ごとの累積売り上げ
    SUM(SUM(ss.amount)) OVER (
        PARTITION BY ss.store_id
        ORDER BY ss.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_Sales

FROM store_sales ss
JOIN stores s
    ON ss.store_id = s.store_id
GROUP BY
    ss.store_id,
    s.store_name,
    ss.sale_date
ORDER BY
    s.store_name,
    ss.sale_date;