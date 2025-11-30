{{ 
    config(
        materialized = 'view'
    )
}}

SELECT
    {{ parse_month("month") }} AS month_period
    , {{ parse_dollars("outbound_sales_team") }} AS outbound_sales_team
    , {{ parse_dollars("inbound_sales_team") }} AS inbound_sales_team
FROM {{ source("GTM_CASE", "EXPENSES_SALARY_AND_COMMISSIONS") }}
