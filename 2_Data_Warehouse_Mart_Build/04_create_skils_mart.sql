
-- STEP 4: Skills Mart

-- fact_skill_demand_monthly = counts based on skill, date and job title short. 
-- Create Schema
DROP SCHEMA IF EXISTS skills_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS skills_schema;

CREATE TABLE IF NOT EXISTS skills_schema.dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skill_name VARCHAR,
    skill_type VARCHAR
);

CREATE TABLE IF NOT EXISTS skills_schema.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year    INTEGER,
    month   INTEGER,
    quarter INTEGER,
    quarter_name    VARCHAR,
    year_quarter    VARCHAR
);

CREATE TABLE IF NOT EXISTS skills_schema.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    posts_count INTEGER,
    remote_posts_count INTEGER,
    health_insurance_posts_count INTEGER,
    no_degree_posts_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_schema.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_schema.dim_date_month(month_start_date)
);

SELECT '===== skills_schema tables created (3) =====' AS status;

INSERT INTO skills_schema.dim_skills (
    skill_id, skill_name, skill_type
) SELECT skill_id, skill_name, skill_type
FROM skills_dim;

SELECT '===== dim_skills table loaded =====' AS status;

INSERT INTO skills_schema.dim_date_month (
    month_start_date, year, month, quarter, quarter_name, year_quarter ) 
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    YEAR(job_posted_date) AS year,
    MONTH(job_posted_date) AS month,
    QUARTER(job_posted_date) AS quarter,
    CASE 
        WHEN QUARTER(job_posted_date) = 1 THEN 'Q1'
        WHEN QUARTER(job_posted_date) = 2 THEN 'Q2'
        WHEN QUARTER(job_posted_date) = 3 THEN 'Q3'
        ELSE 'Q4'
    END AS quarter_name,
    CONCAT(YEAR(job_posted_date),' - ','Q',QUARTER(job_posted_date)) AS year_quarter
FROM job_posts_fact;

SELECT '===== dim_date_month table loaded =====' AS status;

INSERT INTO skills_schema.fact_skill_demand_monthly (
    skill_id, month_start_date, job_title_short, posts_count, remote_posts_count,
    health_insurance_posts_count, no_degree_posts_count )
WITH skills_demand_monthly AS (
    SELECT 
        sjd.skill_id, 
        DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date, 
        jpf.job_title_short,
        1 as posts_count,
        CASE WHEN job_work_from_home THEN 1 ELSE 0 END AS remote_posts_count,
        CASE WHEN job_health_insurance THEN 1 ELSE 0 END AS health_insurance_posts_count,
        CASE WHEN job_no_degree_mention THEN 1 ELSE 0 END AS no_degree_posts_count
    FROM job_posts_fact AS jpf
    INNER JOIN skills_job_dim AS sjd 
        ON jpf.job_id = sjd.job_id
) SELECT 
    skill_id,
    month_start_date,
    job_title_short,
    SUM(posts_count) AS posts_count,
    SUM(remote_posts_count) AS remote_posts_count,
    SUM(health_insurance_posts_count) as health_insurance_posts_count,
    SUM(no_degree_posts_count) AS no_degree_posts_count
FROM skills_demand_monthly
GROUP BY skill_id, month_start_date, job_title_short
ORDER BY month_start_date;


SELECT '===== fact_skill_demand_monthly table loaded =====' AS status;

-- Data Validations 
-- Validate Table Counts 
SELECT 'skills_schema.dim_skills' AS table_name, COUNT(*) AS row_counts FROM skills_schema.dim_skills
UNION ALL
SELECT 'skils_schema.dim_date_month', COUNT(*) FROM skills_schema.dim_date_month
UNION ALL
SELECT 'skills_schema.fact_skill_demand_monthly', COUNT(*) FROM skills_schema.fact_skill_demand_monthly;


-- SELECT SAMPLE DATA
SELECT * FROM skills_schema.dim_skills LIMIT 10;

SELECT * FROM skills_schema.dim_date_month LIMIT 10;

SELECT * FROM skills_schema.fact_skill_demand_monthly LIMIT 10;

SELECT
    s.skill_name, s.skill_type,
    fs.*,
    dm.month, dm.year_quarter
FROM skills_schema.fact_skill_demand_monthly AS fs
LEFT JOIN skills_schema.dim_skills AS s
    ON fs.skill_id = s.skill_id
LEFT JOIN skills_schema.dim_date_month AS dm
    ON fs.month_start_date = dm.month_start_date
ORDER BY month_start_date;

SELECT '======= SKILLS_MART CREATED AND LOADED =======' AS status;

-- .read 2_Data_Warehouse_Mart_Build/04_create_skils_mart.sql