-- STEP 3: Create Flat Table to store Job Posting Detaails

DROP SCHEMA IF EXISTS flat_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS flat_schema;

CREATE OR REPLACE TABLE flat_schema.flat_mart AS 
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location, 
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cm.company_id,
    cm.company_name,
    ARRAY_AGG(
        sd.skill_name ORDER BY sd.skill_name
    ) AS skills_list
FROM job_posts_fact AS jpf
LEFT JOIN company_dim AS cm
    ON cm.company_id = jpf.company_id
LEFT JOIN skills_job_dim AS sjd 
    ON  jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL;

SELECT COUNT(*) AS flat_mart_count FROM flat_schema.flat_mart; 

SELECT * FROM flat_schema.flat_mart  ORDER BY job_id LIMIT 10;

SELECT '======= FLAT_MART CREATED AND LOADED =======' AS status;

--- .read 2_Data_Warehouse_Mart_Build/03_create_flat_mart.sql