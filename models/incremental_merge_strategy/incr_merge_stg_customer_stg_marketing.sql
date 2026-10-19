{{ config(
    materialized='incremental',
    unique_key=['customer_id','campaign_id'],
    incremental_strategy='merge'
) }}

WITH dedup_customer AS (
    SELECT
        customer_id,
        customer_name,
        email,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC
        ) AS rn
    FROM {{ source('raw', 'stg_customer') }}
),
dedup_marketing AS (
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
    FROM {{ source('raw', 'stg_marketing') }}
),
joined AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.email,
        m.campaign_id,
        m.campaign_name,
        m.start_date,
        m.end_date,
        GREATEST(c.updated_at, m.updated_at) AS updated_at
    FROM dedup_customer c
    JOIN dedup_marketing m
      ON c.customer_id = (m.campaign_id % 3 + 1)
    WHERE c.rn = 1
      AND m.rn = 1
)

SELECT
    customer_id,
    customer_name,
    email,
    campaign_id,
    campaign_name,
    start_date,
    end_date,
    updated_at
FROM joined