
{% macro parse_month(field_name, from_alias=None) %}
    {%- set aliased_field = from_alias ~ '.' ~ field_name if from_alias else field_name -%}
    TRY_TO_DATE({{ aliased_field }} || '-01', 'MON-YY-DD')
{% endmacro %}
