{% macro cents_to_dollars(column_name, decimal_places=2) %}
    ROUND(
        COALESCE({{ column_name }}, 0) / 100.0, 
        {{ decimal_places }}
    )
{% endmacro %}