
-- Create Schema and Tables
DROP SCHEMA IF EXISTS company_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS company_schema;

-- CREATE and INSERT INTO Dimension Tables
CREATE OR REPLACE SEQUENCE jt_id START 1;
CREATE OR REPlACE TABLE company_schema.dim_job_title (
    job_title_id INTEGER PRIMARY KEY DEFAULT nextval('jt_id'),
    job_title VARCHAR
);

INSERT INTO company_schema.dim_job_title (job_title)
SELECT DISTINCT job_title FROM job_posts_fact;

CREATE OR REPLACE SEQUENCE jts_id START 1;
CREATE OR REPLACE TABLE company_schema.dim_job_title_short (
    job_title_short_id INTEGER PRIMARY KEY DEFAULT nextval('jts_id'),
    job_title_short VARCHAR
);

INSERT INTO company_schema.dim_job_title_short (job_title_short)
SELECT DISTINCT job_title_short FROM job_posts_fact;

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

CREATE OR REPlACE SEQUENCE loc_id START 1;
CREATE OR REPlACE TABlE company_schema.dim_location (
    location_id INTEGER PRIMARY KEY DEFAULT nextval('loc_id'),
    job_country VARCHAR,
    job_location VARCHAR
);

INSERT INTO company_schema.dim_location (job_country, job_location)
SELECT DISTINCT job_country, job_location FROM job_posts_fact 
    WHERE job_country IS NOT NULL AND job_location IS NOT NULL;

CREATE TABLE IF NOT EXISTS company_schema.dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR
);

INSERT INTO company_schema.dim_company (company_id, company_name)
SELECT DISTINCT company_id, company_name FROM company_dim;

-- CREATE and INSERT INTO Bridge Tables
CREATE TABLE IF NOT EXISTS company_schema.bridge_job_title (
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_schema.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_schema.dim_job_title(job_title_id)
);

INSERT INTO company_schema.bridge_job_title (job_title_short_id, job_title_id)
SELECT DISTINCT
    jts.job_title_short_id,
    jt.job_title_id
FROM job_posts_fact AS jf
INNER JOIN company_schema.dim_job_title AS jt
    ON jf.job_title = jt.job_title
INNER JOIN company_schema.dim_job_title_short AS jts
    ON jf.job_title_short = jts.job_title_short;

CREATE TABLE IF NOT EXISTS company_schema.bridge_company_location (
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_schema.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_schema.dim_location(location_id)
);

INSERT INTO company_schema.bridge_company_location (company_id, location_id)
SELECT DISTINCT
    jf.company_id,
    l.location_id
FROM job_posts_fact as jf
INNER JOIN company_schema.dim_location AS l
    ON jf.job_location = l.job_location AND jf.job_country = l.job_country;

-- CREATE and INSERT INTO Fact Table
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

INSERT INTO company_schema.fact_company_hiring_monthly (
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    posts_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
) WITH init_cols AS (
    SELECT
        jf.company_id, 
        djs.job_title_short_id,
        DATE_TRUNC('month', jf.job_posted_date)::DATE AS month_start_date,
        jf.job_country, 
        salary_year_avg,
        CASE WHEN jf.job_work_from_home THEN 1 ELSE 0 END AS remote_post,
        CASE WHEN jf.job_health_insurance THEN 1 ELSE 0 END AS health_insurance_post,
        CASE WHEN jf.job_no_degree_mention THEN 1 ELSE 0 END AS no_degree_post
    FROM job_posts_fact jf
    INNER JOIN company_schema.dim_job_title_short AS djs
        ON jf.job_title_short = djs.job_title_short
    WHERE jf.job_country IS NOT NULL
        AND jf.company_id IS NOT NULL
        AND djs.job_title_short_id IS NOT NULL
) SELECT 
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(*) AS posts_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    AVG(remote_post) AS remote_share,
    AVG(health_insurance_post) AS health_insurance_share,
    AVG(no_degree_post) AS no_degree_mention_share
FROM init_cols AS i
GROUP BY company_id, job_title_short_id, month_start_date, job_country;


SELECT '======= COMPANY_MART CREATED & LOADED =======' AS status;

-- Validate Table Counts & Rows
SELECT 'dim_job_title_short' AS table_name, COUNT (*) as row_count FROM company_schema.dim_job_title_short
UNION ALL 
SELECT 'dim_job_title', COUNT(*) FROM company_schema.dim_job_title
UNION ALL
SELECT 'dim_company', COUNT(*) FROM company_schema.dim_company
UNION ALL 
SELECT 'dim_location', COUNT(*) FROM company_schema.dim_location
UNION ALL 
SELECT 'dim_date_month', COUNT(*) FROM company_schema.dim_date_month
UNION ALL
SELECT 'bridge_job_title', COUNT(*) FROM company_schema.bridge_job_title
UNION ALL
SELECt 'bridge_company_location', COUNT(*) FROM company_schema.bridge_company_location
UNION ALL 
SELECT 'fact_company_hiring_monthly', COUNT(*) FROM company_schema.fact_company_hiring_monthly;


SELECT '--- Sample Data From Each Dimention Table ---' as info;
SELECT * FROM company_schema.dim_job_title_short LIMIT 10;
SELECT * FROM company_schema.dim_job_title LIMIT 10;
SELECT * FROM company_schema.dim_company LIMIT 10;
SELECT * FROM company_schema.dim_location LIMIT 10;
SELECT * FROM company_schema.dim_date_month LIMIT 10;

SELECT '--- Sample Data From Each Bridge Table ---' as info;
SELECT * FROM company_schema.bridge_job_title LIMIT 10;
SELECT * FROM company_schema.bridge_company_location LIMIT 10;

SELECT '--- Sample Data From The Fact Table ---' as info;
SELECT * FROM company_schema.fact_company_hiring_monthly LIMIT 10;

SELECT '--- Job Title Bridge Sample ---' as info;
SELECT 
    djt.job_title_short_id,
    djt.job_title_short,
    dj.job_title_id,
    dj.job_title
FROM company_schema.bridge_job_title as bjt
INNER JOIN company_schema.dim_job_title_short as djt
    ON bjt.job_title_short_id = djt.job_title_short_id
INNER JOIN company_schema.dim_job_title as dj
    ON bjt.job_title_id = dj.job_title_id
WHERE djt.job_title_short = 'Data Engineer'
LIMIT 10;

SELECT '--- Company Location Bridge Sample ---' as info;
SELECT 
    dc.company_id,
    dc.company_name,
    dl.location_id,
    dl.job_location,
    dl.job_country
FROM company_schema.bridge_company_location as bcl
INNER JOIN company_schema.dim_company AS dc ON bcl.company_id = dc.company_id
INNER JOIN company_schema.dim_location AS dl ON bcl.location_id = dl.location_id
LIMIT 10;

-- .read 2_Data_Warehouse_Mart_Build/07_company_mart.sql
