select
    '{{ target.name }}' as target_name,
    '{{ target.database }}' as database_name,
    '{{ target.schema }}' as schema_name,
    '{{ target.role }}' as role_name,
    '{{ target.user }}' as user_name,
    '{{ target.warehouse }}' as warehouse_name