{{
    config(
        materialized='view',
        secure = true,
        alias = 'vw_ecommerce_orders'
    )
}}

select * from {{ source('raw', 'ecommerce_orders') }}