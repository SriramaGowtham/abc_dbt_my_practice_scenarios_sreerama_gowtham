{{
    config(
        materialized='table',
        transient = false
    )
}}

select CUSTOMER_ID, 
    CUSTOMER_NAME,
    CIBIL_SCORE,
    {{cibil_score_mco('CIBIL_SCORE')}} CIBIL_CATEGORY
from {{ source('raw', 'CUSTOMERS_CIBIL_SCORE') }}