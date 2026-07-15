{% materialization materialized_view, adapter='snowflake' %}

    {% set relation = this %}

    {% set create_mv %}

        create or replace materialized view {{ relation }}

        as

        {{ compiled_code }}

    {% endset %}

    {% call statement('main') %}

        {{ create_mv }}

    {% endcall %}

    {{ return({'relations':[relation]}) }}

{% endmaterialization %}