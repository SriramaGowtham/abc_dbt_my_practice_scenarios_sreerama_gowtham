{% macro cibil_score_mco(cibilscore) %}

    CASE WHEN {{cibilscore}} BETWEEN 300 AND 549 THEN 'POOR'
         WHEN {{cibilscore}} BETWEEN 550 AND 649 THEN 'AVERAGE'
         WHEN {{cibilscore}} BETWEEN 650 AND 749 THEN 'GOOD'
         WHEN {{cibilscore}} BETWEEN 750 AND 900 THEN 'EXCELLENT'
         ELSE 'INVALID' END
    
{% endmacro %}