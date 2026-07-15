-- models/sales_summary.sql
{{ config(
        materialized='materialized_view',
        alias='MV_SALES')
}}

SELECT
    customer_id,
    SUM(amount) AS total_amount,
    COUNT(order_id) AS total_orders
FROM {{ source('raw','sales') }}
GROUP BY customer_id
