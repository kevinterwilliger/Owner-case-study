# Owner.com GTM Analytics Case Study
This project focuses on two primary business objectives: scaling growth 2-3x and improving the CAC:LTV ratio.

The solution is implemented using a modular dbt structure to ensure the data is a Single Source of Truth (SSOT) and can scale with the business.

## Data Product Architecture (dbt Lineage)

The solution follows a standard Extract-Load-Transform (ELT) pattern, where transformation logic is layered using dbt models: 

| Layer | Purpose | Ex. Models | Grainularity |
| :--- | :--- | :--- | :--- |
| **Staging (`stg_`)** | Data cleaning, standardizing column names, and type casting. | `stg_leads`, `stg_opportunities`, `stg_expenses_[ads, salary]` | Raw Source |
| **Intermediate (`int_`)** | Business logic and complex calculations, such as LTV and cost aggregation. | `int_lead_value`, `int_channel_spend` | Lead/Opportunity ID, Month/Channel |
| **Marts (`fct_`/`dim_`)** | Final, consumer-ready tables for BI tools and reporting. These are the core data products. | `fct_monthly_reporting`, `dim_ideal_customer_profile` | Month/Channel, Account/Lead |


## Core Data Products

Three primary data marts were created to provide the GTM team with actionable insights:

### 1. `dim_ideal_customer_profile` (Growth Mart)

This granular table is designed to support segmentation and lead scoring, which is crucial for achieving the 2-3x scaling goal. It considers CW accounts and provides metrics, attributes, and insights into each customer profile. This table can be further improved by opening it up in order to score each incoming lead based on the ICP.

* **Grain:** Single Converted Opportunity ID.
* **Key Dimensions:**
    * **Technographics:** Features like `MARKETPLACES_USED` and `ONLINE_ORDERING_USED`.
    * **Firmographics:** `CUISINE_TYPES` and `LOCATION_COUNT`.
    * **Value:** Projected `estimated_ltv` (from the intermediate layer).
* **Actionable Insight:** Allows the BizOps team  to identify the precise characteristics (e.g., "3-location Italian restaurants using Toast") that yield the highest LTV and conversion rates, informing lead list enrichment and BDR/SDR prioritization.

### 2. `fct_monthly_reporting` (Efficiency Mart)

This table serves as the primary SSOT for the business's financial health, connecting sales results to operational costs.

* **Grain:** Month and Sales Channel (Inbound vs. Outbound).
* **Key Metrics:**
    * **Cost of Acquisition (CAC):** Total monthly spend (Advertising and Salary) divided by the number of deals Closed Won.
    * **Estimated Lifetime Value (LTV):** Calculated by combining the recurring subscription ($500/month) and the variable take rate (5% of `PREDICTED_SALES_WITH_OWNER`) **_(Critical Assumption: This field is treated as the expected monthly sales volume)._**
    * **LTV:CAC Ratio:** The ultimate north-star metric, directly addressing the core problem of improving the CAC:LTV ratio.
* **Actionable Insight:** Identifies which channel (Inbound or Outbound) delivers the most profitable customer over time.


### 3. `fct_sales_velocity` (Operational Mart)

This fact table is designed to track the **speed and efficiency** of the sales process, allowing GTM leadership to identify and address bottlenecks that impede scaling. Reducing the time from Lead creation to Close (increasing velocity) is a direct way to scale without proportionally increasing input (leads). 

* **Grain:** Single Lead (& Opportunity) ID.
* **Key Metrics & Time-Deltas:**
    * **Time-to-Demo:** The duration (in days) between the `FORM_SUBMISSION_DATE` and the `DEMO_SET_DATE`. This measures the effectiveness of the SDR/BDR team.
    * **Time-to-Close:** The duration (in days) between the Opportunity `CREATED_DATE` (when the demo is booked) and the `CLOSE_DATE`. This measures AE efficiency.
    * **Sales Activity Count:** Total number of `SALES_CALL_COUNT`, `SALES_TEXT_COUNT`, and `SALES_EMAIL_COUNT` required to reach key milestones (e.g., booking the first demo).
* **Actionable Insight:** Allows sales managers to audit team performance and implement specific time-based SLAs (Service Level Agreements), such as "Inbound leads must have a first call attempt within 4 hours." It reveals where deals are stalling (e.g., high activity counts but slow progression to Demo Held).

## Biggest GTM Opportunities

Based on the three data marts (`fct_monthly_reporting`, `dim_ideal_customer_profile`, and `fct_sales_velocity`), the GTM team can take two key, interconnected actions to achieve 2-3x growth and improve the CAC:LTV ratio.

### 1. Optimize and Dynamically Reallocate Budget to the Most Profitable Channel

This opportunity directly targets the **CAC:LTV ratio** by ensuring every dollar of spend generates the maximum possible return.

* **Action:** Use the **`fct_monthly_reporting`** mart to identify the channel (Inbound or Outbound) that consistently delivers the highest LTV:CAC ratio month-over-month.
* **Implementation:** Shift marketing ad spend (Facebook/Google ) and BDR/SDR hiring efforts dynamically towards the superior channel. If Outbound, for example, shows a 6:1 LTV:CAC compared to Inbound's 3:1, resources must be aggressively moved to Outbound, maximizing profitable growth (scaling).

### 2. Implement a High-Value Lead Scoring and Prioritization System

This opportunity addresses scaling efficiency by ensuring the sales team's time (a major component of CAC ) is spent only on the most valuable, most likely-to-close leads.

* **Action:** Leverage the **`dim_ideal_customer_profile`** mart to identify and score the specific technographic and firmographic segments (e.g., `CUISINE_TYPES`, `LOCATION_COUNT`) that correlate with the highest `estimated_ltv` and best historical conversion rate.
* **Implementation:**
    * **BizOps/Outbound:** Prioritize the enrichment and list-building efforts for BDRs  to focus *only* on these high-score segments.
    * **SDR/Velocity:** Use the **`fct_sales_velocity`** mart to audit and enforce strict Service Level Agreements (SLAs), ensuring that high-score leads receive the initial outreach (`FIRST_SALES_CALL_DATE` or `FIRST_TEXT_SENT_DATE`) and follow-up activities faster and more frequently than low-score leads.

## Potential Improvements

### 1. One-Hot Encoding
I left the array fields as Arrays in Snowflake. While Snowflake provides pretty good variant handleing and out-of-the-box funtionality (like `ARRAY_CONTAINS`), providing the data in a sparse format (i.e `is_italian` or `uses_doordash`) would allow for easier data science applications for futher analysis.

### 2. More data quality testing.
I did a brief EDA when beginning this case study, but more can always be done. I think there is room for improvement in the data quality testing and raw data analysis.

### 3. Incremental Models.
Since the data provided is quite small, I chose to leave the intermediate and mart models as Tables. Costs & run times can be reduced by implementing incremental logic - especially for the leads/opportunity data. Additional data sources (like raw Ads data) should also be turned into incremental models in the intermediate layer.


