{% macro parse_dollars(field_name, from_alias=None) %}
    {%- set aliased_field = from_alias ~ '.' ~ field_name if from_alias else field_name -%}
    ROUND(
        CAST(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            {{ aliased_field }},
                            '[US$\t ]',
                            ''
                        ),
                        '\\.',
                        ''
                    ),
                    ',',
                    '.'
                ),
                '[^0-9\.-]',
                ''
            ) AS FLOAT
        ),
        2
    )
{% endmacro %}
