-- STEP 1: Create Data Warehouse  & Tables

-- Create Database
CREATE DATABASE IF NOT EXISTS jobs_analysis_dw;

USE jobs_analysis_dw;

-- Drop Tables If Existing
DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS job_posts_fact;
DROP TABLE IF EXISTS company_dim;

CREATE TABLE IF NOT EXISTS company_dim(
    company_id INTEGER PRIMARY KEY NOT NULL,
    company_name VARCHAR,
    link VARCHAR,
    link_google VARCHAR,
    thumbnail VARCHAR
);

CREATE TABLE IF NOT EXISTS job_posts_fact(
    job_id      INTEGER PRIMARY KEY NOT NULL,
    company_id  INTEGER REFERENCES company_dim(company_id),
    job_title_short VARCHAR,
    job_title       VARCHAR,
    job_location    VARCHAR,
    job_via         VARCHAR,
    job_schedule_type   VARCHAR,
    job_work_from_home  BOOLEAN,
    search_location VARCHAR,
    job_posted_date TIMESTAMP,
    job_no_degree_mention   BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country     VARCHAR,
    salary_rate     VARCHAR,
    salary_year_avg DOUBLE,
    salary_hour_avg DOUBLE
);

CREATE TABLE IF NOT EXISTS skills_dim(
    skill_id INTEGER PRIMARY KEY NOT NULL,
    skill_name VARCHAR,
    skill_type VARCHAR
);

CREATE TABLE IF NOT EXISTS skills_job_dim(
    job_id INTEGER, 
    skill_id INTEGER,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_posts_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);

SELECT * FROM job_posts_fact;
SELECT * FROM company_dim;
SELECT * FROM skills_job_dim;
SELECT * FROM skills_dim; 

SELECT '=== DATA WAREHOUSE & TABLES CREATED ===' AS output;

-- .read 2_Data_Warehouse_Mart_Build/01_create_dw_tables.sql