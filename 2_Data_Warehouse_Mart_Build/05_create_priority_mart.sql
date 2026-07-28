

-- Create Schema & Tables

DROP SCHEMA IF EXISTS priority_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS priority_schema;

CREATE TABLE IF NOT EXISTS priority_schema.priority_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_level INTEGER
);

INSERT INTO priority_schema.priority_roles (role_id, role_name, priority_level)
VALUES 
    (1, 'Data Engineer', 1),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

CREATE OR REPLACE TABLE priority_schema.priority_jobs_snapshot AS 
SELECT 
    j.job_id,
    j.job_title_short,
    c.company_name,
    j.job_posted_date,
    j.salary_year_avg,
    p.priority_level,
    CURRENT_TIMESTAMP AS updated_at
FROM job_posts_fact AS j
LEFT JOIN company_dim AS c
    ON j.company_id = c.company_id
LEFT JOIN priority_schema.priority_roles AS p
    ON j.job_title_short = p.role_name;

-- Data Validation
-- Validate row counts
SELECT 'priority_schema.priority_roles' AS table_name, COUNT(*) AS row_counts FROM priority_schema.priority_roles
UNION ALL
SELECT 'priority_schema.priority_jobs_snapshot', COUNT(*) FROM priority_schema.priority_jobs_snapshot;

SELECT * FROM priority_schema.priority_roles;

SELECT * FROM priority_schema.priority_jobs_snapshot;

SELECT 
    job_title_short, 
    COUNT(*) AS job_count,
    MIN(updated_at) AS min_updated_date,
    MIN(priority_level) AS priority_level
FROM priority_schema.priority_jobs_snapshot
GROUP BY job_title_short;

SELECT '======= PRIORITY_MART CREATED AND LOADED =======' AS status;

-- .read 2_Data_Warehouse_Mart_Build/05_create_priority_mart.sql