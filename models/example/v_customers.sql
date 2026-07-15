{{
    config(
        materialized='view',
        alias='VW_CUSTOMERS'
    )
}}

select
    customer_id,
    customer_name,
    email,
    phone
from {{ ref('stg_customers') }}