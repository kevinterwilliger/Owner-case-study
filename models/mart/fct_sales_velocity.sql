{{
    config(
        materialized = 'table'
    )
}}

SELECT
    lead_id
    , opportunity_id
    , lead_source
    , status AS lead_status
    , stage_name

    , form_submission_date
    , initial_engagement_date
    , DATEDIFF(
        DAY
        , form_submission_date
        , LEAST(
            COALESCE(first_sales_call_date, '9999-12-31'), 
            COALESCE(first_text_sent_date, '9999-12-31')
        )
    ) AS inbound_to_lead_days

    , (sales_call_count + sales_email_count + sales_text_count) AS total_touchpoints
    , sales_call_count
    , sales_text_count
    , sales_email_count
    
    , opp_created_date
    , close_date

    , DATEDIFF(day, form_submission_date, opp_created_date) AS lead_to_opp_days
    
    , DATEDIFF(day, opp_created_date, close_date) AS opp_to_close_days
    
    , DATEDIFF(day, form_submission_date, close_date) AS total_sales_cycle_days

    , predicted_monthly_sales
    , subscription_ltv
    , sales_ltv
    , estimated_ltv

FROM {{ ref('int_lead_value') }}
