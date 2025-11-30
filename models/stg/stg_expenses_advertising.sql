{{
    config(
        materialized = 'view'
    )
}}

SELECT
    {{ parse_month("month") }} AS month_period
    , {{ parse_dollars("advertising") }} AS advertising_expense
FROM {{ source("GTM_CASE", "EXPENSES_ADVERTISING") }}
