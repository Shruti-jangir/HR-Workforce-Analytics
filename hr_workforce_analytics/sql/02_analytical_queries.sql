-- =============================================================
-- HR Workforce Analytics - Analytical Queries
-- Compatible: PostgreSQL 14+ / SQLite 3.35+
-- =============================================================


-- ── 1. Overall KPI Summary ───────────────────────────────────
SELECT
    COUNT(*)                                              AS total_employees,
    SUM(attrition_flag)                                   AS total_exits,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 2)   AS attrition_rate_pct,
    ROUND(AVG(tenure_years), 2)                           AS avg_tenure_years,
    ROUND(AVG(annual_salary_inr) / 100000.0, 2)          AS avg_salary_lakhs,
    ROUND(AVG(performance_score), 2)                      AS avg_performance,
    ROUND(AVG(satisfaction_score), 2)                     AS avg_satisfaction,
    SUM(engagement_risk)                                  AS engagement_risk_count
FROM employees;


-- ── 2. Attrition Rate by Department ──────────────────────────
SELECT
    department,
    COUNT(*)                                              AS headcount,
    SUM(attrition_flag)                                   AS attrited,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 1)   AS attrition_pct,
    CASE
        WHEN AVG(CAST(attrition_flag AS FLOAT)) > 0.18 THEN 'High'
        WHEN AVG(CAST(attrition_flag AS FLOAT)) > 0.12 THEN 'Medium'
        ELSE 'Low'
    END                                                   AS risk_level
FROM employees
GROUP BY department
ORDER BY attrition_pct DESC;


-- ── 3. Attrition by Job Level ─────────────────────────────────
SELECT
    job_level,
    COUNT(*)                                              AS headcount,
    SUM(attrition_flag)                                   AS attrited,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 1)   AS attrition_pct
FROM employees
GROUP BY job_level
ORDER BY attrition_pct DESC;


-- ── 4. Exit Reason Distribution ──────────────────────────────
SELECT
    exit_reason,
    COUNT(*)                                              AS exits,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM employees WHERE attrition = 'Yes'), 1) AS pct
FROM employees
WHERE attrition = 'Yes'
GROUP BY exit_reason
ORDER BY exits DESC;


-- ── 5. Salary Analysis by Department ─────────────────────────
SELECT
    department,
    COUNT(*)                                              AS employees,
    ROUND(AVG(annual_salary_inr) / 100000.0, 1)          AS avg_salary_L,
    ROUND(MIN(annual_salary_inr) / 100000.0, 1)          AS min_salary_L,
    ROUND(MAX(annual_salary_inr) / 100000.0, 1)          AS max_salary_L
FROM employees
GROUP BY department
ORDER BY avg_salary_L DESC;


-- ── 6. Salary by Job Level ────────────────────────────────────
SELECT
    job_level,
    COUNT(*)                                              AS employees,
    ROUND(AVG(annual_salary_inr) / 100000.0, 1)          AS avg_salary_L,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 1)   AS attrition_pct
FROM employees
GROUP BY job_level
ORDER BY avg_salary_L ASC;


-- ── 7. Monthly Hiring Trend ───────────────────────────────────
SELECT
    hire_year,
    hire_month,
    COUNT(*)                                              AS new_hires
FROM employees
WHERE hire_year BETWEEN 2015 AND 2024
GROUP BY hire_year, hire_month
ORDER BY hire_year, hire_month;


-- ── 8. Annual Hires vs Exits ─────────────────────────────────
SELECT
    hire_year                                             AS year,
    COUNT(*)                                              AS hires,
    SUM(attrition_flag)                                   AS exits,
    COUNT(*) - SUM(attrition_flag)                        AS net_change
FROM employees
WHERE hire_year BETWEEN 2015 AND 2024
GROUP BY hire_year
ORDER BY hire_year;


-- ── 9. Performance vs Attrition ──────────────────────────────
SELECT
    perf_category,
    COUNT(*)                                              AS total,
    SUM(attrition_flag)                                   AS attrited,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 1)   AS attrition_pct,
    ROUND(AVG(satisfaction_score), 2)                     AS avg_satisfaction
FROM employees
GROUP BY perf_category
ORDER BY attrition_pct DESC;


-- ── 10. High Performers at Risk ───────────────────────────────
SELECT
    employee_id,
    full_name,
    department,
    job_level,
    performance_score,
    satisfaction_score,
    ROUND(annual_salary_inr / 100000.0, 1)               AS salary_L,
    tenure_years
FROM employees
WHERE performance_score >= 4.0
  AND satisfaction_score <= 2.5
  AND attrition = 'No'
ORDER BY satisfaction_score ASC;


-- ── 11. Engagement Risk by Department ────────────────────────
SELECT
    department,
    COUNT(*)                                              AS headcount,
    SUM(engagement_risk)                                  AS at_risk,
    ROUND(SUM(engagement_risk) * 100.0 / COUNT(*), 1)    AS risk_pct,
    ROUND(AVG(satisfaction_score), 2)                     AS avg_satisfaction,
    ROUND(AVG(performance_score), 2)                      AS avg_performance
FROM employees
GROUP BY department
ORDER BY risk_pct DESC;


-- ── 12. Retention Cohort by Hire Year ────────────────────────
SELECT
    hire_year,
    COUNT(*)                                              AS hired,
    SUM(CASE WHEN attrition = 'No' THEN 1 ELSE 0 END)   AS still_active,
    ROUND(SUM(CASE WHEN attrition = 'No' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS retention_pct
FROM employees
WHERE hire_year BETWEEN 2015 AND 2024
GROUP BY hire_year
ORDER BY hire_year;


-- ── 13. Gender Diversity by Department ───────────────────────
SELECT
    department,
    gender,
    COUNT(*)                                              AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY department), 1) AS pct
FROM employees
GROUP BY department, gender
ORDER BY department, count DESC;


-- ── 14. Department Full KPI Scorecard ────────────────────────
SELECT
    department,
    COUNT(*)                                              AS headcount,
    ROUND(AVG(tenure_years), 1)                          AS avg_tenure,
    ROUND(AVG(annual_salary_inr) / 100000.0, 1)         AS avg_salary_L,
    ROUND(AVG(performance_score), 2)                     AS avg_perf,
    ROUND(AVG(satisfaction_score), 2)                    AS avg_satisfaction,
    SUM(attrition_flag)                                  AS exits,
    ROUND(AVG(CAST(attrition_flag AS FLOAT)) * 100, 1)  AS attrition_pct,
    SUM(engagement_risk)                                 AS risk_count,
    ROUND(AVG(CAST(training_hours AS FLOAT)), 1)         AS avg_training_hrs
FROM employees
GROUP BY department
ORDER BY attrition_pct DESC;
