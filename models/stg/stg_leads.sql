{{
    config(
        materialized = 'view'
    )
}}

SELECT
    lead_id
    , sales_text_count
    , sales_email_count
    , first_text_sent_date
    , connected_with_decision_maker
    , {{ parse_date("form_submission_date") }} AS form_submission_date
    , IFF(form_submission_date IS NULL, 'Outbound', 'Inbound') AS lead_source
    , LEAST(
        COALESCE(first_sales_call_date, last_sales_call_date, '9999-12-31')
        , COALESCE(last_sales_email_date, '9999-12-31')
        , COALESCE(first_text_sent_date, '9999-12-31')
        , COALESCE(first_meeting_booked_date, '9999-12-31')
        , COALESCE({{ parse_date("form_submission_date") }}, '9999-12-31')
    ) AS initial_engagement_date

    , last_sales_call_date
    , {{ parse_array("cuisine_types") }} AS cuisine_types
    , sales_call_count
    , status
    , {{ parse_dollars("predicted_sales_with_owner") }} AS predicted_monthly_sales -- Assumed to be montly sales
    , {{ parse_array("marketplaces_used") }} AS marketplaces_used
    , {{ parse_array("online_ordering_used") }} AS online_ordering_used
    , last_sales_email_date
    , first_sales_call_date
    , location_count
    , converted_opportunity_id
    , first_meeting_booked_date
    , last_sales_activity_date
FROM {{ source("GTM_CASE", "LEADS") }}
