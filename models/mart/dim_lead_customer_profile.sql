{{
    config(
        materialized = 'table'
    )
}}

SELECT
    lead_id
    , cuisine_types
    , location_count
    , marketplaces_used
    , online_ordering_used
    , predicted_monthly_sales
    , estimated_ltv
    , is_ongoing
    , is_closed_won
    , days_to_close
FROM {{ ref('int_lead_value') }} AS leads
LEFT JOIN {{ ref('int_channel_spend') }} AS spend
    ON DATE_TRUNC('month', leads.close_date) = spend.month_period
        AND leads.lead_source = spend.spend_channel
