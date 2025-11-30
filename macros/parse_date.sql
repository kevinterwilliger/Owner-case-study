{% macro parse_date(field_name, from_alias=None) %}
    {%- set aliased_field = from_alias ~ '.' ~ field_name if from_alias else field_name -%}
    -- Handles dates in format '0024-03-21' where '0024' represents '2024'
    TRY_TO_DATE(
        CASE 
            WHEN LEFT({{ aliased_field }}, 2) = '00' 
            THEN '20' || RIGHT({{ aliased_field }}, LENGTH({{ aliased_field }}) - 2)
            ELSE {{ aliased_field }}
        END
    )
{% endmacro %}
