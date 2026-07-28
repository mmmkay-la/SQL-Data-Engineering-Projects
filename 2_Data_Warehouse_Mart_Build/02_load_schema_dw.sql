-- STEP 2: Load Data fron GCS
-- Populate tables without Foreign Keys first. 
-- Use of read_csv() duckdb function to import data.

-- Populate tables from GCS (Google Cloud Storage)
INSERT INTO company_dim (company_id, company_name, link, link_google, thumbnail)
SELECT company_id, name, link, link_google, thumbnail
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', 
    AUTO_DETECT=true, 
    HEADER=true);

SELECT '======== Successfully inserted data to company_dim ======== ' AS current_status;

INSERT INTO skills_dim (skill_id, skill_name, skill_type)
SELECT skill_id, skills, type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv',
    AUTO_DETECT=true, 
    HEADER=true);

SELECT ' ======== Successfully inserted data to skills_dim ========' AS current_status;

INSERT INTO job_posts_fact 
    (job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type, 
    job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance, job_country, 
    salary_rate, salary_year_avg, salary_hour_avg)
SELECT job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type, 
    job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance, job_country, 
    salary_rate, salary_year_avg, salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv',
    AUTO_DETECT=true, 
    HEADER=true);

SELECT '======== Successfully inserted data to job_posts_fact ========' AS current_status;

INSERT INTO skills_job_dim (job_id, skill_id)
SELECT job_id, skill_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', 
    AUTO_DETECT=true, 
    HEADER=true);

SELECT '======== Successfully inserted data to skills_job_dim ========' AS current_status;

-- Validate table counts 
SELECT 'company_dim' AS table_name, COUNT(*) AS table_counts FROM company_dim
UNION ALL
SELECT 'skills_dim', COUNT(*) FROM skills_dim
UNION ALL
SELECT 'skills_job_dim', COUNT(*) FROM skills_job_dim
UNION ALL
SELECT 'job_posts_fact', COUNT(*) FROM job_posts_fact;

-- Reference Check - Returns 0
SELECT COUNT(*) as 'rows not referenced'
FROM job_posts_fact
WHERE company_id NOT IN (SELECT company_id FROM company_dim);

SELECT COUNT(*) as 'rows not referenced'
FROM skills_job_dim 
WHERE skill_id NOT IN (SELECT skill_id FROM skills_dim);

SELECT COUNT(*) as 'rows not referenced'
FROM skills_job_dim 
WHERE job_id NOT IN (SELECT job_id FROM job_posts_fact);

-- Select sample Data from Tables.
SELECT * FROM job_posts_fact
ORDER BY RANDOM()
LIMIT 5;

SELECT * FROM company_dim
ORDER BY RANDOM()
LIMIT 5;

SELECT * FROM skills_job_dim
ORDER BY RANDOM()
LIMIT 5;

SELECT * FROM skills_dim
ORDER BY RANDOM()
LIMIT 5;

SELECT '=== DATA LOAD COMPLETED ===' AS output;

-- .read 2_Data_Warehouse_Mart_Build/02_load_schema_dw.sql