
-- STEP 4: Skills Mart

-- Create Schema
DROP SCHEMA IF EXISTS skills_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS skills_schema;

CREATE TABLE IF NOT EXISTS skills_schema.dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skill_name,
    skill_type
);

CREATE TABLE IF NOT EXISTS skills_schema.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year    INTEGER,
    month   INTEGER,
    quarter INTEGER,
    quarter_name    VARCHAR,
    year_quarter    VARCHAR
)

CREATE TABLE IF NOT EXISTS skills_schema.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_posts_count INTEGER,
    health_insurance_posts_count INTEGER,
    no_degree_posts_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_schema.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_schema.dim_date_month(month_start_date)
)

SELECT '===== skills_schema tables created (3) =====' AS status

INSERT INTO skills_schema.dim_skills (
    skill_id, skill_name, skill_type
) SELECT skill_id, skill_name, skill_type
FROM skills_dim;

INSERT INTO skills_schema.dim_date_month (
    month_start_date, year, month, quarter, quarter_name, year_quarter ) 
SELECT 
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    YEAR(job_posted_date) AS year,
    MONTH(job_posted_date) AS month,
    QUARTER(job_posted_date) AS quarter,
    CASE 
        WHEN QUARTER(job_posted_date) = 1 THEN '1st Quarter'
        WHEN QUARTER(job_posted_date) = 2 THEN '2nd Quarter'
        WHEN QUARTER(job_posted_date) = 3 THEN '3rd Quarter'
        ELSE '4th Quarter'
    END AS quarter_name,
    CONCAT(YEAR(job_posted_date),'-',QUARTER(job_posted_date)) AS year_quarter
FROM job_posts_fact
ORDER by RANDOM()
LIMIT 10;


INSERT INTO skills_schema.fact_skill_demand_monthly (
    skill_id, month_start_date, job_title_short, posts_count, remote_posts_count,
    health_insurance_posts_count, no_degree_posts_count )
SELECT 
    sd.skill_id, 
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date, 
    jpf.job_title_short,
    COUNT(jpf.job_id) 
        OVER (PARTITION BY sd.skill_id
        ORDER BY DATE_TRUNC('month', job_posted_date::DATE)) AS posts_count,
    COUNT(jpf.job_id)
        OVER (PARTITION BY sd.skill_id, jpf.job_work_from_home 
        ORDER BY DATE_TRUNC('month', job_posted_date::DATE)) AS remote_posts_count,
    COUNT(jpf.job_id)
        OVER (PARTITION BY sd.skill_id, jpf.job_health_insurance 
        ORDER BY DATE_TRUNC('month', job_posted_date::DATE)) AS heatlh_insurance_posts_count,
    COUNT(jpf.job_id)
        OVER (PARTITION BY sd.skill_id, jpf.job_no_degree_mention
        ORDER BY DATE_TRUNC('month', job_posted_date::DATE)) AS no_degree_posts_count,
FROM job_posts_fact AS jpf
LEFT JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
ORDER BY month_start_date
LIMIT 50;
