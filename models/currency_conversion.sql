{{
    config(
        materialized='table',
        transient = false
    )
}}

select
    order_id,
    customer_id,
    {{ cents_to_dollars('raw_order_amount_cents') }} as net_order_amount,
    {{ cents_to_dollars('raw_shipping_cost_cents') }} as shipping_cost,
    {{ safe_divide('net_profit_cents', 'raw_order_amount_cents', 0) }} as profit_margin
from {{ ref('stg_ecommerce_orders') }}