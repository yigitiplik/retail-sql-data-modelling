-- KPI 3: Repeat purchase rate

WITH customer_order_counts AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    WHERE o.order_status = 'completed'
    GROUP BY o.customer_id
)
SELECT
    COUNT(*) FILTER (WHERE order_count > 1)::DECIMAL
    / NULLIF(COUNT(*), 0) AS repeat_purchase_rate
FROM customer_order_counts;
