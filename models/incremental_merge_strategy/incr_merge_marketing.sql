{{ config(
    materialized='incremental',
    unique_key='campaign_id',
    incremental_strategy='merge'
) }}

WITH source_data AS (
    SELECT
        campaign_id,
        campaign_name,
        start_date,
        end_date,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY campaign_id
            ORDER BY updated_at DESC
        ) AS rn
    FROM {{ source('raw', 'marketing') }}
)

SELECT
    campaign_id,
    campaign_name,
    start_date,
    end_date,
    updated_at
FROM source_data
WHERE rn = 1   -- keep only the latest record per campaign_id