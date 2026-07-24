
-- Create Schema and Tables
DROP SCHEMA IF EXISTS company_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS company_schema;

-- Dimension Tables
CREATE OR REPLACE SEQUENCE jt_id START 1;
CREATE TABLE IF NOT EXISTS company_schema.dim_job_title (
    job_title_id INTEGER PRIMARY KEY DEFAULT nextval('jt_id'),
    job_title VARCHAR
);

INSERT INTO company_schema.dim_job_title (job_title)
SELECT DISTINCT job_title FROM job_posts_fact
WHERE job_title IS NOT NULL;

CREATE OR REPLACE SEQUENCE jts_id START 1;
CREATE TABLE IF NOT EXISTS company_schema.dim_job_title_short (
    job_title_short_id INTEGER PRIMARY KEY DEFAULT nextval('jts_id'),
    job_title_short VARCHAR
);

INSERT INTO company_schema.dim_job_title_short (job_title_short)
SELECT DISTINCT job_title_short FROM job_posts_fact
WHERE job_title_short IS NOT NULL;

CREATE TABLE IF NOT EXISTS company_schema.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER
);

INSERT INTO company_schema.dim_date_month (month_start_date, year, month)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    YEAR(job_posted_date) AS year,
    MONTH(job_posted_date) AS month
FROM job_posts_fact;

CREATE OR REPlACE SEQUENCE IF NOT EXISTS loc_id START 1;
CREATE TABlE IF NOT EXISTS company_schema.dim_location (
    location_id INTEGER PRIMARY KEY DEFAULT nextval('loc_id'),
    job_country VARCHAR,
    job_location VARCHAR
);

INSERT INTO company_schema.dim_location (job_country, job_location)
SELECT DISTINCT job_country, job_location FROM job_posts_fact;

CREATE TABLE IF NOT EXISTS company_schema.dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR
);

INSERT INTO company_schema.dim_company (company_id, company_name)
SELECT DISTINCT company_id, company_name FROM company_dim;

-- Bridge Tables
CREATE TABLE IF NOT EXISTS company_schema.bridge_job_title (
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_schema.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_schema.dim_job_title(job_title_id)
);

INSERT INTO company_schema.bridge_job_title (job_title_short_id, job_title_id)
SELECT DISTINCT
    jf.job_id,
    jts.job_title_short_id,
    jt.job_title_id
FROM job_posts_fact AS jf
LEFT JOIN company_schema.dim_job_title AS jt
    ON jf.job_title = jt.job_title
LEFT JOIN company_schema.dim_job_title_short AS jts
    ON jf.job_title_short = jts.job_title_short
ORDER by jt.job_title_id;

CREATE TABLE IF NOT EXISTS company_schema.bridge_company_location (
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_schema.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_schema.dim_location(location_id)
);

INSERT INTO company_schema.bridge_company_location (company_id, location_id)
SELECT 
    c.company_id,
    l.location_id
FROM job_post_fact as jf
LEFT JOIN company_schema.dim_company AS c
    ON jf.company_id = c.company_id
LEFT JOIN company_schema.dim_location AS l
    ON jf.job_location = l.job_location AND jf.job_country = l.job_country;

-- Fact Table
CREATE TABLE IF NOT EXISTS company_schema.fact_company_hiring_monthly (
    company_id INTEGER,
    job_title_short_id INTEGER,
    month_start_date DATE,
    job_country VARCHAR,
    posts_count INTEGER,
    median_salary_year DOUBLE,
    min_salary_year DOUBLE,
    max_salary_year DOUBLE,
    remote_share DOUBLE,
    health_insurance_share DOUBLE,
    no_degree_mention_share DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY (company_id) REFERENCES company_schema.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_schema.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_schema.dim_date_month(month_start_date)
);

SELECT '======= COMPANY_MART CREATED & LOADED =======' AS status;

-- .read 2_Data_Warehouse_Mart_Build/07_company_mart.sql


SELECT 'dim_job_title_short' AS table_name, COUNT (*) as row_count FROM company_schema.dim_job_title_short
UNION ALL 
SELECT 'dim_job_title', COUNT(*) FROM company_schema.dim_job_title;
