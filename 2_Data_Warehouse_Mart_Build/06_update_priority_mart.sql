
-- Update priority_schema.priority_jobs_snapshot to reflete priority_roles changes
SELECT 'Priority Mart Update Started ...' AS status;
-- Create a temporary Table as source table for uppdate. Table reflects the changes
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs_tmmp AS 
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


MERGE INTO priority_schema.priority_jobs_snapshot AS tgt
    USING src_priority_jobs_tmmp AS src
    ON tgt.job_title_short = src.job_title_short
WHEN MATCHED AND tgt.priority_level IS DISTINCT FROM src.priority_level THEN
    -- existing rows, then update
    UPDATE SET 
        priority_level = src.priority_level,
        updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    -- new rows, then insert
    INSERT (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_level,
        updated_at )
    VALUES (
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_level,
        CURRENT_TIMESTAMP
    ) 
WHEN NOT MATCHED BY SOURCE THEN DELETE;
    -- removed rows, then delete

SELECT '======= PRIORITY_MART UPDATED =======' AS status;

-- .read 2_Data_Warehouse_Mart_Build/06_update_priority_mart.sql