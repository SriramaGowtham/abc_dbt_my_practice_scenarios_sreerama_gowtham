{{
    config(
        alias = 'v_stg_customers_view'
    )
}}

select * from {{ ref('stg_customers') }}