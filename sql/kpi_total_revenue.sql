-- KPI 1: Total revenue

SELECT
    SUM(oi.line_total) AS total_revenue
FROM order_items oi
JOIN orders o
  ON o.order_id = oi.order_id
WHERE o.order_status = 'completed';


