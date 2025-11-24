-- KPI 2: Average order value (AOV)

WITH order_revenue AS (
    SELECT
        o.order_id,
        SUM(oi.line_total) AS order_total
    FROM orders o
    JOIN order_items oi
      ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY o.order_id
)
SELECT
    AVG(order_total) AS average_order_value
FROM order_revenue;
