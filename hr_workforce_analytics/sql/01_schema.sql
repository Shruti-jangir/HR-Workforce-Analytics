-- =============================================================
-- HR Workforce Analytics - Database Schema
-- Compatible: PostgreSQL 14+ / SQLite 3.35+
-- =============================================================

CREATE TABLE IF NOT EXISTS departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id         VARCHAR(10)    PRIMARY KEY,
    full_name           VARCHAR(100)   NOT NULL,
    gender              VARCHAR(20),
    age                 INT,
    education           VARCHAR(50),
    city                VARCHAR(50),
    department          VARCHAR(50),
    job_title           VARCHAR(100),
    job_level           VARCHAR(20),
    employment_type     VARCHAR(20),
    hire_date           DATE           NOT NULL,
    exit_date           DATE,
    tenure_years        NUMERIC(5,2),
    annual_salary_inr   BIGINT,
    performance_score   NUMERIC(3,1),
    satisfaction_score  NUMERIC(3,1),
    training_hours      INT,
    promotions          INT            DEFAULT 0,
    manager_id          VARCHAR(10),
    attrition           VARCHAR(5)     CHECK (attrition IN ('Yes','No')),
    exit_reason         VARCHAR(50),
    attrition_flag      SMALLINT       DEFAULT 0,
    engagement_risk     SMALLINT       DEFAULT 0,
    hire_year           INT,
    hire_month          INT,
    age_band            VARCHAR(10),
    salary_band         VARCHAR(10),
    perf_category       VARCHAR(20),
    salary_L            NUMERIC(8,2)
);

CREATE INDEX IF NOT EXISTS idx_dept      ON employees(department);
CREATE INDEX IF NOT EXISTS idx_attrition ON employees(attrition);
CREATE INDEX IF NOT EXISTS idx_hire_date ON employees(hire_date);
CREATE INDEX IF NOT EXISTS idx_perf      ON employees(performance_score);
CREATE INDEX IF NOT EXISTS idx_hire_year ON employees(hire_year);
