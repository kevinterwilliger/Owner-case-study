{{
    config(
        materialized = 'table'
    )
}}

{% set take_rate = 0.05 %}

{% set monthly_sub = 500 %}

{% set estimated_sub_length = 24 %} -- Estimated Length of customer subscription. I've chosen 2 years, but this can be altered.

{% set in_progress_stages = ('Verbal Commitment', 'In Progress', 'Demo Set', 'Interest', 'On Hold') %}


SELECT
    leads.lead_id
    , opps.opportunity_id

    , leads.sales_text_count
    , leads.sales_email_count
    , leads.first_text_sent_date
    , leads.connected_with_decision_maker
    , leads.form_submission_date
    , leads.lead_source
    , leads.last_sales_call_date
    , leads.cuisine_types
    , leads.sales_call_count
    , leads.status
    , leads.marketplaces_used
    , leads.online_ordering_used
    , leads.predicted_monthly_sales
    , leads.last_sales_email_date
    , leads.first_sales_call_date
    , leads.location_count
    , leads.first_meeting_booked_date
    , leads.last_sales_activity_date
    , leads.initial_engagement_date

    , opps.stage_name
    , opps.stage_name IN {{ in_progress_stages }} AS is_ongoing
    , opps.stage_name = 'Closed Won' AS is_closed_won
    , opps.demo_time
    , opps.lost_reason_c
    , opps.demo_set_date
    , opps.demo_held
    , opps.business_issue_c
    , opps.closed_lost_notes_c
    , opps.close_date
    , DATEDIFF(DAY, leads.initial_engagement_date, opps.close_date) AS total_sales_cycle_days
    , opps.last_sales_call_date_time
    , opps.account_id
    , opps.created_date AS opp_created_date
    , opps.how_did_you_hear_about_us_c

    , leads.predicted_monthly_sales * {{ estimated_sub_length }} AS predicted_total_sales
    , {{ monthly_sub }} * {{ estimated_sub_length }} AS subscription_ltv
    , {{ take_rate }} * leads.predicted_monthly_sales * {{ estimated_sub_length }} AS sales_ltv
    , subscription_ltv + sales_ltv AS estimated_ltv
FROM {{ ref("stg_leads") }} AS leads
LEFT JOIN {{ ref("stg_opportunities") }} AS opps
    ON leads.converted_opportunity_id = opps.opportunity_id
