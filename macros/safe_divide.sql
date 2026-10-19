{% macro safe_divide(numerator, denominator, default_value=0) %}
    CASE 
        WHEN {{ denominator }} IS NULL OR {{ denominator }} = 0 
        THEN {{ default_value }}
        ELSE ({{ numerator }} * 1.0) / NULLIF({{ denominator }}, 0)
    END
{% endmacro %}
