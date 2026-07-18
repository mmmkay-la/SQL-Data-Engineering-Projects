/*
Question: What are the higest paying skills in data engineering?
-- Calculate the median salary for each skill required in data engineer positions.
-- Focus on job positions specific to the Philippines.
-- Include skill frequency to identify salary and demand.
Why? 
    - Helps identify which skills command the highest compensation while also showing how common
    those skills are, providing a more complete picture for skill development priorities.
    - The median is used instead of the average to reduce the impact of outlier salaries.
*/

SELECT
    sd.skills,
    COUNT(sd.skills) AS demand_count,
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS salary_median,
    sd.type AS skill_type
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_country in ('Philippines')
    AND jpf.job_title_short in ('Data Engineer')
GROUP BY sd.skills, sd.type
HAVING COUNT(sd.skills) >= 100
    AND ROUND(MEDIAN(jpf.salary_year_avg),0) IS NOT NULL
ORDER BY salary_median DESC;

/*
Key Takeaways:
- Flow is the highest paying skill for Data Engineer roles in the Philippines paying ~ $147,000 median salary
- Unix comes in second that pays ~ $140,000 median salary 
followed by SSIS (SQL Server Integration Servises) and kubernetes with median salary of ~ $114,000 median salary 
- SQL and Python, the top most in-demand skills for Data Engineer has a median salary of ~ $84,000
- Kafka and Airflow have the least median salary of ~$40,000 median salary 
- Notable Skills with high pay and medium-high demand:
-- AWS median salary of ~ $80,000 (1235 job postings)
-- Azure median salry of ~ $70,000 (1,535 job postings)
-- Apache Spark median salry of ~ $70,000 (860 job postings)
-- Power Bi median salry of ~ $94,000 (637 job postings)
-- Databricks median salry of ~ $70,000 (636 job postings)

** Note: Even though Flow is the highest paying skill for Data Engineering it only had a couple hundred job postings based on the Philippines (~200 job postings).
┌────────────┬──────────────┬───────────────┬───────────────┐
│   skills   │ demand_count │ salary_median │  skill_type   │
│  varchar   │    int64     │    double     │    varchar    │
├────────────┼──────────────┼───────────────┼───────────────┤
│ flow       │          238 │      147500.0 │ other         │
│ unix       │          214 │      140000.0 │ os            │
│ kubernetes │          137 │      114177.0 │ other         │
│ ssis       │          306 │      114177.0 │ analyst_tools │
│ r          │          270 │       97444.0 │ programming   │
│ bigquery   │          235 │       96773.0 │ cloud         │
│ postgresql │          223 │       96773.0 │ databases     │
│ java       │          737 │       96773.0 │ programming   │
│ php        │          146 │       96773.0 │ programming   │
│ javascript │          180 │       96250.0 │ programming   │
│ power bi   │          637 │       94583.0 │ analyst_tools │
│ go         │          122 │       93600.0 │ programming   │
│ nosql      │          481 │       90386.0 │ programming   │
│ linux      │          231 │       84000.0 │ os            │
│ snowflake  │          544 │       84000.0 │ cloud         │
│ hadoop     │          594 │       84000.0 │ libraries     │
│ sql        │         2870 │       84000.0 │ programming   │
│ python     │         2403 │       84000.0 │ programming   │
│ excel      │          378 │       84000.0 │ analyst_tools │
│ mysql      │          278 │       84000.0 │ databases     │
│ redshift   │          419 │       83762.0 │ cloud         │
│ scala      │          470 │       83387.0 │ programming   │
│ shell      │          276 │       80000.0 │ programming   │
│ aws        │         1235 │       80000.0 │ cloud         │
│ gcp        │          420 │       75375.0 │ cloud         │
│ tableau    │          461 │       70887.0 │ analyst_tools │
│ spark      │          860 │       70750.0 │ libraries     │
│ azure      │         1535 │       70375.0 │ cloud         │
│ databricks │          636 │       70000.0 │ cloud         │
│ oracle     │          387 │       50400.0 │ cloud         │
│ kafka      │          425 │       45000.0 │ libraries     │
│ airflow    │          391 │       45000.0 │ libraries     │
└────────────┴──────────────┴───────────────┴───────────────┘
*/