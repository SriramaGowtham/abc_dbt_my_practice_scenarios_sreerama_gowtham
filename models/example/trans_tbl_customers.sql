{{
    config(
        materialized='table',
        alias='TRANS_TABLE_CUSTOMERS',
        transient=true
    )
}}

select
    customer_id,
    customer_name,
    email,
    phone,
    current_timestamp() as etl_load_date
from {{ ref('stg_customers') }}