SELECT
    CASE
        WHEN amount >= 10000 THEN 'High'
        WHEN amount >= 5000 THEN 'Medium'
        ELSE 'Low'
    END AS sales_category,

    COUNT(*) AS sales_count
FROM (
    -- 店舗売り上げ
    SELECT amount
    FROM store_sales

    UNION ALL

    -- オンライン売り上げ
    SELECT amount
    FROM online_sales
) AS all_sales
GROUP BY
    CASE
        WHEN amount >= 10000 THEN 'High'
        WHEN amount >= 5000 THEN 'Medium'
        ELSE 'Low'
    END
ORDER BY
    sales_category