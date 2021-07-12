CREATE TABLE ITDE1.HECV_LOG AS
WITH t1 AS (
    SELECT
        CAST(SUBSTR(val, 1, INSTR(val, CHR(09), 1, 1) - 1) AS VARCHAR2(32)) AS ip,
        TO_DATE(SUBSTR(val, INSTR(val, CHR(09), 1, 3) + 1, INSTR(val, CHR(09), 1, 4) - 1 - INSTR(val, CHR(09), 1, 3)), 'YYYYMMDDHH24:MI:SS') AS dt,
        CAST(SUBSTR(val, INSTR(val, CHR(09), 1, 4) + 1, INSTR(val, CHR(09), 1, 5) - 1 - INSTR(val, CHR(09), 1, 4)) AS VARCHAR2(50)) AS link,
        CAST(SUBSTR(val, INSTR(val, CHR(09), 1, 7) + 1) AS VARCHAR2(200)) AS user_agent
    FROM DE.log),
    t2 AS (
    SELECT
        CAST(SUBSTR(val, 1, INSTR(val, ' ', 1, 1) - 1) AS VARCHAR2(32)) AS ip,
        CAST(TRIM(SUBSTR(val, INSTR(val, ' ', 1, 1) + 1)) AS VARCHAR2(30)) AS region
    FROM DE.ip)
SELECT
    dt,
    link,
    user_agent,
    region
FROM t1 LEFT JOIN t2
ON t1.ip = t2.ip


/
CREATE TABLE ITDE1.HECV_LOG_REPORT AS
WITH t1 AS (
    SELECT
        CAST(SUBSTR(val, 1, INSTR(val, CHR(09), 1, 1) - 1) AS VARCHAR2(32)) AS ip,
        CAST(SUBSTR(val, INSTR(val, CHR(09), 1, 7) + 1, INSTR(val, '/', INSTR(val, CHR(09), 1, 7) + 1, 1) - 1 - INSTR(val, CHR(09), 1, 7)) AS VARCHAR2(10)) AS browser
    FROM DE.log),
    t2 AS (
    SELECT
        CAST(SUBSTR(val, 1, INSTR(val, ' ', 1, 1) - 1) AS VARCHAR2(32)) AS ip,
        CAST(TRIM(SUBSTR(val, INSTR(val, ' ', 1, 1) + 1)) AS VARCHAR2(20)) AS region
    FROM DE.ip),
    t3 AS (
    SELECT
        region,
        browser,
        COUNT(browser) AS nums
    FROM t1 LEFT JOIN t2
    ON t1.ip = t2.ip
    GROUP BY region, browser
    ORDER BY region),
    t4 AS (
    SELECT
        region,
        MAX(nums) AS max_value
    FROM t3
    GROUP BY region)
SELECT
    t3.region,
    t3.browser
FROM t3 INNER JOIN t4
ON t3.region = t4.region
WHERE nums = max_value


/
COMMIT;