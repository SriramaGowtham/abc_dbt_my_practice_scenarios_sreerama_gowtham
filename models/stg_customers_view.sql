{{
    config(
        alias = 'vw_stg_customers'
    )
}}

select * from {{ ref('stg_customers') }}