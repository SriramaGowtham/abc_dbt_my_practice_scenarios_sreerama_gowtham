{{
    config(
        materialized='incremental',
        unique_key='vehicle_id',
        incremental_strategy='delete+insert'
    )
}}


-- ============================================================
-- STEP 1
-- DEDUPLICATE VEHICLES
--
-- Keep the latest version of every VEHICLE_ID.
-- ============================================================

WITH vehicles_deduplicated AS (
    SELECT
        VEHICLE_ID,
        COMPANY_ID,
        VEHICLE_NAME,
        MODEL_YEAR,
        VEHICLE_TYPE,
        PRICE,
        STATUS,
        UPDATED_AT
    FROM (
        SELECT
            V.*,
            ROW_NUMBER() OVER (
                PARTITION BY VEHICLE_ID
                ORDER BY UPDATED_AT DESC
            ) AS RN
        FROM {{ source('raw', 'VEHICLES') }} V
    )
    WHERE RN = 1
),
-- ============================================================
-- STEP 2
-- DEDUPLICATE MANUFACTURING COMPANIES
--
-- Keep the latest version of every COMPANY_ID.
-- ============================================================
companies_deduplicated AS (
    SELECT
        COMPANY_ID,
        COMPANY_NAME,
        COUNTRY,
        HEADQUARTERS,
        UPDATED_AT
    FROM (
        SELECT
            M.*,
            ROW_NUMBER() OVER (
                PARTITION BY COMPANY_ID
                ORDER BY UPDATED_AT DESC
            ) AS RN
        FROM {{ source('raw', 'MANUFACTURING_COMPANIES') }} M
    )
    WHERE RN = 1
)

{% if is_incremental() %}
,
-- ============================================================
-- STEP 3
-- IDENTIFY AFFECTED VEHICLE IDs
--
-- A vehicle is affected when:
--
--   1. It is a brand-new VEHICLE_ID
--   2. The vehicle itself was updated
--   3. Its manufacturing company was updated
--
-- A LOOKBACK WINDOW is used to protect against
-- late-arriving source records.
-- ============================================================

changed_vehicle_ids AS (

    SELECT
        V.VEHICLE_ID
    FROM vehicles_deduplicated V
    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} T
        WHERE T.VEHICLE_ID = V.VEHICLE_ID

    )

    UNION

    -- ======================================================== 
    -- CASE 2 
    -- EXISTING VEHICLE CHANGED 
    -- -- Compare source UPDATED_AT against the target watermark. 
    -- -- Example: -- -- Target MAX timestamp = 2026-08-01 11:00 
    -- -- 2-hour lookback: -- 2026-08-01 09:00 
    -- -- Any source vehicle updated after that point is processed. 
    -- ======================================================== 
    SELECT V.VEHICLE_ID FROM vehicles_deduplicated V 
    WHERE V.UPDATED_AT >= ( SELECT DATEADD( hour, -{{ var('incremental_lookback_hours', 2) }}, COALESCE( MAX(VEHICLE_UPDATED_AT), '1900-01-01'::TIMESTAMP_NTZ ) ) 
    FROM {{ this }} ) 
    UNION 
    -- ======================================================== 
    -- CASE 3 
    -- MANUFACTURING COMPANY CHANGED 
    -- -- If company 101 changes, find ALL vehicles belonging -- to company 101. 
    -- ======================================================== 
    SELECT V.VEHICLE_ID FROM vehicles_deduplicated V 
    INNER JOIN 
    companies_deduplicated M 
    ON V.COMPANY_ID = M.COMPANY_ID 
    WHERE M.UPDATED_AT >= ( SELECT DATEADD( hour, -{{ var('incremental_lookback_hours', 2) }}, COALESCE( MAX(COMPANY_UPDATED_AT), '1900-01-01'::TIMESTAMP_NTZ ) ) 
    FROM {{ this }} )

)

{% endif %}
,

-- ============================================================
-- STEP 4
-- JOIN VEHICLES + MANUFACTURING COMPANIES
--
-- Full load:
--     All vehicles are processed.
--
-- Incremental:
--     Only affected VEHICLE_IDs are processed.
-- ============================================================

final_data AS (
    SELECT
        -- ========================================================
        -- VEHICLE COLUMNS
        -- ========================================================
        V.VEHICLE_ID,
        V.VEHICLE_NAME,
        V.MODEL_YEAR,
        V.VEHICLE_TYPE,
        V.PRICE,
        V.STATUS,
        -- ========================================================
        -- MANUFACTURING COMPANY COLUMNS
        -- ========================================================
        M.COMPANY_ID,
        M.COMPANY_NAME,
        M.COUNTRY AS COMPANY_COUNTRY,
        M.HEADQUARTERS AS COMPANY_HEADQUARTERS,
        -- ========================================================
        -- SOURCE AUDIT COLUMNS
        -- ========================================================
        V.UPDATED_AT AS VEHICLE_UPDATED_AT,
        M.UPDATED_AT AS COMPANY_UPDATED_AT,
        -- ========================================================
        -- DBT AUDIT COLUMN
        -- ========================================================
        CURRENT_TIMESTAMP() AS DBT_UPDATED_AT
    FROM vehicles_deduplicated V
    INNER JOIN companies_deduplicated M
        ON V.COMPANY_ID = M.COMPANY_ID
    {% if is_incremental() %}
    WHERE EXISTS (
        SELECT 1
        FROM changed_vehicle_ids C
        WHERE C.VEHICLE_ID = V.VEHICLE_ID
    )
    {% endif %}
)

-- ============================================================
-- STEP 5
-- FINAL OUTPUT
-- ============================================================

SELECT
    VEHICLE_ID,
    VEHICLE_NAME,
    MODEL_YEAR,
    VEHICLE_TYPE,
    PRICE,
    STATUS,
    COMPANY_ID,
    COMPANY_NAME,
    COMPANY_COUNTRY,
    COMPANY_HEADQUARTERS,
    VEHICLE_UPDATED_AT,
    COMPANY_UPDATED_AT,
    DBT_UPDATED_AT
FROM final_data

