{% snapshot customers_snapshot_timestamp_strategy %}

{{
    config(
        target_database='SNOWFLAKE_DBT',
        target_schema='sf_dbt',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=True
    )
}}

select
    customer_id,
    customer_name,
    email,
    phone,
    address,
    updated_at
from {{ ref('stg_customers') }}

{% endsnapshot %}