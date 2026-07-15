{{
    config(
        materialized='table',
        transient=false,
        alias='TR_FACT_SALES'
    )
}}

select
    order_id,
    customer_id,
    product_id,
    quantity,
    amount
from {{ source('raw','sales') }}