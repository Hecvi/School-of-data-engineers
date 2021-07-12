SELECT
    payment_dt,
    person,
    payment,
    month_paid,
    salary - month_paid AS month_rest
FROM (
    SELECT
        de.payment_dt,
        de.person,
        de.payment,
        SUM(de.payment) OVER(PARTITION BY de.person,
            EXTRACT(MONTH FROM de.payment_dt) ORDER BY de.payment_dt)
                AS month_paid,
        hecv.salary
    FROM de.payments de LEFT JOIN itde1.hecv_salary_hist hecv
    ON de.person = hecv.person AND de.payment_dt BETWEEN hecv.effective_from
        AND hecv.effective_to
    ORDER BY person, payment_dt);