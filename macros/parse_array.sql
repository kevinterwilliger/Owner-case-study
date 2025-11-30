{% macro parse_array(field_name, from_alias=None) %}
    {%- set aliased_field = from_alias ~ '.' ~ field_name if from_alias else field_name -%}
    TRY_PARSE_JSON(
        REPLACE(
            REPLACE({{ aliased_field }}, '"', '')
            , '[\'\']'
            , ''
        )
    )::ARRAY
{% endmacro %}
