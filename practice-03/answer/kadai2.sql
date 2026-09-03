SELECT
    c.customer_id,
    c.customer_name
FROM customers c

-- 店舗売り上げを顧客IDで結合
LEFT JOIN store_sales ss
    ON c.customer_id = ss.customer_id

-- オンライン売り上げを顧客IDで結合
LEFT JOIN online_sales os
    ON c.customer_id = os.customer_id

-- どららのうりがげにも存在しない顧客を取得
WHERE ss.customer_id IS NULL
    AND os.customer_id IS NULL;