-- KPI 4: Revenue by country

SELECT
    o.country,
    SUM(oi.line_total) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COUNT(DISTINCT o.customer_id) AS customers_count
FROM orders o
JOIN order_items oi
  ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY o.country
ORDER BY total_revenue DESC;
