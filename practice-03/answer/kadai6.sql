SELECT
    p.category,
    p.product_id,
    p.product_name,
    COALESCE(s.total_sales, 0) AS total_sales,

    -- カテゴリごとに売り上げランキング
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY COALESCE(s.total_sales, 0) DESC
    ) AS sales_rank

FROM products p

-- 商品ごとの売り上げを結合
LEFT JOIN (
    SELECT
        product_id,
        SUM(amount) AS total_sales
    FROM (
        -- 店舗売り上げ
        SELECT
            product_id,
            amount
        FROM store_sales

        UNION ALL

        -- オンライン売り上げ
        SELECT
            product_id,
            amount
        FROM online_sales
    ) AS all_sales
    GROUP BY product_id
) s
    ON p.product_id = s.product_id
ORDER BY
    p.category,
    sales_rank;