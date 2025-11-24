-- KPI 6: Top customers by revenue

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.external_customer_id,
        c.country,
        SUM(oi.line_total) AS total_revenue
    FROM customers c
    JOIN orders o
      ON o.customer_id = c.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY c.customer_id, c.external_customer_id, c.country
)
SELECT
    customer_id,
    external_customer_id,
    country,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank
LIMIT 20;
