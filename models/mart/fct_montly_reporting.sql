{{
    config(
        materialized = 'table'
    )
}}

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', close_date) as win_month
        , lead_source AS channel
        , COUNT(DISTINCT lead_id) AS n_leads
        , COUNT(DISTINCT IFF(stage_name = 'Closed Won', lead_id, NULL)) AS n_cw
        , COUNT(DISTINCT opportunity_id) AS n_opps
        , SUM(sales_call_count) AS total_calls
        , SUM(sales_text_count) AS total_texts
        , SUM(sales_email_count) AS total_emails
        , SUM(IFF(is_closed_won, estimated_ltv, NULL)) as total_new_ltv_generated
    FROM {{ ref('int_lead_value') }}
    GROUP BY 1, 2
)

SELECT
    spend.month_period
    , spend.spend_channel
    , spend.spend
    , revenue.n_cw AS opps_won
    , revenue.total_new_ltv_generated
    , (spend.spend / NULLIF(revenue.n_leads, 0)) as lead_acq_cost
    , (spend.spend / NULLIF(revenue.n_opps, 0)) as opp_acq_cost
    , (spend.spend / NULLIF(revenue.n_cw, 0)) as customer_acq_cost
    , (revenue.total_new_ltv_generated / NULLIF(spend.spend, 0)) as ltv_to_cac_ratio
FROM {{ ref('int_channel_spend') }} AS spend
LEFT JOIN monthly_revenue AS revenue
    ON spend.month_period = revenue.win_month
        AND spend.spend_channel = revenue.channel
