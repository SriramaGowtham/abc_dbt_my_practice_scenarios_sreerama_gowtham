{{
    config(
        materialized='table',
        transient = false
    )
}}

select
    customer_id,
    customer_name,
    email,
    phone,
    address,
    updated_at
from {{ source('raw', 'customers') }}