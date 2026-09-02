WITH gender_sales AS (
    -- カテゴリ・性別ごとの購入金額を集計
    SELECT
        p.category,
        c.gender,
        SUM(a.amount) AS total_purchase_amount

        FROM(
            -- 店舗売り上げ
            SELECT
                customer_id,
                product_id,
                amount
            FROM store_sales

            UNION ALL

            -- オンライン売り上げ
            SELECT
                customer_id,
                product_id,
                amount
            FROM online_sales
        ) a

        -- 商品情報を結合
        JOIN products p
            ON a.product_id = p.product_id
        -- 顧客情報を結合
        JOIN customers c
            ON a.customer_id = c.customer_id
        GROUP BY
            p.category,
            c.gender
        ), 

        ranked_sales AS (
            -- カテゴリごとに購入金額をランキング
            SELECT
                category,
                gender,
                total_purchase_amount,

                RANK() OVER (
                    PARTITION BY category
                    ORDER BY total_purchase_amount DESC
                ) AS sales_rank
                FROM gender_sales
        )

        SELECT
            category,
            gender,
            total_purchase_amount
        FROM ranked_sales
        WHERE sales_rank = 1
        ORDER BY category;