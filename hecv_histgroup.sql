SELECT
    person,
    class,
    dt AS effective_from,
    COALESCE((LEAD(dt) OVER(PARTITION BY person ORDER BY dt) - INTERVAL '1'SECOND),
        TO_DATE('31.12.2999 23:59:59', 'DD.MM.YYYY HH24:MI:SS')) AS effective_to
FROM (
    SELECT
        person,
        class,
        COALESCE(LAG(class) OVER(PARTITION BY person ORDER BY dt),
            CAST(' ' AS VARCHAR2(100))) AS next,
        dt
    FROM de.histgroup)
WHERE class <> next;