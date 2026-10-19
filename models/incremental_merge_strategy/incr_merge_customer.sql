{{ config(
    materialized='incremental',
    unique_key='customer_id',
    incremental_strategy='merge'
) }}

WITH source_data AS (
    SELECT
        customer_id,
        customer_name,
        email,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC
        ) AS rn
    FROM {{ source('raw', 'customer') }}
)

SELECT
    customer_id,
    customer_name,
    email,
    updated_at
FROM source_data
WHERE rn = 1   -- keep only the latest record per customer_id
