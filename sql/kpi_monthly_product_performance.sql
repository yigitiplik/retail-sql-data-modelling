-- KPI 5: Monthly product performance

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.line_total) AS total_revenue
FROM orders o
JOIN order_items oi
  ON oi.order_id = o.order_id
JOIN products p
  ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY DATE_TRUNC('month', o.order_date), p.product_id, p.product_name
ORDER BY month, total_revenue DESC;
