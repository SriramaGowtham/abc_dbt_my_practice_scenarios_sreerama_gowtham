{{
    config(
        materialized='table',
        alias='DIM_CUSTOMERS'
    )
}}

select
    customer_id,
    customer_name,
    email,
    phone,
    current_timestamp() as etl_load_date
from {{ ref('stg_customers') }}