{{
    config(
        schema = 'silver',
        alias = 'v_first_view'
    )
}}

select * from {{ ref('stg_customers') }}