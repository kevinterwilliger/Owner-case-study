{{
    config(
        materialized = 'table'
    )
}}

WITH combined AS (
    SELECT
        month_period
        , 'Outbound' AS spend_channel
        , outbound_sales_team AS spend
    FROM {{ ref("stg_expenses_salary_and_comissions") }}
    
    UNION ALL
    
    SELECT
        month_period
        , 'Inbound' AS spend_channel
        , inbound_sales_team AS spend
    FROM {{ ref("stg_expenses_salary_and_comissions") }}
    
    UNION ALL
    
    SELECT
        month_period
        , 'Inbound' AS spend_channel
        , advertising_expense AS spend
    FROM {{ ref("stg_expenses_advertising") }}
)

SELECT
    month_period
    , spend_channel
    , SUM(spend) AS spend
FROM combined
GROUP BY 1, 2
