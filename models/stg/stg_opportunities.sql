{{
    config(
        materialized = 'view'
    )
}}

SELECT
    opportunity_id
    , stage_name
    , closed_lost_notes_c
    , demo_time
    , lost_reason_c
    , demo_set_date
    , demo_held
    , business_issue_c
    , {{ parse_date("close_date") }} AS close_date
    , last_sales_call_date_time
    , account_id
    , created_date
    , how_did_you_hear_about_us_c
FROM {{ source('GTM_CASE', 'OPPORTUNITIES') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY opportunity_id ORDER BY created_date DESC) = 1 -- Deduplicate opportunities on id - there are a few duplicate rows so the created date ordering is a bit arbitrary.
