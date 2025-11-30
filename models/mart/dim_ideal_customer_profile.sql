{{
    config(
        materialized = 'table'
    )
}}

WITH lead_spend_attribution AS (
    SELECT
        leads.lead_id
        , leads.opportunity_id
        , leads.account_id
        , leads.cuisine_types
        , leads.location_count
        , leads.lead_source
        , leads.marketplaces_used
        , leads.online_ordering_used
        , leads.estimated_ltv
        , leads.total_sales_cycle_days
        , leads.opp_created_date
        , leads.close_date
        , leads.initial_engagement_date

        , spend.spend AS channel_monthly_spend
        , COUNT(leads.lead_id) OVER (
            PARTITION BY 
                DATE_TRUNC('month', leads.close_date)
                , leads.lead_source
        ) AS monthly_cw

    FROM {{ ref('int_lead_value') }} leads
    INNER JOIN {{ ref('int_channel_spend') }} spend
        ON DATE_TRUNC('month', initial_engagement_date) = spend.month_period
            AND leads.lead_source = spend.spend_channel
    WHERE leads.is_closed_won
)

SELECT
    lead_id
    , opportunity_id
    , account_id
    , cuisine_types
    , marketplaces_used
    , online_ordering_used
    , location_count
    , lead_source

    , channel_monthly_spend / monthly_cw AS avg_attributed_cac
    , estimated_ltv AS avg_ltv
    , estimated_ltv / avg_attributed_cac AS ltv_to_cac_ratio
FROM lead_spend_attribution
