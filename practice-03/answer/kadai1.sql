SELECT
    -- 全体の売上額を合計
    SUM(amount) AS total_sales_amount,

    -- 全体の販売数量を合計
    SUM(quantity) AS total_quantity
FROM (
    -- 店舗売上を取得
    SELECT
        amount,
        quantity
    FROM store_sales

    UNION ALL

    SELECT
        amount,
        quantity
    FROM online_sales
) AS all_sales;