{{ config(
    materialized='incremental',
    unique_key='sale_id',
    incremental_strategy='append'
) }}

with employee as (
    select
        emp_id,
        emp_name,
        department
    from {{ source('raw_gold', 'employee') }}
),

sales as (
    select
        sale_id,
        emp_id,
        sale_date,
        sale_amount
    from {{ source('raw_gold', 'emp_sales') }}
)

, combined as (
    select
        s.sale_id,
        s.emp_id,
        e.emp_name,
        e.department,
        s.sale_date,
        s.sale_amount
    from sales s
    left join employee e
        on s.emp_id = e.emp_id
)

-- Deduplication logic
, deduped as (
    select *
    from (
        select
            c.*,
            row_number() over (partition by sale_id order by sale_date desc) as rn
        from combined c
    ) t
    where rn = 1
)

select *
from deduped

{% if is_incremental() %}
    -- Only bring in new sales since the last run from the source table
    where sale_date > (select max(sale_date) from {{ this }})
{% endif %}
