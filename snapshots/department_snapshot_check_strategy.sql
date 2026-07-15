{% snapshot department_snapshot_check_strategy %}

{{
    config(
        target_database='SNOWFLAKE_DBT',
        target_schema='sf_dbt',
        unique_key='department_id',
        strategy='check',
        check_cols=[
            'department_name',
            'department_head',
            'location',
            'budget',
            'status'
        ],
        invalidate_hard_deletes=True
    )
}}

select
    department_id,
    department_name,
    department_head,
    location,
    budget,
    status,
    created_date,
    updated_at
from {{ source('raw','department') }}

{% endsnapshot %}
